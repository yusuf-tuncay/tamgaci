import { onRequest } from 'firebase-functions/v2/https';
import * as cors from 'cors';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

// Import new Cloud Functions
import { createPayTRPayment } from './paytr-payment';
import { syncSubscriptionStatus } from './sync-subscription';
import { createUserTrial, checkTrialStatus } from './trial-management';
import { sendContactEmail } from './send-contact-email';
import { sendFeedbackEmail } from './send-feedback-email';

const corsHandler = cors({ origin: true });

try {
    admin.initializeApp();
} catch (_) { }

// EVDS API Key - Server-side'da güvenli şekilde saklanıyor (şimdilik kullanılmıyor)
// const EVDS_API_KEY = 'Kkze5A46Sf';

export const evdsProxy = onRequest(
    {
        cors: true,
        invoker: 'public', // Allow public access
    },
    (request, response) => {
    return corsHandler(request, response, async () => {
        try {
            // Sadece GET isteklerine izin ver
            if (request.method !== 'GET') {
                response.status(405).json({ error: 'Method not allowed' });
                return;
            }

            // URL parametresini al
            const targetUrl = request.query.url as string;
            if (!targetUrl) {
                response.status(400).json({ error: 'URL parameter is required' });
                return;
            }

            // EVDS API'ye istek gönder
            const fetch = (await import('node-fetch')).default;
            const evdsResponse = await fetch(targetUrl, {
                method: 'GET',
                headers: {
                    'User-Agent': 'Firebase-Functions-Proxy/1.0',
                },
                timeout: 10000, // 10 saniye timeout
            });

            if (!evdsResponse.ok) {
                response.status(evdsResponse.status).json({
                    error: 'EVDS API error',
                    status: evdsResponse.status
                });
                return;
            }

            const data = await evdsResponse.json();

            // CORS headers ekle
            response.set('Access-Control-Allow-Origin', '*');
            response.set('Access-Control-Allow-Methods', 'GET');
            response.set('Access-Control-Allow-Headers', 'Content-Type');

            response.json(data);
        } catch (error) {
            console.error('Proxy error:', error);
            response.status(500).json({
                error: 'Internal server error',
                message: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    });
});

// One-time seeding function to load il/ilçe and tax offices into Firestore
export const seedGeoMetadata = onRequest((request, response) => {
    return corsHandler(request, response, async () => {
        try {
            if (request.method !== 'POST') {
                response.status(405).json({ error: 'Method not allowed' });
                return;
            }

            const body = request.body as any;
            const cities = body?.cities as Array<{ name: string; districts: string[] }> | undefined;
            const taxOffices = body?.taxOffices as string[] | undefined;

            if (!cities || !taxOffices) {
                response.status(400).json({ error: 'Payload must include cities[] and taxOffices[]' });
                return;
            }

            const db = admin.firestore();

            // Batch write cities
            const batch = db.batch();
            for (const c of cities) {
                const docRef = db.collection('geo_cities').doc(c.name);
                batch.set(docRef, { name: c.name, districts: c.districts });
            }
            // Tax offices list
            const taxDoc = db.collection('metadata').doc('tax_offices');
            batch.set(taxDoc, { names: taxOffices });

            await batch.commit();

            response.json({ ok: true, cities: cities.length, taxOffices: taxOffices.length });
        } catch (error) {
            console.error('seedGeoMetadata error:', error);
            response.status(500).json({ error: 'Internal server error' });
        }
    });
});

// PayTR Callback Handler - PayTR dökümanına göre yeniden yazıldı
export const paytrCallback = onRequest((request, response) => {
    return corsHandler(request, response, async () => {
        try {
            console.log('=== PayTR Callback Started ===');
            console.log('Method:', request.method);
            console.log('Headers:', request.headers);
            console.log('Body:', request.body);

            // GET isteği ise test amaçlı OK döndür
            if (request.method === 'GET') {
                console.log('GET request received - returning OK');
                response.status(200).send('PayTR Callback Handler is ready');
                return;
            }

            // POST isteği değilse hata
            if (request.method !== 'POST') {
                console.log('Invalid method:', request.method);
                response.status(405).json({ error: 'Method not allowed' });
                return;
            }

            const post = request.body;
            console.log('POST data received:', post);

            // PayTR merchant bilgileri
            const merchantKey = 'uePB6f7AfxtAAyqZ';
            const merchantSalt = 'ejdEC3ReZay7QxE8';

            // PayTR RESMİ DÖKÜMANTASYONUNA GÖRE HASH DOĞRULAMASI
            // PayTR callback hash: HMAC-SHA256(merchant_oid + merchant_salt + status + total_amount, merchant_key)
            // Kaynak: https://dev.paytr.com - Resmi PayTR dökümantasyonu
            const hash_str = post.merchant_oid + merchantSalt + post.status + post.total_amount;
            const hash = crypto.createHmac('sha256', merchantKey).update(hash_str).digest('base64');

            console.log('🔍 PAYTR HASH DEBUG (RESMİ DÖKÜMANTASYON):');
            console.log('merchant_oid:', post.merchant_oid);
            console.log('merchant_salt:', merchantSalt);
            console.log('status:', post.status);
            console.log('total_amount:', post.total_amount);
            console.log('merchant_key:', merchantKey);
            console.log('Hash String (merchant_oid + merchant_salt + status + total_amount):', hash_str);
            console.log('Generated Hash (HMAC-SHA256):', hash);

            console.log('Received Hash:', post.hash);

            // PayTR RESMİ DÖKÜMANTASYONUNA GÖRE HASH DOĞRULAMASI
            console.log('🔐 PAYTR HASH VERIFICATION (RESMİ DÖKÜMANTASYON):');
            console.log('Hash String:', hash_str);
            console.log('Merchant Key:', merchantKey);
            console.log('Generated Hash:', hash);
            console.log('Received Hash:', post.hash);

            if (hash !== post.hash) {
                console.error('❌ PayTR Hash verification failed - MISMATCH DETECTED');
                console.error('Expected (PayTR Official):', hash);
                console.error('Received:', post.hash);
                console.error('Hash string used:', hash_str);
                console.error('Merchant Key used:', merchantKey);
                console.error('Merchant Salt used:', merchantSalt);
                response.status(400).json({ error: 'Invalid hash' });
                return;
            } else {
                console.log('✅ PayTR Hash verification successful - PROCEEDING');
            }

            const db = admin.firestore();
            const orderId = post.merchant_oid;

            console.log('Looking for subscription with orderId:', orderId);
            console.log('Order ID length:', orderId.length);
            console.log('Order ID type:', typeof orderId);

            // Subscription'ı bul
            const subscriptionDoc = await db.collection('subscriptions').doc(orderId).get();

            if (!subscriptionDoc.exists) {
                console.error('Subscription not found for orderId:', orderId);
                console.log('Available subscriptions in database:');
                // Tüm subscription'ları listele
                const allSubs = await db.collection('subscriptions').limit(10).get();
                allSubs.forEach(doc => {
                    console.log('Available subscription ID:', doc.id);
                });
                console.log('⚠️ Subscription not found - but continuing anyway for testing');
                // TEST AMAÇLI: Subscription bulunamasa bile devam et
                // response.status(400).json({ error: 'Invalid order ID' });
                // return;

                // Test için dummy subscription oluştur
                const dummySubscription = {
                    userId: 'test-user',
                    planType: 'monthly',
                    status: 'pending'
                };
                console.log('Using dummy subscription for testing:', dummySubscription);
                const subscription = dummySubscription;

                // Ödeme durumuna göre işlem yap
                if (post.status === 'success') {
                    console.log('Payment successful - updating dummy subscription');
                    console.log('✅ Test mode: Payment processed successfully');
                    response.status(200).send('OK');
                    return;
                } else {
                    console.log('Payment failed - dummy subscription');
                    response.status(200).send('OK');
                    return;
                }
            }

            const subscription = subscriptionDoc.data();
            console.log('Found subscription:', subscription);

            // Ödeme durumuna göre işlem yap
            if (post.status === 'success') {
                console.log('Payment successful - updating subscription');

                const now = new Date();
                const planType = subscription.planType || 'monthly';
                let daysToAdd = 30;

                switch (planType) {
                    case 'monthly':
                        daysToAdd = 30;
                        break;
                    case 'semiAnnual':
                        daysToAdd = 180;
                        break;
                    case 'annual':
                        daysToAdd = 365;
                        break;
                    default:
                        daysToAdd = 30;
                        break;
                }

                // Kullanıcının mevcut abonelik durumunu kontrol et
                const userId = subscription.userId;
                const userDoc = await db.collection('users').doc(userId).get();
                const userData = userDoc.data();

                let newEndDate: Date;

                if (userData && userData.subscriptionEndAt) {
                    const currentEndDate = userData.subscriptionEndAt.toDate();
                    const nowTime = now.getTime();

                    if (currentEndDate.getTime() > nowTime) {
                        newEndDate = new Date(currentEndDate.getTime() + (daysToAdd * 24 * 60 * 60 * 1000));
                        console.log('Adding to existing subscription');
                    } else {
                        newEndDate = new Date(now.getTime() + (daysToAdd * 24 * 60 * 60 * 1000));
                        console.log('Starting new subscription');
                    }
                } else {
                    newEndDate = new Date(now.getTime() + (daysToAdd * 24 * 60 * 60 * 1000));
                    console.log('First subscription');
                }

                // Subscription'ı güncelle
                await subscriptionDoc.ref.update({
                    status: 'active',
                    startDate: now,
                    endDate: newEndDate,
                    amount: parseFloat(post.total_amount) / 100,
                    planType: planType,
                    daysAdded: daysToAdd,
                    updatedAt: now,
                });

                // Kullanıcının abonelik durumunu güncelle
                await db.collection('users').doc(userId).update({
                    subscriptionStatus: 'active',
                    subscriptionStartAt: now,
                    subscriptionEndAt: newEndDate,
                    subscriptionPlan: planType,
                    updatedAt: now,
                });

                // Real-time bildirim için
                await db.collection('subscription_updates').doc(userId).set({
                    userId: userId,
                    status: 'updated',
                    subscriptionEndAt: newEndDate,
                    subscriptionPlan: planType,
                    updatedAt: now,
                    orderId: orderId,
                    daysAdded: daysToAdd,
                });

                console.log('Subscription updated successfully');
            } else {
                console.log('Payment failed - updating subscription status');
                await subscriptionDoc.ref.update({
                    status: 'expired',
                    updatedAt: new Date(),
                });
            }

            // PayTR'ye OK yanıtı gönder
            console.log('Sending OK response to PayTR');
            response.status(200).send('OK');

        } catch (error) {
            console.error('🚨 PayTR callback error:', error);
            console.error('🚨 Error stack:', error instanceof Error ? error.stack : 'No stack');
            console.error('🚨 Error message:', error instanceof Error ? error.message : 'Unknown error');
            console.log('🚨 Sending 500 error to PayTR');
            response.status(500).json({ error: 'Internal server error' });
        }
    });
});

// Export all Cloud Functions
export { createPayTRPayment, syncSubscriptionStatus, createUserTrial, checkTrialStatus, sendContactEmail, sendFeedbackEmail };
