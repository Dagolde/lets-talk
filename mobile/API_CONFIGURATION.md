# API Configuration Guide

This document explains how to configure the API endpoints for different environments in the Let's Talk mobile app.

## Environment Configuration

The app supports multiple environments (development, staging, production) and automatically selects the appropriate API endpoints based on the build configuration.

### Current Configuration

The API configuration is managed in `lib/core/config/api_config.dart`:

```dart
static const Map<String, String> baseUrls = {
  'development': 'http://localhost:8000/api',
  'staging': 'https://staging-api.letstalk.com/api',
  'production': 'https://api.letstalk.com/api',
};
```

### Setting Environment

To set the environment when building the app, use the `--dart-define` flag:

#### Development (Default)
```bash
flutter run
# or
flutter build apk --dart-define=ENVIRONMENT=development
```

#### Staging
```bash
flutter run --dart-define=ENVIRONMENT=staging
# or
flutter build apk --dart-define=ENVIRONMENT=staging
```

#### Production
```bash
flutter run --dart-define=ENVIRONMENT=production
# or
flutter build apk --dart-define=ENVIRONMENT=production
```

## API Endpoints

The app makes the following API calls to your backend:

### Authentication Endpoints

#### Phone Verification (WhatsApp-like Flow)
- `POST /auth/send-phone-verification` - Send OTP to phone number
- `POST /auth/verify-otp` - Verify 6-digit OTP

#### Traditional Authentication
- `POST /auth/login` - Email/password login
- `POST /auth/register` - User registration
- `POST /auth/logout` - User logout

#### Two-Step Verification
- `POST /auth/send-two-step-code` - Send 4-digit PIN
- `POST /auth/verify-two-step-code` - Verify 4-digit PIN

#### Profile Management
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update user profile
- `POST /user/avatar` - Upload avatar
- `PUT /user/password` - Change password

#### Other Authentication
- `POST /auth/forgot-password` - Send password reset
- `POST /auth/verify-phone` - Verify phone number
- `POST /auth/resend-verification` - Resend verification code

### Chat Endpoints
- `GET /conversations` - Get conversations list
- `GET /conversations/{id}` - Get specific conversation
- `GET /conversations/{id}/messages` - Get messages
- `POST /conversations/{id}/messages` - Send message
- `POST /conversations` - Create conversation

### Payment Endpoints
- `GET /payments` - Get payments list
- `POST /payments` - Create payment
- `GET /payments/{id}` - Get payment details
- `POST /payments/qr` - Create QR payment
- `POST /qr-codes/scan` - Scan QR code

### Product Search Endpoints
- `POST /product-search` - Search products by image
- `GET /product-search/{id}` - Get search results
- `GET /product-search/history` - Get search history

### User Management Endpoints
- `GET /contacts` - Get contacts list
- `POST /contacts` - Add contact
- `DELETE /contacts/{id}` - Remove contact
- `GET /users/search` - Search users

### File Upload Endpoints
- `POST /upload` - Upload files

## Request/Response Format

### Authentication Request Format

#### Login
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Register
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "phone": "+1234567890"
}
```

#### Phone Verification
```json
{
  "phone": "+1234567890",
  "name": "John Doe"
}
```

#### OTP Verification
```json
{
  "phone": "+1234567890",
  "name": "John Doe",
  "otp": "123456"
}
```

### Authentication Response Format

#### Successful Login/Register/OTP Verification
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "avatar": "https://example.com/avatar.jpg",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

#### Error Response
```json
{
  "message": "Invalid credentials",
  "errors": {
    "email": ["The email field is required"],
    "password": ["The password field is required"]
  }
}
```

## Headers

All API requests include the following headers:

- `Content-Type: application/json`
- `Accept: application/json`
- `Authorization: Bearer {token}` (for authenticated requests)

## Error Handling

The app handles the following HTTP status codes:

- `401` - Unauthorized (redirects to login)
- `403` - Access forbidden
- `404` - Resource not found
- `422` - Validation error
- `500` - Server error
- `502/503/504` - Service unavailable

## Timeout Configuration

- **Connect Timeout**: 30 seconds
- **Receive Timeout**: 30 seconds
- **Send Timeout**: 30 seconds

## Development Setup

1. **Update API URLs**: Modify `lib/core/config/api_config.dart` with your backend URLs
2. **Set Environment**: Use the appropriate `--dart-define` flag when running/building
3. **Test Endpoints**: Ensure your backend implements all required endpoints
4. **Handle CORS**: If testing on web, ensure your backend allows CORS requests

## Production Deployment

1. **Set Production Environment**: Use `--dart-define=ENVIRONMENT=production`
2. **Update Production URL**: Ensure the production URL in `api_config.dart` is correct
3. **SSL Certificate**: Ensure your production API uses HTTPS
4. **Rate Limiting**: Implement appropriate rate limiting on your backend
5. **Monitoring**: Set up API monitoring and logging

## Troubleshooting

### Common Issues

1. **Connection Refused**: Check if your backend server is running
2. **CORS Errors**: Ensure your backend allows requests from the app
3. **Authentication Errors**: Verify token format and expiration
4. **Timeout Errors**: Check network connectivity and server response times

### Debug Information

To get current API configuration:
```dart
final config = ApiService.getApiConfig();
print(config);
```

This will output the current base URL, environment, and timeout settings.
