// Backfill script: set companyId and createdBy for legacy documents across collections
// Usage:
//   node functions/backfill_company_createdby.js [--dry] [--limit=1000]
// Requires Firebase Admin credentials. Set GOOGLE_APPLICATION_CREDENTIALS or run in Functions env.

/* eslint-disable no-console */
const admin = require('firebase-admin');

// Initialize admin if not already
try {
    admin.initializeApp();
} catch (_) {
    // ignore when already initialized
}

const db = admin.firestore();

const args = process.argv.slice(2);
const isDryRun = args.some((a) => a === '--dry' || a === '--dry-run');
const limitArg = args.find((a) => a.startsWith('--limit='));
const HARD_LIMIT = limitArg ? parseInt(limitArg.split('=')[1], 10) : undefined;

// Collections to process and the fields that should exist
const TARGETS = [
    { name: 'customers', fields: { companyId: true, createdBy: true } },
    { name: 'suppliers', fields: { companyId: true, createdBy: true } },
    { name: 'products', fields: { companyId: true, createdBy: true } },
    { name: 'warehouses', fields: { companyId: true, createdBy: true } },
    { name: 'stock_movements', fields: { companyId: true, createdBy: true } },
    { name: 'expenses', fields: { companyId: true, createdBy: true } },
    { name: 'incomes', fields: { companyId: true, createdBy: true } },
    { name: 'sales', fields: { companyId: true, createdBy: true } },
    { name: 'purchases', fields: { companyId: true, createdBy: true } },
    { name: 'cash_accounts', fields: { companyId: true, createdBy: true } },
    { name: 'reports', fields: { companyId: true, createdBy: true } },
];

async function loadUserCompanyMap() {
    const snap = await db.collection('users').get();
    const map = new Map();
    snap.forEach((doc) => {
        const data = doc.data() || {};
        const companies = Array.isArray(data.companies) ? data.companies : [];
        map.set(doc.id, companies.length > 0 ? companies[0] : '');
    });
    return map;
}

async function backfillCollection(colName, fields, userCompanyMap) {
    console.log(`\n▶ Processing collection: ${colName}`);

    let processed = 0;
    let updated = 0;
    const pageSize = 500; // Firestore read page size
    let lastDoc = undefined;

    while (true) {
        let query = db.collection(colName).orderBy(admin.firestore.FieldPath.documentId());
        if (lastDoc) query = query.startAfter(lastDoc);
        if (HARD_LIMIT) query = query.limit(Math.min(HARD_LIMIT - processed, pageSize));
        else query = query.limit(pageSize);

        const snap = await query.get();
        if (snap.empty) break;

        // Prepare batch
        let batch = db.batch();
        let batchCount = 0;

        snap.forEach((doc) => {
            processed += 1;
            const data = doc.data() || {};
            const needsCompany = fields.companyId && (!data.companyId || data.companyId === '');
            const needsCreatedBy = fields.createdBy && (!data.createdBy || data.createdBy === '');

            if (needsCompany || needsCreatedBy) {
                const uid = data.createdBy || data.updatedBy || data.ownerId || '';
                const inferredCompany = uid ? (userCompanyMap.get(uid) || '') : '';
                const updates = {};
                if (needsCompany) updates.companyId = inferredCompany;
                if (needsCreatedBy) updates.createdBy = uid || 'system';
                updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();

                if (!isDryRun) {
                    batch.update(doc.ref, updates);
                    batchCount += 1;
                    updated += 1;
                    if (batchCount >= 450) {
                        // commit and reset batch to stay under limits
                        // eslint-disable-next-line no-await-in-loop
                        await batch.commit();
                        batch = db.batch();
                        batchCount = 0;
                    }
                } else {
                    updated += 1; // count only
                }
            }
        });

        if (!isDryRun && batchCount > 0) {
            await batch.commit();
        }

        lastDoc = snap.docs[snap.docs.length - 1];
        if (HARD_LIMIT && processed >= HARD_LIMIT) break;
    }

    console.log(`✔ ${colName}: processed=${processed}, updated=${updated} ${isDryRun ? '(dry-run)' : ''}`);
}

async function main() {
    console.log('=== Backfill companyId/createdBy START ===');
    console.log(`Dry run: ${isDryRun}`);
    if (HARD_LIMIT) console.log(`Hard limit: ${HARD_LIMIT}`);

    const userCompanyMap = await loadUserCompanyMap();
    for (const t of TARGETS) {
        // eslint-disable-next-line no-await-in-loop
        await backfillCollection(t.name, t.fields, userCompanyMap);
    }

    console.log('=== Backfill DONE ===');
}

main().catch((e) => {
    console.error('Backfill failed:', e);
    process.exit(1);
});


