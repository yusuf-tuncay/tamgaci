@echo off
echo Building Flutter web app with WebAssembly support...

REM WebAssembly uyumlu build
flutter build web --release --wasm --no-tree-shake-icons

REM WebAssembly index dosyasını kopyala
copy web\index_wasm.html build\web\index.html

echo WebAssembly build completed!
echo Output: build\web\
echo Deploy with: firebase deploy --only hosting
