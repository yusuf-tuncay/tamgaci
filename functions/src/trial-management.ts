// ========== TRIAL MANAGEMENT CLOUD FUNCTION ==========
// functions/src/trial-management.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const createUserTrial = functions.https.onCall(async (data, context) => {
    // Authentication kontrolü
    // @ts-ignore - Firebase Functions v2 type issue
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // @ts-ignore - Firebase Functions v2 type issue
    const userId = context.auth.uid;

    try {
        console.log('Trial: Creating trial for user:', userId);

        const db = admin.firestore();
        const now = new Date();
        const trialEndDate = new Date(now.getTime() + (30 * 24 * 60 * 60 * 1000)); // 30 gün

        // Kullanıcının mevcut trial'ını kontrol et
        const existingTrial = await db
            .collection('trials')
            .where('userId', '==', userId)
            .where('status', '==', 'active')
            .limit(1)
            .get();

        if (!existingTrial.empty) {
            console.log('Trial: User already has an active trial');
            return {
                success: true,
                message: 'User already has an active trial',
                trialId: existingTrial.docs[0].id,
            };
        }

        // Trial oluştur
        const trialData = {
            userId: userId,
            startDate: now,
            endDate: trialEndDate,
            status: 'active',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        const trialRef = await db.collection('trials').add(trialData);
        console.log('Trial: Trial created with ID:', trialRef.id);

        // Kullanıcı bilgilerini güncelle
        await db.collection('users').doc(userId).update({
            trialStatus: 'active',
            trialEndAt: trialEndDate,
            subscriptionStatus: 'trial',
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log('Trial: User trial status updated');

        return {
            success: true,
            trialId: trialRef.id,
            startDate: now,
            endDate: trialEndDate,
            message: 'Trial created successfully',
        };

    } catch (error) {
        console.error('Trial: Trial creation error:', error);
        throw new functions.https.HttpsError('internal', `Trial creation failed: ${error}`);
    }
});

export const checkTrialStatus = functions.https.onCall(async (data, context) => {
    // Authentication kontrolü
    // @ts-ignore - Firebase Functions v2 type issue
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // @ts-ignore - Firebase Functions v2 type issue
    const userId = context.auth.uid;

    try {
        console.log('Trial: Checking trial status for user:', userId);

        const db = admin.firestore();
        const now = new Date();

        // Kullanıcının aktif trial'ını al
        const trialSnapshot = await db
            .collection('trials')
            .where('userId', '==', userId)
            .where('status', '==', 'active')
            .limit(1)
            .get();

        if (trialSnapshot.empty) {
            return {
                success: true,
                hasTrial: false,
                status: 'none',
                message: 'No active trial found',
            };
        }

        const trialDoc = trialSnapshot.docs[0];
        const trialData = trialDoc.data();
        const endDate = trialData.endDate.toDate();

        if (now > endDate) {
            // Trial süresi dolmuş
            await trialDoc.ref.update({
                status: 'expired',
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Kullanıcı bilgilerini güncelle
            await db.collection('users').doc(userId).update({
                trialStatus: 'expired',
                subscriptionStatus: 'none',
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            return {
                success: true,
                hasTrial: true,
                status: 'expired',
                message: 'Trial has expired',
            };
        }

        // Trial aktif
        const remainingDays = Math.ceil((endDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

        return {
            success: true,
            hasTrial: true,
            status: 'active',
            remainingDays: remainingDays,
            endDate: endDate,
            message: 'Trial is active',
        };

    } catch (error) {
        console.error('Trial: Trial status check error:', error);
        throw new functions.https.HttpsError('internal', `Trial status check failed: ${error}`);
    }
});
