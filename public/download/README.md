# TAMGACI Windows Downloads

Bu klasör GitHub Actions tarafından otomatik olarak güncellenir.

## Dosyalar

- `tamgaci-setup-latest.exe` - En güncel sürüm (her zaman en son build)
- `tamgaci-setup-{version}.exe` - Versiyonlu sürümler
- `release.json` - Sürüm bilgileri

## Otomatik Güncelleme

Her `main` branch'e push'ta:
1. Flutter Windows app build edilir
2. pubspec.yaml'dan versiyon okunur
3. `tamgaci-setup-{version}.exe` oluşturulur
4. `tamgaci-setup-latest.exe` güncellenir
5. `release.json` oluşturulur
6. Firebase Hosting'e deploy edilir

## İndirme Linkleri

- **En Güncel:** https://www.tamgaci.online/download/tamgaci-setup-latest.exe
- **Sürüm Bilgisi:** https://www.tamgaci.online/download/release.json
