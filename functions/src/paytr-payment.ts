// ========== PAYTR PAYMENT CLOUD FUNCTION ==========
// functions/src/paytr-payment.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

export const createPayTRPayment = functions.https.onCall(async (data, context) => {
    // Authentication kontrolü
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userId = context.auth.uid;
    const { planType, amount, currency = 'TRY' } = data;

    // Input validation
    if (!planType || !amount) {
        throw new functions.https.HttpsError('invalid-argument', 'planType and amount are required');
    }

    try {
        console.log('PayTR: Creating payment for user:', userId);
        console.log('PayTR: Plan type:', planType);
        console.log('PayTR: Amount:', amount);

        // PayTR merchant bilgileri - Environment variables kullan
        const merchantId = process.env.PAYTR_MERCHANT_ID || '622887';
        const merchantKey = process.env.PAYTR_MERCHANT_KEY || 'uePB6f7AfxtAAyqZ';
        const merchantSalt = process.env.PAYTR_MERCHANT_SALT || 'ejdEC3ReZay7QxE8';
        const isTestMode = process.env.PAYTR_TEST_MODE === '1' || true;

        console.log('PayTR: merchantId:', merchantId);
        console.log('PayTR: isTestMode:', isTestMode);

        // Sipariş ID oluştur (alfanumerik olmalı)
        const timestamp = Date.now();
        const orderId = `TMG${timestamp}${userId.replace(/[^a-zA-Z0-9]/g, '')}`;

        // Kullanıcı bilgilerini al
        const userDoc = await admin.firestore().collection('users').doc(userId).get();
        if (!userDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }

        const userData = userDoc.data()!;
        const userEmail = userData.email || '';
        const userName = `${userData.name || ''} ${userData.surname || ''}`.trim();
        const userPhone = userData.phone || '5550000000';

        // PayTR parametreleri
        const params = {
            merchant_id: merchantId,
            user_ip: '127.0.0.1', // Test için
            merchant_oid: orderId,
            email: userEmail,
            payment_amount: Math.round(amount * 100), // TL'den kuruşa çevir
            user_basket: Buffer.from(JSON.stringify([
                [getProductName(planType), Math.round(amount * 100), 1]
            ])).toString('base64'),
            no_installment: 0,
            max_installment: 0,
            currency: currency,
            test_mode: isTestMode ? '1' : '0',
        };

        // PayTR hash oluştur
        const hashString = `${params.merchant_id}${params.user_ip}${params.merchant_oid}${params.email}${params.payment_amount}${params.user_basket}${params.no_installment}${params.max_installment}${params.currency}${params.test_mode}`;
        const paytrToken = hashString + merchantSalt;
        const hash = crypto.createHmac('sha256', merchantKey).update(paytrToken).digest('base64');

        console.log('PayTR: Hash created successfully');

        // Firestore'da abonelik kaydı oluştur
        const subscriptionData = {
            id: orderId,
            orderId: orderId, // PayTR callback için gerekli
            userId: userId,
            planType: planType,
            status: 'pending',
            provider: 'paytr',
            amount: amount,
            currency: currency,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        await admin.firestore().collection('subscriptions').doc(orderId).set(subscriptionData);

        console.log('PayTR: Subscription record created:', orderId);

        // PayTR API'ye istek gönder
        const formData = new URLSearchParams();
        Object.entries(params).forEach(([key, value]) => {
            formData.append(key, value.toString());
        });
        formData.append('paytr_token', hash);

        const response = await fetch('https://www.paytr.com/odeme/api/get-token', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: formData.toString(),
        });

        const result = await response.json() as any;
        console.log('PayTR: API response:', result);

        if (result.status === 'success') {
            return {
                success: true,
                token: result.token,
                iframeUrl: `https://www.paytr.com/odeme/guvenli/${result.token}`,
                orderId: orderId,
            };
        } else {
            throw new functions.https.HttpsError('internal', result.reason || 'PayTR payment creation failed');
        }

    } catch (error) {
        console.error('PayTR payment creation error:', error);
        throw new functions.https.HttpsError('internal', `PayTR payment creation failed: ${error}`);
    }
});

// Plan tipine göre ürün adı
function getProductName(planType: string): string {
    switch (planType) {
        case 'monthly':
            return 'TAMGACI Aylık Abonelik';
        case 'semiAnnual':
            return 'TAMGACI 6 Aylık Abonelik';
        case 'annual':
            return 'TAMGACI Yıllık Abonelik';
        default:
            return 'TAMGACI Abonelik';
    }
}
