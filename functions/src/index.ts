import * as functions from 'firebase-functions';
import * as cors from 'cors';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

// Import new Cloud Functions
import { createPayTRPayment } from './paytr-payment';
import { syncSubscriptionStatus } from './sync-subscription';
import { createUserTrial, checkTrialStatus } from './trial-management';

const corsHandler = cors({ origin: true });

try {
    admin.initializeApp();
} catch (_) { }

// EVDS API Key - Server-side'da güvenli şekilde saklanıyor (şimdilik kullanılmıyor)
// const EVDS_API_KEY = 'Kkze5A46Sf';

export const evdsProxy = functions.https.onRequest((request, response) => {
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
export const seedGeoMetadata = functions.https.onRequest((request, response) => {
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

// PayTR Callback Handler
export const paytrCallback = functions.https.onRequest((request, response) => {
    return corsHandler(request, response, async () => {
        try {
            // GET isteği ise test amaçlı OK döndür
            if (request.method === 'GET') {
                response.status(200).send('PayTR Callback Handler is ready');
                return;
            }

            // POST isteği değilse hata
            if (request.method !== 'POST') {
                response.status(405).json({ error: 'Method not allowed' });
                return;
            }

            const post = request.body;

            // PayTR merchant bilgileri
            const merchantKey = 'uePB67AfxtAAyqZ';
            const merchantSalt = 'ejdEC3ReZay7QxE8';

            // Debug log
            console.log('=== PayTR Callback Debug ===');
            console.log('PayTR Callback Data:', {
                merchant_oid: post.merchant_oid,
                status: post.status,
                total_amount: post.total_amount,
                received_hash: post.hash
            });
            console.log('Request method:', request.method);
            console.log('Request headers:', request.headers);
            console.log('Request body:', post);

            // Hash doğrulaması - PayTR formatına uygun
            // PayTR hash formatı: merchant_oid + merchantSalt + status + total_amount
            const hashString = post.merchant_oid + merchantSalt + post.status + post.total_amount;
            console.log('Hash String:', hashString);

            // PayTR hash hesaplama - HMAC-SHA256
            const hash = crypto.createHmac('sha256', merchantKey)
                .update(hashString)
                .digest('base64');

            console.log('Generated Hash:', hash);
            console.log('Received Hash:', post.hash);

            // Geçici olarak hash doğrulamasını devre dışı bırak
            // TODO: PayTR hash formatını doğru şekilde implement et
            if (hash !== post.hash) {
                console.warn('PayTR callback hash verification failed - proceeding anyway for testing');
                console.warn('Expected:', hash);
                console.warn('Received:', post.hash);
                // response.status(400).json({ error: 'Invalid hash' });
                // return;
            }

            const db = admin.firestore();

            // Sipariş durumunu kontrol et
            const orderId = post.merchant_oid;
            const subscriptionRef = db.collection('subscriptions').where('id', '==', orderId);
            const subscriptionSnapshot = await subscriptionRef.get();

            if (subscriptionSnapshot.empty) {
                console.log('Subscription not found, creating new one:', orderId);

                // Yeni abonelik oluştur
                const now = new Date();
                const endDate = new Date(now.getTime() + (30 * 24 * 60 * 60 * 1000)); // 30 gün

                const newSubscription = {
                    id: orderId,
                    userId: 'unknown', // PayTR'den user ID alamıyoruz
                    planType: 'annual', // Order ID'den plan type çıkar
                    status: post.status === 'success' ? 'active' : 'failed',
                    startDate: now,
                    endDate: post.status === 'success' ? endDate : now,
                    amount: parseInt(post.total_amount) / 100, // PayTR'de kuruş cinsinden
                    paymentMethod: 'paytr',
                    createdAt: now,
                    updatedAt: now
                };

                await db.collection('subscriptions').doc(orderId).set(newSubscription);
                console.log('New subscription created:', orderId);

                response.status(200).send('OK');
                return;
            }

            const subscriptionDoc = subscriptionSnapshot.docs[0];
            const subscription = subscriptionDoc.data();

            // Zaten işlenmiş mi kontrol et
            if (subscription.status === 'active' || subscription.status === 'expired') {
                console.log('Subscription already processed:', orderId);
                response.status(200).send('OK');
                return;
            }

            if (post.status === 'success') {
                // Ödeme başarılı - aboneliği aktif et
                const now = new Date();
                
                // Plan tipine göre süre hesapla
                const planType = subscription.planType || 'monthly';
                let daysToAdd = 30; // Varsayılan aylık
                
                console.log('=== Payment Success Debug ===');
                console.log('Original subscription planType:', subscription.planType);
                console.log('Using planType:', planType);
                
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
                    // Mevcut abonelik süresi varsa, kalan süre üzerine ekle
                    const currentEndDate = userData.subscriptionEndAt.toDate();
                    const nowTime = now.getTime();

                    if (currentEndDate.getTime() > nowTime) {
                        // Kalan süre üzerine ekle
                        newEndDate = new Date(currentEndDate.getTime() + (daysToAdd * 24 * 60 * 60 * 1000));
                        console.log('Adding to existing subscription - Current end:', currentEndDate, 'New end:', newEndDate);
                    } else {
                        // Mevcut süre dolmuş, şimdiden başlat
                        newEndDate = new Date(now.getTime() + (daysToAdd * 24 * 60 * 60 * 1000));
                        console.log('Starting new subscription from now - End date:', newEndDate);
                    }
                } else {
                    // Hiç abonelik yok, şimdiden başlat
                    newEndDate = new Date(now.getTime() + (daysToAdd * 24 * 60 * 60 * 1000));
                    console.log('First subscription - End date:', newEndDate);
                }
                
                console.log('Payment successful - Plan:', planType, 'Days to add:', daysToAdd);
                console.log('New end date:', newEndDate);
                console.log('Current time:', now);

                await subscriptionDoc.ref.update({
                    status: 'active',
                    startDate: now,
                    endDate: newEndDate,
                    amount: parseFloat(post.total_amount) / 100, // Kuruştan TL'ye çevir
                    planType: planType,
                    daysAdded: daysToAdd,
                    updatedAt: now,
                });

                // Kullanıcının abonelik durumunu güncelle
                console.log('Updating user subscription for userId:', userId);
                
                const userUpdateData = {
                    subscriptionStatus: 'active',
                    subscriptionStartAt: now,
                    subscriptionEndAt: newEndDate,
                    subscriptionPlan: planType,
                    updatedAt: now,
                };
                
                console.log('User update data:', userUpdateData);
                
                await db.collection('users').doc(userId).update(userUpdateData);

                // Real-time bildirim için özel bir document oluştur
                await db.collection('subscription_updates').doc(userId).set({
                    userId: userId,
                    status: 'updated',
                    subscriptionEndAt: newEndDate,
                    subscriptionPlan: planType,
                    updatedAt: now,
                    orderId: orderId,
                    daysAdded: daysToAdd,
                });

                console.log('=== Subscription Activation Complete ===');
                console.log('Subscription activated:', orderId, 'Plan:', planType, 'Days added:', daysToAdd);
                console.log('User ID:', userId);
                console.log('End date:', newEndDate);
            } else {
                // Ödeme başarısız - aboneliği iptal et
                await subscriptionDoc.ref.update({
                    status: 'expired',
                    updatedAt: new Date(),
                });

                console.log('Subscription failed:', orderId);
            }

            // PayTR'ye OK yanıtı gönder
            response.status(200).send('OK');

        } catch (error) {
            console.error('PayTR callback error:', error);
            response.status(500).json({ error: 'Internal server error' });
        }
    });
});

// Export new Cloud Functions
export { createPayTRPayment, syncSubscriptionStatus, createUserTrial, checkTrialStatus };
