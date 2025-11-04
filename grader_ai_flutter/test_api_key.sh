#!/bin/bash

# Тест API ключа
KEY="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"

echo "🔍 Тестируем API ключ..."

curl -i https://api.openai.com/v1/models \
  -H "Authorization: Bearer $KEY" \
  2>&1 | head -20

echo ""
echo "---"
echo "Если увидишь 200 OK — ключ работает!"
echo "Если увидишь 401/403 — ключ не работает извне"
