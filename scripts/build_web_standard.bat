@echo off
echo Building Flutter web app with standard web support...

REM Standart web build
flutter build web --release --no-tree-shake-icons

REM Standart index dosyasını kopyala
copy web\index_standard.html build\web\index.html

echo Standard web build completed!
echo Output: build\web\
echo Deploy with: firebase deploy --only hosting
