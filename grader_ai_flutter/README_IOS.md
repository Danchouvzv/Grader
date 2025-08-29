# iOS Release Setup для Grader

## Настройка в Xcode

1. Открой `ios/Runner.xcworkspace` в Xcode
2. Выбери проект `Runner` в навигаторе
3. В разделе `Signing & Capabilities`:
   - Team: выбери свой Apple Developer Team
   - Bundle Identifier: `com.graderai.app`
   - Включи "Automatically manage signing"

## Первая сборка

1. Выбери схему `Runner` → `Any iOS Device (arm64)`
2. Product → Archive
3. Убедись, что сборка проходит без ошибок

## Версионирование

- Version: `1.0.0` (CFBundleShortVersionString)
- Build: `1` (CFBundleVersion)

## Тестирование

После успешной сборки можно использовать fastlane для автоматизации:

```bash
./scripts/ios.sh beta
```

## Примечания

- Не редактируй `.pbxproj` вручную
- Все настройки подписи через Xcode UI
- Для TestFlight используй App Store Connect API Key
