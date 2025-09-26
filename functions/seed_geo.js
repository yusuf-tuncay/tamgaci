// Seed Firestore with cities/districts and tax offices
// Usage: node seed_geo.js

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function main() {
    try {
        const citiesPath = resolve(__dirname, '..', 'il_ilce.json');
        const taxPath = resolve(__dirname, '..', 'vergi_daireleri.json');

        const citiesRaw = readFileSync(citiesPath, 'utf-8');
        const taxRaw = readFileSync(taxPath, 'utf-8');

        const citiesJson = JSON.parse(citiesRaw);
        const taxJson = JSON.parse(taxRaw);

        const payload = {
            cities: citiesJson.map((c) => ({ name: c.il_adi, districts: c.ilceler })),
            taxOffices: taxJson,
        };

        const url = 'https://us-central1-tamgaci.cloudfunctions.net/seedGeoMetadata';
        const res = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
        });
        const text = await res.text();
        if (!res.ok) {
            console.error('Seed failed:', res.status, text);
            process.exit(1);
        }
        console.log('Seed success:', text);
    } catch (err) {
        console.error('Seed error:', err);
        process.exit(1);
    }
}

main();


