# Чеклист для исправления 2.3.3 Accurate Metadata

## ❌ Что НЕ должно быть в описании/скриншотах:

1. **Career Guidance / RIASEC тест** - этой функции НЕТ в приложении
2. **Автоматические In-App Purchases** - покупки не работают автоматически, только через запрос
3. **Цены подписок** ($9.99, $79.99, $199.99) - таких планов нет
4. **"Buy now" или "Subscribe now"** - только "Contact Support"

## ✅ Что ДОЛЖНО быть в описании:

### Правильное описание для App Store Connect:

**Короткое описание (30 символов):**
```
IELTS Speaking AI Coach
```

**Полное описание:**
```
Practice IELTS Speaking with AI-powered feedback. Record your responses to real exam questions, get instant band scores (0-9) across 4 criteria, and receive personalized improvement tips.

Features:
• IELTS Speaking practice (Parts 1-3)
• AI-powered speech analysis and scoring
• Detailed feedback on fluency, vocabulary, grammar, and pronunciation
• 60-second timer for Part 2 practice
• Progress tracking and analytics
• Achievement system
• Personalized learning insights

Free version includes limited practice sessions. Premium features (unlimited sessions, advanced analytics) available by request through support.

Contact support@grader.ai for Premium subscription inquiries.
```

### Release Notes (What's New):
```
• IELTS Speaking practice with automatic scoring on 4 criteria
• 60-second timer for Part 2 Speaking
• AI-powered speech analysis and detailed feedback
• Personalized development recommendations
• Progress tracking and performance analytics
• Mobile-friendly learning interface
```

## 📸 Скриншоты - что проверить:

1. **НЕТ скриншотов с Career Guidance**
2. **НЕТ скриншотов с кнопками покупки/подписки**
3. **ЕСТЬ скриншоты:**
   - IELTS Speaking экран
   - Результаты с оценками
   - Профиль с прогрессом
   - Экран подписки с диалогом "Contact Support"

## 🔍 Что проверить в App Store Connect:

1. **App Description** - нет упоминаний Career Guidance?
2. **Screenshots** - не показывают несуществующие функции?
3. **Keywords** - соответствуют реальному функционалу?
4. **Promotional Text** - не обещает автоматические покупки?
5. **App Preview Video** - показывает только реальные функции?

## ✅ Исправления уже сделаны:

- ✅ `appstore/testflight/what-to-test.md` - убрана Career Guidance
- ✅ `appstore/metadata.json` - корректные метаданные
- ✅ `appstore/release-notes/en-US.txt` - только реальные функции
- ✅ `appstore/release-notes/ru-RU.txt` - только реальные функции

## 🎯 Что нужно сделать в App Store Connect:

1. Открой App Store Connect → Your App → App Information
2. Проверь **App Description** - убедись, что там нет:
   - Career Guidance
   - Автоматических покупок
   - Конкретных цен
3. Проверь **Screenshots** - убедись, что они показывают только:
   - IELTS Speaking экраны
   - Результаты
   - Профиль
4. Проверь **Promotional Text** (если есть) - должен соответствовать реальности

## 📝 Пример правильного описания для App Store:

```
🎤 IELTS Speaking Practice with AI Feedback

Master IELTS Speaking with personalized AI coaching. Practice real exam questions, get instant band scores, and improve your English speaking skills.

KEY FEATURES:
✅ IELTS Speaking practice (Parts 1-3)
✅ AI-powered scoring on 4 criteria
✅ Detailed feedback and improvement tips
✅ Progress tracking and analytics
✅ Achievement system

FREE: Limited practice sessions
PREMIUM: Unlimited sessions (available by request via support@grader.ai)
```

---

**Важно:** Все описания должны точно соответствовать тому, что пользователь видит в приложении!

