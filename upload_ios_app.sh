#!/bin/bash
set -e

# ================= НАСТРОЙКИ =================
PROJECT_DIR="$(pwd)"
IPA_PATH="$PROJECT_DIR/app.ipa"
API_KEY_JSON="$PROJECT_DIR/api_key.json"
BUNDLE_ID="com.sergey930501.myitfapp"
# =============================================

# Проверка Cordova
if ! command -v cordova &> /dev/null
then
    echo "❌ Cordova не установлен. Установи: npm install -g cordova"
    exit 1
fi

# Сборка Cordova iOS проекта
echo "⚡ Сборка iOS проекта..."
cordova platform rm ios || true
cordova platform add ios
cordova build ios --release --device

# Находим .ipa
IPA_FILE=$(find platforms/ios/build/device -name "*.ipa" | head -n 1)
if [ -z "$IPA_FILE" ]; then
    echo "❌ .ipa файл не найден после сборки!"
    exit 1
fi
echo "✅ .ipa найден: $IPA_FILE"
cp "$IPA_FILE" "$IPA_PATH"

# Проверка Fastlane
if ! command -v fastlane &> /dev/null
then
    echo "❌ Fastlane не установлен. Установи: sudo gem install fastlane"
    exit 1
fi

# Загрузка на TestFlight через Fastlane API Key
echo "🚀 Загружаем $IPA_PATH на TestFlight..."
fastlane deliver \
  --ipa "$IPA_PATH" \
  --api_key_path "$API_KEY_JSON" \
  --skip_screenshots \
  --skip_metadata \
  --force

echo "🎉 Загрузка завершена! Проверь TestFlight."
