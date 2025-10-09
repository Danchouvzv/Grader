# Stripe Integration - Production Ready Setup

## 🎯 Что было исправлено

### ❌ Проблемы старого кода:
- Неправильный пакет (`stripe_flutter` вместо `flutter_stripe`)
- Ключи в коде вместо конфигурации
- PaymentIntent создавался на клиенте (небезопасно!)
- Моки вместо реальных API вызовов
- Отсутствие обработки ошибок
- Нет локализации валют

### ✅ Новый production-ready код:

## 📁 Структура файлов

```
lib/
├── core/
│   ├── config/
│   │   └── stripe_config.dart          # Конфигурация Stripe
│   ├── models/
│   │   └── stripe_models.dart          # Модели данных
│   └── services/
│       ├── stripe_service.dart         # Основной сервис
│       └── stripe_api_client.dart     # HTTP клиент для backend
└── presentation/
    └── pages/
        └── subscription_page.dart      # UI экрана подписки
```

## 🔧 Настройка

### 1. Конфигурация Stripe

В `lib/core/config/stripe_config.dart`:

```dart
class StripeConfig {
  // TODO: Замените на ваши реальные ключи
  static const String publishableKey = 'pk_test_your_publishable_key_here';
  static const String merchantId = 'your_merchant_id_here';
  static const String merchantDisplayName = 'Grader.AI';
  static const String apiBaseUrl = 'https://your-backend-api.com/api';
  static const int apiTimeoutMs = 30000;
}
```

### 2. Backend API Endpoints

Ваш backend должен предоставлять следующие endpoints:

#### POST `/api/stripe/create-payment-intent`
```json
{
  "amount": 999,
  "currency": "usd",
  "customer_id": "cus_xxx",
  "metadata": {}
}
```

#### POST `/api/stripe/create-subscription`
```json
{
  "price_id": "price_xxx",
  "customer_id": "cus_xxx",
  "metadata": {}
}
```

#### GET `/api/stripe/subscription-plans`
```json
{
  "plans": [
    {
      "id": "price_monthly",
      "name": "Monthly Premium",
      "price": 999,
      "currency": "usd",
      "interval": "month",
      "features": ["Feature 1", "Feature 2"],
      "is_popular": false,
      "original_price": null
    }
  ]
}
```

#### POST `/api/stripe/create-customer`
```json
{
  "email": "user@example.com",
  "name": "User Name",
  "metadata": {}
}
```

#### GET `/api/stripe/customer-subscriptions/{customerId}`
#### POST `/api/stripe/cancel-subscription/{subscriptionId}`

## 🛡️ Безопасность

### ✅ Что правильно:
- **Publishable key** только на клиенте
- **Secret key** только на backend
- **PaymentIntent** создается на backend
- **Customer** создается на backend
- **Subscription** создается на backend

### ❌ Что НЕ делать:
- Никогда не храните secret key на клиенте
- Не создавайте PaymentIntent на клиенте
- Не передавайте sensitive данные через клиент

## 🎨 UI/UX

### Экран подписки:
- ✅ Загружает планы с backend
- ✅ Показывает loading состояния
- ✅ Обрабатывает ошибки
- ✅ Красивый дизайн с градиентами
- ✅ "MOST POPULAR" метки
- ✅ Скидки и оригинальные цены

### Обработка ошибок:
- ✅ `StripePaymentCanceledException` - пользователь отменил
- ✅ `StripeServiceException` - общие ошибки
- ✅ `StripeInitializationException` - проблемы инициализации

## 💰 Локализация валют

```dart
// Правильная локализация
StripeService.formatAmount(999, 'usd', locale: 'en_US') // $9.99
StripeService.formatAmount(999, 'eur', locale: 'de_DE') // 9,99 €
StripeService.formatAmount(999, 'gbp', locale: 'en_GB') // £9.99
```

## 🚀 Использование

### Инициализация:
```dart
// В main.dart
await StripeService.initialize();
StripeService().initializeApiClient();
```

### Создание подписки:
```dart
final stripeService = StripeService();

// Создать клиента
final customer = await stripeService.createCustomer(
  email: 'user@example.com',
  name: 'User Name',
);

// Создать подписку
final subscription = await stripeService.createSubscription(
  priceId: 'price_monthly',
  customerId: customer.id,
);

// Показать платежный экран
await stripeService.presentPaymentSheet(
  paymentIntentClientSecret: subscription['client_secret'],
  customerId: customer.id,
);
```

## 📱 Поддержка платформ

- ✅ **iOS**: Apple Pay через Stripe
- ✅ **Android**: Google Pay через Stripe
- ✅ **Web**: Card payments
- ✅ **macOS**: Card payments

## 🔍 Валидация

```dart
// Валидация email
StripeService.isValidEmail('user@example.com') // true

// Валидация карты
StripeService.isValidCardNumber('4242424242424242') // true

// Валидация CVC
StripeService.isValidCVC('123') // true

// Валидация даты
StripeService.isValidExpiryDate('12/25') // true
```

## 🎯 Следующие шаги

1. **Настройте backend** с указанными endpoints
2. **Замените ключи** в `StripeConfig`
3. **Создайте продукты** в Stripe Dashboard
4. **Настройте webhooks** для обработки событий
5. **Интегрируйте с аутентификацией** пользователей
6. **Добавьте тесты** для критических путей

## 🐛 Отладка

### Логи в debug режиме:
- HTTP запросы/ответы
- Stripe API вызовы
- Ошибки и исключения

### Проверка:
```dart
// Проверить инициализацию
try {
  await StripeService.initialize();
  print('Stripe initialized successfully');
} catch (e) {
  print('Stripe initialization failed: $e');
}
```

Теперь у вас есть **production-ready** Stripe интеграция! 🚀
