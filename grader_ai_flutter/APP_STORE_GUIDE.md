# 🍎 App Store Submission Guide

## 📋 **Pre-Submission Checklist**

### ✅ **App Information**
- **App Name**: Grader
- **Bundle ID**: `cloud.grader.app`
- **Version**: 1.3.0 (Build 4)
- **Category**: Education
- **Age Rating**: 4+ (No objectionable content)

### ✅ **Required Assets**
- **App Icon**: 1024x1024px (required)
- **Screenshots**: iPhone 6.7", iPhone 6.5", iPad Pro 12.9"
- **App Preview**: Optional but recommended

### ✅ **App Store Connect Setup**

1. **Create App Record**
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Click "My Apps" → "+" → "New App"
   - Fill in app information:
     - Name: Grader
     - Primary Language: English
     - Bundle ID: cloud.grader.app
     - SKU: grader-ios-2024

2. **App Information**
   - **Description**: 
     ```
     Master IELTS Speaking with AI-powered feedback. Practice with real exam topics, get instant band scores, and improve your English speaking skills with personalized insights.
     ```
   - **Keywords**: IELTS, English, Speaking, Practice, AI, Education, Language Learning
   - **Support URL**: https://t.me/doniponi
   - **Marketing URL**: https://t.me/doniponi

3. **Pricing**
   - Free app with in-app purchases
   - Subscription plans: Monthly, Yearly, Lifetime

### ✅ **Build Submission**

1. **Archive in Xcode**
   ```bash
   # Run build script
   ./scripts/build_for_appstore.sh
   
   # Open Xcode
   open ios/Runner.xcworkspace
   ```

2. **Xcode Steps**
   - Select "Any iOS Device" as target
   - Product → Archive
   - Wait for archive to complete
   - Click "Distribute App"
   - Select "App Store Connect"
   - Upload

3. **App Store Connect**
   - Go to your app in App Store Connect
   - Click "TestFlight" tab
   - Wait for processing (5-10 minutes)
   - Go to "App Store" tab
   - Select build and submit for review

### ✅ **Review Information**

**Contact Information**
- **First Name**: [Your First Name]
- **Last Name**: [Your Last Name]
- **Phone Number**: [Your Phone]
- **Email**: [Your Email]

**Demo Account** (if required)
- Username: demo@grader.app
- Password: demo123

**Notes for Review**
```
This app provides IELTS Speaking practice with AI feedback. 
Users can practice with real exam topics and receive instant band scores.
The app includes subscription features for unlimited practice sessions.
All audio processing is done securely and user data is protected.
```

### ✅ **Privacy Policy & Terms**

- **Privacy Policy**: Available at `/LEGAL/PRIVACY_POLICY.md`
- **Terms of Service**: Available at `/LEGAL/TERMS_OF_SERVICE.md`
- **Data Collection**: Audio recordings for analysis, user progress data
- **Third-party Services**: Firebase (authentication, storage), OpenAI (speech analysis)

### ✅ **App Store Review Guidelines**

**Compliance Checklist**
- ✅ No objectionable content
- ✅ Proper age rating (4+)
- ✅ Clear app description
- ✅ Working app functionality
- ✅ Proper privacy policy
- ✅ Subscription terms clearly stated
- ✅ No misleading claims
- ✅ Proper app categorization

### 🚨 **Common Issues & Solutions**

1. **Build Upload Fails**
   - Check Bundle ID matches App Store Connect
   - Verify signing certificates
   - Ensure version number is higher than previous

2. **Review Rejection**
   - Check email for specific reasons
   - Address all reviewer feedback
   - Resubmit with fixes

3. **Metadata Issues**
   - Ensure all required fields are filled
   - Check screenshot requirements
   - Verify app icon format

### 📞 **Support**

For technical issues:
- Telegram: @doniponi
- Email: [Your Email]

---

## 🎯 **Quick Start Commands**

```bash
# Build for App Store
./scripts/build_for_appstore.sh

# Open Xcode
open ios/Runner.xcworkspace

# Check build status
flutter doctor
```

**Good luck with your App Store submission! 🚀**
