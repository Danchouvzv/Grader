# Документация Grader

## Юридические страницы

### Публикация на GitHub Pages

1. Создай ветку `gh-pages`:
   ```bash
   git checkout -b gh-pages
   git push origin gh-pages
   ```

2. В настройках репозитория включи GitHub Pages:
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: gh-pages

3. Страницы будут доступны по адресу:
   - Privacy: `https://[username].github.io/[repo]/docs/privacy.html`
   - Terms: `https://[username].github.io/[repo]/docs/terms.html`

### Альтернативный хостинг

Если используешь другой хостинг:

1. Скопируй файлы в корень сайта
2. Обнови ссылки в `appstore/metadata.json`
3. Убедись, что доступны по указанным URL

### Обновление

При изменении условий:
1. Обнови файлы в `docs/`
2. Измени дату "Last updated"
3. Уведоми пользователей через приложение

## Структура

```
docs/
├── README.md          # Этот файл
├── privacy.md         # Политика конфиденциальности
└── terms.md           # Условия использования
```
