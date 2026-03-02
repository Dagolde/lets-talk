# Let's Talk - System Architecture

## Overview

Let's Talk is a comprehensive chat application with payment integration, QR code functionality, and AI-powered product search. The system is built using a modern, scalable architecture with separate components for different concerns.

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  Laravel Admin  │    │  Laravel API    │
│   (Mobile)      │    │   (Web Panel)   │    │   (Backend)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Database      │
                    │   (MySQL)       │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Redis Cache   │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   WebSockets    │
                    └─────────────────┘
```

## Technology Stack

### Backend (Laravel API)
- **Framework**: Laravel 10
- **Database**: MySQL 8.0+
- **Cache**: Redis
- **Real-time**: Laravel WebSockets
- **Authentication**: Laravel Sanctum
- **Payments**: Stripe
- **File Storage**: AWS S3
- **AI**: Google Cloud Vision API
- **Queue**: Redis + Laravel Queues

### Mobile App (Flutter)
- **Framework**: Flutter 3.16+
- **State Management**: Provider + Riverpod
- **HTTP Client**: Dio + Retrofit
- **Local Storage**: Hive + SharedPreferences
- **Real-time**: WebSocket
- **QR Code**: qr_code_scanner + qr_flutter
- **Camera**: camera + image_picker
- **AI**: Google ML Kit
- **Payments**: Stripe Flutter SDK
- **Notifications**: Firebase Cloud Messaging

### Admin Panel (Laravel Nova)
- **Framework**: Laravel 10 + Nova 4
- **UI**: Nova Admin Interface
- **Monitoring**: Laravel Telescope
- **Backup**: Spatie Laravel Backup

## Core Features Architecture

### 1. Chat System

#### Real-time Messaging
```
User A → Flutter App → WebSocket → Laravel Backend → WebSocket → User B
```

**Components:**
- **WebSocket Service**: Handles real-time communication
- **Message Model**: Stores message data with metadata
- **Conversation Model**: Manages chat rooms and participants
- **Message Broadcasting**: Uses Laravel Events and WebSockets

#### Message Types
- Text messages
- Media messages (images, videos, audio, files)
- Payment messages
- Location sharing
- Contact sharing
- Voice messages

### 2. Payment System

#### Payment Flow
```
User → Flutter App → Laravel API → Stripe → Payment Processing → Webhook → Database
```

**Components:**
- **Payment Model**: Stores transaction data
- **Stripe Integration**: Handles payment processing
- **QR Code Payments**: Generate and scan payment QR codes
- **Payment History**: Track all transactions
- **Refund System**: Handle payment reversals

#### Payment Types
- Peer-to-peer transfers
- QR code payments
- Payment requests
- Refunds

### 3. QR Code System

#### QR Code Types
- **Profile QR**: Share user profile
- **Payment QR**: Make payments
- **Group Invite QR**: Join group chats
- **Contact Share QR**: Share contact information

#### QR Code Flow
```
Generate QR → Store in Database → Share → Scan → Process Action
```

### 4. AI-Powered Product Search

#### Product Search Flow
```
Camera → Image Capture → Google ML Kit → Object Detection → 
API Call → Google Cloud Vision → Product Search → Results
```

**Components:**
- **ProductSearch Model**: Stores search data and results
- **Image Processing**: Google ML Kit for on-device processing
- **Cloud Vision API**: Server-side image analysis
- **Product Matching**: AI-powered product recognition
- **Search History**: Track user searches

### 5. User Management

#### Authentication Flow
```
Login/Register → Laravel Sanctum → JWT Token → API Access
```

**Components:**
- **User Model**: User data and relationships
- **Authentication**: Laravel Sanctum
- **Profile Management**: Avatar, settings, preferences
- **Contact Management**: Add/remove contacts
- **Privacy Settings**: Control data visibility

## Database Design

### Core Tables

#### Users
- Basic user information
- Authentication data
- Profile settings
- Stripe integration

#### Conversations
- Chat rooms (private/group)
- Conversation metadata
- Participant management

#### Messages
- Message content and metadata
- Media attachments
- Read receipts
- Message reactions

#### Payments
- Transaction records
- Payment status tracking
- Fee calculations
- Refund handling

#### QR Codes
- QR code data and metadata
- Usage tracking
- Expiration management

#### Product Searches
- Search queries and results
- AI analysis data
- User search history

### Relationships

```
Users (1) ←→ (Many) Conversations
Users (1) ←→ (Many) Messages
Users (1) ←→ (Many) Payments
Users (1) ←→ (Many) QR Codes
Users (1) ←→ (Many) Product Searches
Conversations (1) ←→ (Many) Messages
```

## API Design

### RESTful Endpoints

#### Authentication
- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/logout`
- `POST /api/auth/forgot-password`

#### Users
- `GET /api/user/profile`
- `PUT /api/user/profile`
- `POST /api/user/avatar`
- `GET /api/users/search`

#### Conversations
- `GET /api/conversations`
- `POST /api/conversations`
- `GET /api/conversations/{id}`
- `GET /api/conversations/{id}/messages`
- `POST /api/conversations/{id}/messages`

#### Payments
- `GET /api/payments`
- `POST /api/payments`
- `POST /api/payments/qr`
- `GET /api/payments/{id}`

#### Product Search
- `POST /api/product-search`
- `GET /api/product-search/{id}`
- `GET /api/product-search/history`

#### QR Codes
- `GET /api/qr-codes`
- `POST /api/qr-codes`
- `POST /api/qr-codes/scan`

### WebSocket Events

#### Chat Events
- `message.sent`
- `message.received`
- `message.read`
- `typing.started`
- `typing.stopped`
- `user.online`
- `user.offline`

#### Payment Events
- `payment.created`
- `payment.completed`
- `payment.failed`

## Security Architecture

### Authentication & Authorization
- **JWT Tokens**: Secure API access
- **Role-based Access**: User permissions
- **API Rate Limiting**: Prevent abuse
- **Input Validation**: Sanitize all inputs

### Data Protection
- **Encryption**: Sensitive data encryption
- **HTTPS**: Secure communication
- **CORS**: Cross-origin resource sharing
- **SQL Injection Prevention**: Parameterized queries

### Payment Security
- **Stripe Integration**: PCI-compliant payments
- **Webhook Verification**: Secure payment confirmations
- **Fraud Detection**: Transaction monitoring

## Scalability Considerations

### Horizontal Scaling
- **Load Balancing**: Multiple server instances
- **Database Sharding**: Distribute data across servers
- **CDN**: Content delivery network for media
- **Caching**: Redis for performance

### Performance Optimization
- **Database Indexing**: Optimize queries
- **Lazy Loading**: Load data on demand
- **Image Optimization**: Compress and resize images
- **API Caching**: Cache frequently accessed data

### Monitoring & Logging
- **Application Monitoring**: Track performance
- **Error Tracking**: Monitor and alert on errors
- **User Analytics**: Track user behavior
- **Payment Monitoring**: Monitor transaction health

## Deployment Architecture

### Development Environment
- **Local Development**: Docker containers
- **Database**: Local MySQL instance
- **Cache**: Local Redis instance
- **File Storage**: Local storage

### Production Environment
- **Web Servers**: Nginx + PHP-FPM
- **Application Servers**: Multiple Laravel instances
- **Database**: MySQL cluster
- **Cache**: Redis cluster
- **File Storage**: AWS S3
- **CDN**: CloudFront
- **Load Balancer**: Application Load Balancer

## Future Enhancements

### Planned Features
- **Video Calls**: WebRTC integration
- **Group Video**: Multi-party video calls
- **Advanced AI**: Machine learning for recommendations
- **Blockchain**: Cryptocurrency payments
- **AR Features**: Augmented reality product visualization
- **Voice Assistant**: AI-powered voice commands

### Technical Improvements
- **Microservices**: Break down into smaller services
- **GraphQL**: More efficient API queries
- **Real-time Analytics**: Live user behavior tracking
- **A/B Testing**: Feature experimentation
- **Automated Testing**: Comprehensive test coverage

## Conclusion

The Let's Talk system is designed with scalability, security, and user experience in mind. The modular architecture allows for easy maintenance and future enhancements while providing a robust foundation for a modern chat application with advanced features like payments and AI-powered search.
