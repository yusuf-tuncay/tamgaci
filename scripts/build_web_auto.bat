@echo off
echo Building Flutter web app with automatic platform detection...

REM WebAssembly desteğini kontrol et
echo Checking WebAssembly support...

REM WebAssembly uyumlu build dene
flutter build web --release --wasm --no-tree-shake-icons 2>nul
if %errorlevel% equ 0 (
    echo WebAssembly build successful!
    copy web\index_wasm.html build\web\index.html
    echo Using WebAssembly-optimized version
) else (
    echo WebAssembly build failed, falling back to standard web build...
    flutter build web --release --no-tree-shake-icons
    copy web\index_standard.html build\web\index.html
    echo Using standard web version
)

echo Build completed!
echo Output: build\web\
echo Deploy with: firebase deploy --only hosting
