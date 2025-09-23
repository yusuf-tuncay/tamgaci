## TCMB EVDS Exchange Rates API

We use the official TCMB EVDS API for up-to-date exchange rates. This API must always be used for currency data in the app.

Base endpoint example:

```
https://evds2.tcmb.gov.tr/service/evds/series=TP.DK.USD.A.YTL-TP.DK.USD.S.YTL-TP.DK.EUR.A.YTL-TP.DK.EUR.S.YTL-TP.DK.GBP.A.YTL-TP.DK.GBP.S.YTL-TP.DK.CHF.A.YTL-TP.DK.CHF.S.YTL-TP.DK.JPY.A.YTL-TP.DK.JPY.S.YTL-TP.DK.CAD.A.YTL-TP.DK.CAD.S.YTL-TP.DK.AUD.A.YTL-TP.DK.AUD.S.YTL-TP.DK.DKK.A.YTL-TP.DK.DKK.S.YTL-TP.DK.SEK.A.YTL-TP.DK.SEK.S.YTL-TP.DK.NOK.A.YTL-TP.DK.NOK.S.YTL-TP.DK.SAR.A.YTL-TP.DK.SAR.S.YTL-TP.DK.KWD.A.YTL-TP.DK.KWD.S.YTL-TP.DK.BGN.A.YTL-TP.DK.BGN.S.YTL-TP.DK.RON.A.YTL-TP.DK.RON.S.YTL-TP.DK.RUB.A.YTL-TP.DK.RUB.S.YTL-TP.DK.IRR.A.YTL-TP.DK.IRR.S.YTL-TP.DK.CNY.A.YTL-TP.DK.CNY.S.YTL-TP.DK.PKR.A.YTL-TP.DK.PKR.S.YTL-TP.DK.QAR.A.YTL-TP.DK.QAR.S.YTL-TP.DK.XDR.A.YTL-TP.DK.XDR.S.YTL-TP.DK.XAU.A.YTL-TP.DK.XAU.S.YTL&startDate=01-01-2025&endDate=18-09-2025&type=json&key=Kkze5A46Sf
```

Query parameters:
- `series`: hyphen-separated EVDS series codes for currencies (A: Buying, S: Selling). Suffix `.YTL` yields TRY-based values.
- `startDate`, `endDate`: dd-MM-yyyy range. For latest only, you may pass the same date or fetch recent window and pick last row.
- `type`: `json` preferred.
- `key`: EVDS API key.

Notes:
- We parse the latest available row by date and map key currencies (USD, EUR, GBP, etc.) to our internal `Currency` model.
- We cache results to reduce API calls.
- Always prefer Selling (S) rate; fallback to Buying (A) if necessary.

### Optional CORS proxy for Web

On web builds, EVDS can respond without CORS headers. You can provide a proxy via a Dart define to bypass CORS:

```
flutter run -d chrome --dart-define=EVDS_PROXY_URL=https://your-proxy.example.com/?url={url}
```

Accepted template formats for `EVDS_PROXY_URL`:
- With placeholder: `https://proxy.example.com/?url={url}` or `...?q=%s`
- Without placeholder (auto-append): `https://proxy.example.com/` → final URL becomes `https://proxy.example.com/<encoded-evds-url>`
- With query: `https://proxy.example.com?token=ABC` → final URL becomes `...?token=ABC&url=<encoded-evds-url>`

If no proxy is provided, the app calls EVDS directly. On network/CORS errors, we return cached or TRY-only data, avoiding UI crashes.


