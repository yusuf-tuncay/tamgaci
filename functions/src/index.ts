import * as functions from 'firebase-functions';
import * as cors from 'cors';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

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
            // Sadece POST isteklerine izin ver
            if (request.method !== 'POST') {
                response.status(405).json({ error: 'Method not allowed' });
                return;
            }

            const post = request.body;
            
            // PayTR merchant bilgileri
            const merchantKey = 'uePB67AfxtAAyqZ';
            const merchantSalt = 'ejdEC3ReZay7QxE8';
            
            // Hash doğrulaması
            const hash = crypto.createHmac('sha256', merchantKey)
                .update(post.merchant_oid + merchantSalt + post.status + post.total_amount)
                .digest('base64');
            
            if (hash !== post.hash) {
                console.error('PayTR callback hash verification failed');
                response.status(400).json({ error: 'Invalid hash' });
                return;
            }
            
            const db = admin.firestore();
            
            // Sipariş durumunu kontrol et
            const orderId = post.merchant_oid;
            const subscriptionRef = db.collection('subscriptions').where('id', '==', orderId);
            const subscriptionSnapshot = await subscriptionRef.get();
            
            if (subscriptionSnapshot.empty) {
                console.error('Subscription not found:', orderId);
                response.status(404).json({ error: 'Subscription not found' });
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
                const endDate = new Date(now.getTime() + (30 * 24 * 60 * 60 * 1000)); // 30 gün
                
                await subscriptionDoc.ref.update({
                    status: 'active',
                    startDate: now,
                    endDate: endDate,
                    amount: parseFloat(post.total_amount) / 100, // Kuruştan TL'ye çevir
                    updatedAt: now,
                });
                
                // Kullanıcının abonelik durumunu güncelle
                const userId = subscription.userId;
                await db.collection('users').doc(userId).update({
                    subscriptionStatus: 'active',
                    subscriptionEndAt: endDate,
                    updatedAt: now,
                });
                
                console.log('Subscription activated:', orderId);
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
