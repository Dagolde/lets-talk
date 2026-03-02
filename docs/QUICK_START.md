# Let's Talk - Quick Start Guide

## Prerequisites

Before you begin, ensure you have the following installed:

- **PHP 8.1+** with extensions: `php-mysql`, `php-redis`, `php-gd`, `php-mbstring`, `php-xml`
- **Composer** (latest version)
- **MySQL 8.0+** or **MariaDB 10.5+**
- **Redis** (for caching and sessions)
- **Node.js 18+** (for asset compilation)
- **Flutter 3.16+** (for mobile app development)
- **Git**

## Quick Setup (Automated)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lets-talk
   ```

2. **Run the setup script**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. **Configure environment variables**
   - Edit `backend/.env` and `admin/.env`
   - Set your database credentials
   - Add your Stripe API keys
   - Configure Google Cloud Vision API key

4. **Start all services**
   ```bash
   ./start.sh
   ```

5. **Access the applications**
   - Backend API: http://localhost:8000
   - Admin Panel: http://localhost:8001
   - WebSocket Server: ws://localhost:6001

## Manual Setup

### 1. Backend Setup

```bash
cd backend

# Install dependencies
composer install

# Create environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env file
# DB_DATABASE=lets_talk
# DB_USERNAME=your_username
# DB_PASSWORD=your_password

# Run migrations
php artisan migrate

# Seed database
php artisan db:seed

# Create storage link
php artisan storage:link

# Install WebSockets
php artisan websockets:install

# Start the server
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. Admin Panel Setup

```bash
cd admin

# Install dependencies
composer install

# Create environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database (same as backend)

# Run migrations
php artisan migrate

# Install Nova
php artisan nova:install

# Start the server
php artisan serve --host=0.0.0.0 --port=8001
```

### 3. Mobile App Setup

```bash
cd mobile

# Get dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

## Configuration

### Environment Variables

#### Backend (.env)
```env
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
DB_PASSWORD=your_password

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

STRIPE_KEY=pk_test_your_stripe_key
STRIPE_SECRET=sk_test_your_stripe_secret

GOOGLE_CLOUD_VISION_API_KEY=your_google_api_key
```

#### Admin (.env)
```env
APP_NAME="Let's Talk Admin"
APP_ENV=local
APP_KEY=base64:your-key
APP_DEBUG=true
APP_URL=http://localhost:8001

# Same database configuration as backend
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=lets_talk
DB_USERNAME=root
DB_PASSWORD=your_password
```

### API Keys Setup

#### Stripe
1. Create a Stripe account at https://stripe.com
2. Get your API keys from the dashboard
3. Add them to your `.env` files

#### Google Cloud Vision
1. Create a Google Cloud project
2. Enable the Cloud Vision API
3. Create credentials (API key)
4. Add the key to your `.env` files

## Testing the Setup

### 1. Test Backend API

```bash
# Test the API health
curl http://localhost:8000/api/health

# Test authentication
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### 2. Test Admin Panel

1. Visit http://localhost:8001
2. Create an admin user
3. Access the Nova dashboard

### 3. Test Mobile App

1. Run the Flutter app
2. Register a new account
3. Test basic chat functionality

## Development Workflow

### Backend Development

```bash
cd backend

# Run tests
php artisan test

# Generate API documentation
php artisan l5-swagger:generate

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Watch for changes (optional)
php artisan serve --host=0.0.0.0 --port=8000
```

### Mobile App Development

```bash
cd mobile

# Run tests
flutter test

# Build for release
flutter build apk
flutter build ios

# Hot reload during development
flutter run --hot
```

### Database Management

```bash
# Create a new migration
php artisan make:migration create_new_table

# Run migrations
php artisan migrate

# Rollback migrations
php artisan migrate:rollback

# Seed database
php artisan db:seed

# Reset database
php artisan migrate:fresh --seed
```

## Common Issues & Solutions

### 1. Database Connection Issues

**Error**: `SQLSTATE[HY000] [1045] Access denied for user`

**Solution**:
- Check database credentials in `.env`
- Ensure MySQL is running
- Create database: `CREATE DATABASE lets_talk;`

### 2. Redis Connection Issues

**Error**: `Connection refused`

**Solution**:
- Start Redis: `redis-server`
- Check Redis configuration in `.env`

### 3. Flutter Dependencies Issues

**Error**: `Could not resolve dependencies`

**Solution**:
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. Laravel Storage Issues

**Error**: `Storage link not found`

**Solution**:
```bash
php artisan storage:link
```

### 5. Permission Issues

**Error**: `Permission denied`

**Solution**:
```bash
chmod -R 755 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

## Next Steps

1. **Explore the Codebase**
   - Read the [Architecture Documentation](ARCHITECTURE.md)
   - Review the API endpoints
   - Understand the database schema

2. **Set Up Development Tools**
   - Configure your IDE
   - Set up debugging
   - Install useful extensions

3. **Start Building Features**
   - Create new API endpoints
   - Add new Flutter screens
   - Implement new functionality

4. **Testing**
   - Write unit tests
   - Create integration tests
   - Set up CI/CD pipeline

## Support

- **Documentation**: Check the `docs/` folder
- **Issues**: Create an issue on GitHub
- **Discussions**: Use GitHub Discussions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

Happy coding! 🚀
