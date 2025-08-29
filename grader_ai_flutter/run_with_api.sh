#!/bin/bash

# Скрипт для запуска Flutter с API ключами
echo "🚀 Запуск Grader.AI с API ключами..."

# Проверяем наличие env.dev файла
if [ ! -f "env.dev" ]; then
    echo "❌ Файл env.dev не найден!"
    echo "Создайте файл env.dev с вашими API ключами"
    exit 1
fi

# Загружаем переменные из env.dev
export $(cat env.dev | grep -v '^#' | xargs)

# Проверяем OpenAI API ключ
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ OPENAI_API_KEY не найден в env.dev"
    exit 1
fi

echo "✅ OpenAI API ключ загружен: ${OPENAI_API_KEY:0:8}..."

# Запускаем Flutter с переменными окружения
echo "🎯 Запуск Flutter приложения..."
flutter run --dart-define=OPENAI_API_KEY="$OPENAI_API_KEY" \
           --dart-define=GOOGLE_CLOUD_PROJECT_ID="$GOOGLE_CLOUD_PROJECT_ID" \
           --dart-define=BACKEND_API_URL="$BACKEND_API_URL"
