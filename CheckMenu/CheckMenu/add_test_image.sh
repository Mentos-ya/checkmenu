#!/bin/bash

# Скрипт для добавления тестового изображения в симулятор iOS

echo "Создаем тестовое изображение с текстом..."

# Создаем простое изображение с текстом используя sips (встроенная утилита macOS)
sips -s format png -s dpiHeight 72 -s dpiWidth 72 -z 800 600 /System/Library/Desktop\ Pictures/Solid\ Colors/Solid\ Gray\ Pro\ Ultra\ Dark.png --out test_menu.png

echo "Изображение создано: test_menu.png"
echo "Теперь перетащите это изображение в симулятор iOS в приложение Фото"
echo "Или используйте команду: xcrun simctl addmedia booted test_menu.png"
