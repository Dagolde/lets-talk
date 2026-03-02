# Let's Talk - WeChat-like Chat System

A comprehensive chat application with payment integration, QR code functionality, and AI-powered product search.

## Features

### Core Chat Features
- Real-time messaging with WebSocket support
- Group chats and private conversations
- File sharing (images, videos, documents)
- Voice messages and video calls
- Message encryption and security

### Payment System
- In-app payment processing
- QR code payment scanning
- Payment history and receipts
- Multiple payment methods integration
- Secure transaction handling

### AI-Powered Product Search
- Camera-based product recognition
- Online product search and comparison
- Price tracking and alerts
- Shopping recommendations
- Integration with e-commerce platforms

### QR Code Features
- User profile QR codes for easy connection
- Payment QR codes for transactions
- Group invitation QR codes
- Business card sharing

## Project Structure

```
lets-talk/
├── backend/                 # Laravel API Backend
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── config/
├── mobile/                  # Flutter Mobile App
│   ├── lib/
│   ├── assets/
│   └── pubspec.yaml
├── admin/                   # Laravel Admin Panel
│   ├── app/
│   ├── resources/
│   └── routes/
└── docs/                    # Documentation
```

## Technology Stack

### Backend
- **Laravel 10** - PHP framework
- **Laravel Sanctum** - API authentication
- **Laravel WebSockets** - Real-time messaging
- **MySQL** - Database
- **Redis** - Caching and sessions
- **Stripe** - Payment processing
- **AWS S3** - File storage
- **Google Cloud Vision API** - Image recognition

### Mobile App
- **Flutter 3.16** - Cross-platform mobile development
- **Dart** - Programming language
- **Provider** - State management
- **WebSocket** - Real-time communication
- **Camera** - QR scanning and product photos
- **Google ML Kit** - On-device image recognition

### Admin Panel
- **Laravel Nova** - Admin interface
- **Laravel Telescope** - Debugging and monitoring

## Getting Started

### Prerequisites
- PHP 8.1+
- Composer
- Node.js 18+
- Flutter SDK 3.16+
- MySQL 8.0+
- Redis

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lets-talk
   ```

2. **Backend Setup**
   ```bash
   cd backend
   composer install
   cp .env.example .env
   php artisan key:generate
   php artisan migrate
   php artisan serve
   ```

3. **Mobile App Setup**
   ```bash
   cd mobile
   flutter pub get
   flutter run
   ```

4. **Admin Panel Setup**
   ```bash
   cd admin
   composer install
   cp .env.example .env
   php artisan key:generate
   php artisan migrate
   php artisan nova:install
   php artisan serve --port=8001
   ```

## Environment Configuration

Create `.env` files in each directory with the following variables:

### Backend (.env)
```
APP_NAME="Let's Talk"
APP_ENV=local
APP_KEY=base64:your-key
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=lets_talk
DB_USERNAME=root
DB_PASSWORD=

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

STRIPE_KEY=your-stripe-key
STRIPE_SECRET=your-stripe-secret

AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=your-bucket

GOOGLE_CLOUD_VISION_API_KEY=your-google-api-key
```

## API Documentation

The API documentation is available at `/api/documentation` when the backend is running.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
