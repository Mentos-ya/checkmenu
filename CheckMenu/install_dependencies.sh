#!/bin/bash

echo "🚀 Установка зависимостей для CheckMenu..."

# Проверяем, установлен ли CocoaPods
if ! command -v pod &> /dev/null; then
    echo "❌ CocoaPods не установлен. Устанавливаем..."
    sudo gem install cocoapods
fi

# Переходим в директорию проекта
cd "$(dirname "$0")"

# Устанавливаем зависимости
echo "📦 Устанавливаем ML Kit..."
pod install

echo "✅ Зависимости установлены!"
echo "📝 Теперь откройте CheckMenu.xcworkspace вместо CheckMenu.xcodeproj"

