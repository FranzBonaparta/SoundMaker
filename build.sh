#!/bin/bash
# Create SoundMaker.love
set -e  # Stop on error

echo "🔧 Creating RSoundMaker.love..."
zip -9 -r ../SoundMaker.love . -x ".git*" "*.DS_Store" "*~" "tools/*"
cd ..

# Create Windows folder
echo "📁 Creating build directory..."
mkdir -p build/windows
echo "📦 Creating SoundMaker.exe..."
cat tools/love-11.5-win32/love.exe SoundMaker.love > build/windows/SoundMaker.exe
echo "📄 Copying DLLs and license..."
cp tools/love-11.5-win32/*.dll build/windows/
cp tools/love-11.5-win32/license.txt build/windows/
echo "✅ Build completed! Output: build/windows/SoundMaker.exe"