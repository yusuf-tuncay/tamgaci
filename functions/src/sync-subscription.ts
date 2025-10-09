// ========== SYNC SUBSCRIPTION CLOUD FUNCTION ==========
// functions/src/sync-subscription.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const syncSubscriptionStatus = functions.https.onCall(async (data, context) => {
    // Authentication kontrolü
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userId = context.auth.uid;

    try {
        console.log('Sync: Starting subscription sync for user:', userId);

        const db = admin.firestore();
        const now = new Date();

        // Kullanıcının aktif aboneliklerini al
        const subscriptionsSnapshot = await db
            .collection('subscriptions')
            .where('userId', '==', userId)
            .orderBy('createdAt', 'desc')
            .get();

        let activeSubscription = null;
        let latestSubscription = null;

        // En son aboneliği bul
        if (!subscriptionsSnapshot.empty) {
            latestSubscription = subscriptionsSnapshot.docs[0];
            const subscriptionData = latestSubscription.data();

            // Süresi dolmuş abonelikleri işaretle
            if (subscriptionData.status === 'active' && subscriptionData.endDate) {
                const endDate = subscriptionData.endDate.toDate();
                if (endDate < now) {
                    await latestSubscription.ref.update({
                        status: 'expired',
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    });
                    console.log('Sync: Subscription expired:', latestSubscription.id);
                } else {
                    activeSubscription = subscriptionData;
                }
            }
        }

        // Kullanıcının trial durumunu kontrol et
        const userDoc = await db.collection('users').doc(userId).get();
        if (!userDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'User not found');
        }

        const userData = userDoc.data()!;
        let subscriptionStatus = 'none';
        let trialStatus = 'none';

        // Trial kontrolü
        if (userData.trialEndAt) {
            const trialEndDate = userData.trialEndAt.toDate();
            if (trialEndDate > now) {
                trialStatus = 'active';
                subscriptionStatus = 'trial';
            } else {
                trialStatus = 'expired';
            }
        }

        // Aktif abonelik varsa
        if (activeSubscription) {
            subscriptionStatus = 'active';
            trialStatus = 'converted';
        }

        // Kullanıcı bilgilerini güncelle
        await userDoc.ref.update({
            subscriptionStatus: subscriptionStatus,
            trialStatus: trialStatus,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log('Sync: User subscription status updated:', subscriptionStatus);
        console.log('Sync: User trial status updated:', trialStatus);

        return {
            success: true,
            subscriptionStatus: subscriptionStatus,
            trialStatus: trialStatus,
            hasActiveSubscription: !!activeSubscription,
            message: 'Subscription status synced successfully',
        };

    } catch (error) {
        console.error('Sync: Subscription sync error:', error);
        throw new functions.https.HttpsError('internal', `Subscription sync failed: ${error}`);
    }
});
