#!/bin/bash

# Let's Talk - Complete Setup Script
# This script sets up the entire project including Laravel backend, Flutter mobile app, and admin panel

set -e

echo "🚀 Starting Let's Talk project setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Check if required tools are installed
check_requirements() {
    print_header "Checking Requirements"
    
    # Check PHP
    if ! command -v php &> /dev/null; then
        print_error "PHP is not installed. Please install PHP 8.1+"
        exit 1
    fi
    
    PHP_VERSION=$(php -r "echo PHP_VERSION;")
    print_status "PHP version: $PHP_VERSION"
    
    # Check Composer
    if ! command -v composer &> /dev/null; then
        print_error "Composer is not installed. Please install Composer"
        exit 1
    fi
    
    print_status "Composer is installed"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_warning "Node.js is not installed. Some features may not work properly"
    else
        NODE_VERSION=$(node --version)
        print_status "Node.js version: $NODE_VERSION"
    fi
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter is not installed. Mobile app setup will be skipped"
    else
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        print_status "Flutter: $FLUTTER_VERSION"
    fi
    
    # Check MySQL
    if ! command -v mysql &> /dev/null; then
        print_warning "MySQL is not installed. Please install MySQL 8.0+"
    else
        print_status "MySQL is installed"
    fi
    
    # Check Redis
    if ! command -v redis-server &> /dev/null; then
        print_warning "Redis is not installed. Please install Redis"
    else
        print_status "Redis is installed"
    fi
}

# Setup Laravel Backend
setup_backend() {
    print_header "Setting up Laravel Backend"
    
    cd backend
    
    # Install dependencies
    print_status "Installing PHP dependencies..."
    composer install --no-interaction
    
    # Create environment file
    if [ ! -f .env ]; then
        print_status "Creating .env file..."
        cp .env.example .env
    fi
    
    # Generate application key
    print_status "Generating application key..."
    php artisan key:generate
    
    # Run migrations
    print_status "Running database migrations..."
    php artisan migrate --force
    
    # Seed database
    print_status "Seeding database..."
    php artisan db:seed --force
    
    # Create storage link
    print_status "Creating storage link..."
    php artisan storage:link
    
    # Install Laravel WebSockets
    print_status "Installing Laravel WebSockets..."
    php artisan websockets:install
    
    # Publish vendor assets
    print_status "Publishing vendor assets..."
    php artisan vendor:publish --all
    
    cd ..
}

# Setup Admin Panel
setup_admin() {
    print_header "Setting up Laravel Admin Panel"
    
    cd admin
    
    # Install dependencies
    print_status "Installing PHP dependencies..."
    composer install --no-interaction
    
    # Create environment file
    if [ ! -f .env ]; then
        print_status "Creating .env file..."
        cp .env.example .env
    fi
    
    # Generate application key
    print_status "Generating application key..."
    php artisan key:generate
    
    # Run migrations
    print_status "Running database migrations..."
    php artisan migrate --force
    
    # Install Nova
    print_status "Installing Laravel Nova..."
    php artisan nova:install
    
    # Publish vendor assets
    print_status "Publishing vendor assets..."
    php artisan vendor:publish --all
    
    cd ..
}

# Setup Flutter Mobile App
setup_mobile() {
    print_header "Setting up Flutter Mobile App"
    
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter not found. Skipping mobile app setup."
        return
    fi
    
    cd mobile
    
    # Get dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate code
    print_status "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    # Create assets directories
    print_status "Creating assets directories..."
    mkdir -p assets/images
    mkdir -p assets/icons
    mkdir -p assets/animations
    mkdir -p assets/sounds
    mkdir -p assets/fonts
    
    cd ..
}

# Setup Database
setup_database() {
    print_header "Setting up Database"
    
    # Create database if it doesn't exist
    print_status "Creating database..."
    mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS lets_talk CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    print_status "Database setup complete"
}

# Create environment files
create_env_files() {
    print_header "Creating Environment Files"
    
    # Backend .env
    cat > backend/.env << EOF
APP_NAME="Let's Talk"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=lets_talk
DB_USERNAME=root
DB_PASSWORD=

BROADCAST_DRIVER=pusher
CACHE_DRIVER=redis
FILESYSTEM_DISK=local
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_APP_NAME="${APP_NAME}"
VITE_PUSHER_APP_KEY="\${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="\${PUSHER_HOST}"
VITE_PUSHER_PORT="\${PUSHER_PORT}"
VITE_PUSHER_SCHEME="\${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="\${PUSHER_APP_CLUSTER}"

STRIPE_KEY=
STRIPE_SECRET=
STRIPE_WEBHOOK_SECRET=

GOOGLE_CLOUD_VISION_API_KEY=
EOF

    # Admin .env
    cat > admin/.env << EOF
APP_NAME="Let's Talk Admin"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8001

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=lets_talk
DB_USERNAME=root
DB_PASSWORD=

BROADCAST_DRIVER=pusher
CACHE_DRIVER=redis
FILESYSTEM_DISK=local
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="admin@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_APP_NAME="${APP_NAME}"
VITE_PUSHER_APP_KEY="\${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="\${PUSHER_HOST}"
VITE_PUSHER_PORT="\${PUSHER_PORT}"
VITE_PUSHER_SCHEME="\${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="\${PUSHER_APP_CLUSTER}"

STRIPE_KEY=
STRIPE_SECRET=
STRIPE_WEBHOOK_SECRET=

GOOGLE_CLOUD_VISION_API_KEY=
EOF

    print_status "Environment files created"
}

# Create startup scripts
create_startup_scripts() {
    print_header "Creating Startup Scripts"
    
    # Start all services
    cat > start.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Let's Talk services..."

# Start Redis
echo "Starting Redis..."
redis-server --daemonize yes

# Start Laravel Backend
echo "Starting Laravel Backend..."
cd backend
php artisan serve --host=0.0.0.0 --port=8000 &
BACKEND_PID=$!

# Start Laravel Admin
echo "Starting Laravel Admin..."
cd ../admin
php artisan serve --host=0.0.0.0 --port=8001 &
ADMIN_PID=$!

# Start Laravel WebSockets
echo "Starting WebSockets..."
cd ../backend
php artisan websockets:serve --host=0.0.0.0 --port=6001 &
WEBSOCKETS_PID=$!

echo "✅ All services started!"
echo "Backend: http://localhost:8000"
echo "Admin: http://localhost:8001"
echo "WebSockets: ws://localhost:6001"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for interrupt
trap "echo 'Stopping services...'; kill $BACKEND_PID $ADMIN_PID $WEBSOCKETS_PID; exit" INT
wait
EOF

    chmod +x start.sh
    
    # Stop all services
    cat > stop.sh << 'EOF'
#!/bin/bash

echo "🛑 Stopping Let's Talk services..."

# Stop Redis
redis-cli shutdown

# Kill PHP processes
pkill -f "php artisan serve"
pkill -f "php artisan websockets:serve"

echo "✅ All services stopped"
EOF

    chmod +x stop.sh
    
    print_status "Startup scripts created"
}

# Main setup function
main() {
    print_header "Let's Talk Project Setup"
    
    check_requirements
    create_env_files
    setup_database
    setup_backend
    setup_admin
    setup_mobile
    create_startup_scripts
    
    print_header "Setup Complete!"
    echo ""
    print_status "Next steps:"
    echo "1. Configure your database credentials in backend/.env and admin/.env"
    echo "2. Set up your Stripe API keys for payment processing"
    echo "3. Configure Google Cloud Vision API for product search"
    echo "4. Run './start.sh' to start all services"
    echo "5. Access the admin panel at http://localhost:8001"
    echo "6. Build and run the Flutter app with 'cd mobile && flutter run'"
    echo ""
    print_status "Happy coding! 🎉"
}

# Run main function
main "$@"
