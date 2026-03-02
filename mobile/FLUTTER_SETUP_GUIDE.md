# Flutter Mobile App Setup Guide

This guide will help you set up and run the Let's Talk Flutter mobile app that connects to your Laravel backend.

## Prerequisites

1. **Flutter SDK** (version 3.0.0 or higher)
2. **Dart SDK** (version 3.0.0 or higher)
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Android Emulator** or **Physical Device**
5. **iOS Simulator** (for macOS users)
6. **Backend Server** running on `http://127.0.0.1:8000`

## Quick Setup

### 1. Install Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Test API Connection

```bash
dart test_api_connection.dart
```

This will test if your Flutter app can connect to the backend API.

### 3. Run the App

```bash
flutter run
```

## Configuration

### API Configuration

The app is configured to connect to your backend at `http://127.0.0.1:8000/api`. 

**For different environments:**

- **Development**: `http://127.0.0.1:8000/api` (default)
- **Staging**: `https://staging-api.letstalk.com/api`
- **Production**: `https://api.letstalk.com/api`

To change the environment, use:
```bash
flutter run --dart-define=ENVIRONMENT=production
```

### Payment Gateway Configuration

The app supports multiple payment gateways:

- **Stripe**: Credit card payments
- **Paystack**: African payment gateway
- **Flutterwave**: African payment gateway
- **Internal**: In-app wallet transfers

All payment gateways are enabled by default and can be configured through the admin dashboard.

## Features

### ✅ Implemented Features

1. **Authentication**
   - Phone verification (WhatsApp-like flow)
   - Email/password login
   - Two-step verification
   - Session management

2. **Chat System**
   - Direct and group chats
   - Text, image, video, audio, file messages
   - Location sharing
   - Contact sharing
   - Message reactions
   - Read receipts

3. **Payment System**
   - Multiple payment gateways
   - QR code payments
   - Payment requests
   - Transaction history
   - Wallet management

4. **QR Code Features**
   - Generate QR codes for profile, payment, contact
   - Scan QR codes
   - QR code management

5. **Product Search**
   - AI-powered text search
   - Image-based search
   - Search history
   - Product recommendations

6. **Contact Management**
   - Contact list
   - Contact sync
   - Favorite contacts
   - Contact sharing

7. **Notifications**
   - Push notifications
   - In-app notifications
   - Notification preferences

### 🔄 Real-time Features

- **WebSocket Integration**: Real-time messaging
- **Push Notifications**: Firebase integration
- **Live Updates**: Dashboard and chat updates

## Project Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   └── api_config.dart          # API configuration
│   │   ├── models/                      # Data models
│   │   │   ├── user.dart
│   │   │   ├── chat.dart
│   │   │   ├── message.dart
│   │   │   ├── payment.dart
│   │   │   ├── contact.dart
│   │   │   ├── qr_code.dart
│   │   │   ├── product_search.dart
│   │   │   ├── notification.dart
│   │   │   └── api_response.dart
│   │   └── services/
│   │       └── api_service.dart         # API communication
│   ├── features/                        # Feature modules
│   │   ├── auth/                        # Authentication
│   │   ├── chat/                        # Chat functionality
│   │   ├── payment/                     # Payment system
│   │   ├── qr_code/                     # QR code features
│   │   ├── product_search/              # Product search
│   │   ├── contacts/                    # Contact management
│   │   └── notifications/               # Notifications
│   ├── shared/                          # Shared components
│   │   ├── widgets/                     # Reusable widgets
│   │   ├── utils/                       # Utility functions
│   │   └── constants/                   # App constants
│   └── main.dart                        # App entry point
├── assets/                              # App assets
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── sounds/
├── android/                             # Android configuration
├── ios/                                 # iOS configuration
└── pubspec.yaml                         # Dependencies
```

## API Integration

### Authentication Flow

1. **Phone Verification** (WhatsApp-like)
   ```dart
   // Send verification code
   await apiService.sendPhoneVerification(phone, name);
   
   // Verify code and register
   await apiService.verifyPhoneAndRegister(phone, name, otp);
   ```

2. **Traditional Login**
   ```dart
   // Login with email/password
   final response = await apiService.login(email, password);
   if (response.success) {
     // Navigate to main app
   }
   ```

### Chat Integration

```dart
// Get user's chats
final chats = await apiService.getChats();

// Send a message
await apiService.sendMessage(chatId, content, 'text');

// Get chat messages
final messages = await apiService.getMessages(chatId);
```

### Payment Integration

```dart
// Create a payment
final payment = await apiService.createPayment(
  recipientId, 
  amount, 
  'USD', 
  'stripe', 
  'send'
);

// Initialize payment gateway
final gatewayData = await apiService.initializePayment(
  'stripe', 
  amount, 
  'USD'
);
```

## Testing

### Run Tests

```bash
flutter test
```

### Test API Connection

```bash
dart test_api_connection.dart
```

### Test on Different Devices

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Ensure backend server is running on `http://127.0.0.1:8000`
   - Check if API routes are accessible
   - Verify CORS settings in backend

2. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart versions
   - Update dependencies if needed

3. **Payment Gateway Issues**
   - Verify payment gateway credentials in admin panel
   - Check if payment gateways are enabled
   - Test with sandbox credentials first

4. **Real-time Features Not Working**
   - Check WebSocket connection
   - Verify Firebase configuration
   - Check notification permissions

### Debug Mode

Enable debug logging:
```dart
// In api_config.dart
static const bool enableLogging = true;
```

## Deployment

### Android

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Archive and upload to App Store

### Environment Configuration

For production deployment:

1. **Update API URLs**
   ```dart
   // In api_config.dart
   'production': 'https://api.letstalk.com/api',
   ```

2. **Configure Payment Gateways**
   - Use production credentials
   - Enable SSL/TLS
   - Configure webhooks

3. **Set up Firebase**
   - Configure production Firebase project
   - Update `google-services.json` and `GoogleService-Info.plist`

## Next Steps

1. **Test all features** on different devices
2. **Configure payment gateways** in admin panel
3. **Set up Firebase** for push notifications
4. **Deploy to app stores**
5. **Monitor and maintain** the application

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review the API documentation
3. Check the backend logs
4. Test API endpoints manually

## Contributing

1. Follow Flutter best practices
2. Write tests for new features
3. Update documentation
4. Test on multiple devices

---

**Happy Coding! 🚀**
