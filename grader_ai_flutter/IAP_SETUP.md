# In-App Purchase Setup Guide

## Overview
This app uses native In-App Purchases (IAP) through Google Play Billing and Apple StoreKit for subscription management.

## Current Status
✅ IAP SDK integrated (`in_app_purchase: ^3.1.11`)
✅ IAP Service implemented with purchase flow
✅ Subscription UI ready
⚠️ Products need to be configured in store consoles

## Product IDs
The app expects the following subscription products:

1. **Monthly Premium** - `monthly_premium`
   - Duration: 1 month
   - Suggested Price: $9.99

2. **Yearly Premium** - `yearly_premium` 
   - Duration: 1 year
   - Suggested Price: $79.99
   - Tagged as "Most Popular"

3. **Lifetime Premium** - `lifetime_premium`
   - Duration: Lifetime (non-renewing)
   - Suggested Price: $199.99

## Setup Instructions

### For iOS (App Store Connect)

1. **Create App in App Store Connect**
   - Go to https://appstoreconnect.apple.com
   - My Apps → + → New App

2. **Enable In-App Purchases**
   - Select your app → Features → In-App Purchases
   - Click + to create new product

3. **Create Subscriptions**
   For each product:
   - Type: Auto-Renewable Subscription
   - Reference Name: Monthly/Yearly/Lifetime Premium
   - Product ID: `monthly_premium` / `yearly_premium` / `lifetime_premium`
   - Subscription Group: Create "Premium Membership"
   - Subscription Duration: 1 Month / 1 Year / Lifetime
   - Price: Set appropriate tier

4. **Testing**
   - Create Sandbox Tester in App Store Connect → Users and Access → Sandbox Testers
   - Sign out of real Apple ID on device
   - Install app and test purchase

### For Android (Google Play Console)

1. **Create App in Google Play Console**
   - Go to https://play.google.com/console
   - All apps → Create app

2. **Enable In-App Products**
   - Monetization → Products → Subscriptions
   - Create subscription

3. **Create Subscription Products**
   For each product:
   - Product ID: `monthly_premium` / `yearly_premium` / `lifetime_premium`
   - Name: Monthly/Yearly/Lifetime Premium
   - Description: Unlock all premium features
   - Billing period: 1 month / 1 year / Lifetime
   - Price: Set appropriate price

4. **Testing**
   - Add test account in Google Play Console → Settings → License testing
   - Install app from internal testing track
   - Test purchase

## Premium Features
When user has active subscription, they get:
- ✅ Unlimited IELTS Speaking Practice
- ✅ Advanced AI Feedback
- ✅ Detailed Performance Analytics
- ✅ Personalized Study Plans
- ✅ Priority Support
- ✅ Exclusive Content Access (Yearly/Lifetime)
- ✅ Offline Mode (Yearly/Lifetime)
- ✅ All Future Updates (Lifetime)
- ✅ Premium Badge (Lifetime)

## Development Notes

### Current Behavior
- On **web**: IAP shows "Not available" message (as expected)
- On **iOS/Android without products**: Shows "Products not available" message
- On **iOS/Android with products configured**: Full purchase flow works

### Code Structure
```
lib/core/services/iap_service.dart          # IAP business logic
lib/presentation/pages/subscription_page.dart  # Subscription UI
lib/main.dart                               # IAP initialization
```

### Testing Checklist
- [ ] Products created in App Store Connect
- [ ] Products created in Google Play Console  
- [ ] Sandbox/Test accounts configured
- [ ] Purchase flow tested on iOS
- [ ] Purchase flow tested on Android
- [ ] Restore purchases tested
- [ ] Subscription cancellation tested
- [ ] Receipt validation implemented (backend)

## Next Steps for Production

1. **Backend Integration** (Optional but Recommended)
   - Implement receipt validation server
   - Store subscription status in your database
   - Sync premium status across devices

2. **Analytics**
   - Track subscription events
   - Monitor conversion rates
   - A/B test pricing

3. **Customer Support**
   - Handle refund requests
   - Subscription management portal
   - FAQ section

## Troubleshooting

### "Products not found"
- Ensure products are created in store console
- Wait 2-24 hours after creating products
- Check product IDs match exactly
- Ensure app bundle ID matches
- For iOS: Ensure Paid Applications agreement signed

### "Purchase failed"
- Check internet connection
- Verify test account is signed in
- Ensure app is signed correctly
- Check sandbox environment is active

### "IAP not available"
- This is expected on web platform
- Check device supports IAP
- Verify in_app_purchase permissions

## Support
For IAP issues, check:
- Apple: https://developer.apple.com/in-app-purchase/
- Google: https://developer.android.com/google/play/billing
- Flutter Plugin: https://pub.dev/packages/in_app_purchase

