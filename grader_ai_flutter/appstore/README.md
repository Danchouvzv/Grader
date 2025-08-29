# App Store Metadata для Grader

## Структура каталога

```
appstore/
├── README.md                    # Этот файл
├── metadata.json               # Основные метаданные
├── release-notes/              # Заметки о релизах
│   ├── en-US.txt              # Английская версия
│   └── ru-RU.txt              # Русская версия
└── testflight/                 # Материалы для TestFlight
    ├── what-to-test.md         # Что тестировать
    └── beta-review-notes.md    # Заметки для Beta Review
```

## Обновление релизов

### 1. Версионирование
- Обнови `CFBundleShortVersionString` в `ios/Runner/Info.plist`
- Обнови `version` в `pubspec.yaml`
- Создай тег `vX.Y.Z`

### 2. Release Notes
Обнови оба файла:
- `release-notes/ru-RU.txt` - основная версия
- `release-notes/en-US.txt` - краткая английская версия

### 3. TestFlight
- Обнови `what-to-test.md` если добавились новые функции
- Проверь `beta-review-notes.md` на актуальность

## App Store Connect

### Скриншоты
Размеры для iPhone:
- 6.7" Display: 1290 x 2796 px
- 6.5" Display: 1242 x 2688 px
- 5.5" Display: 1242 x 2208 px

### Описание
Используй `metadata.json` как основу для:
- App Store description
- Keywords
- Support URL
- Privacy Policy URL

## Локализация

Основные языки:
- **en-US** (English) - обязательный
- **ru-RU** (Russian) - для русскоязычных пользователей

## Контакты

- Support: support@grader.ai
- Privacy: https://grader.ai/privacy
- Terms: https://grader.ai/terms
