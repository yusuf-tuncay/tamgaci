import * as functions from 'firebase-functions';
import * as cors from 'cors';

const corsHandler = cors({ origin: true });

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
