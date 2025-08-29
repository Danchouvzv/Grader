# Fastlane для Grader iOS

## Установка

```bash
cd ios
bundle install
```

## Доступные команды

### `fastlane doctor`
Проверка окружения (Ruby, Xcode, CocoaPods, Flutter)

### `fastlane build`
Сборка .ipa файла

### `fastlane beta`
Сборка и загрузка в TestFlight

## Переменные окружения

Скопируй `env.default` в `.env` и заполни:

- `BUNDLE_ID` - идентификатор приложения
- `TEAM_ID` - Apple Developer Team ID
- `ASC_API_KEY_*` - App Store Connect API Key

## Первый запуск

1. Настрой подпись в Xcode (Team + Automatic signing)
2. Запусти `fastlane doctor` для проверки
3. Запусти `fastlane beta` для загрузки в TestFlight
