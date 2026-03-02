# Let's Talk - Complete Deployment Guide

## 🚀 System Overview

The Let's Talk application is a comprehensive chat system with the following components:

- **Backend**: Laravel 12 API with WhatsApp-style authentication
- **Admin Dashboard**: Modern web interface for system management
- **Mobile App**: Flutter application (currently paused for backend completion)
- **Payment System**: Multi-gateway support (Stripe, Paystack, Flutterwave)

## 📋 Pre-Deployment Checklist

### 1. System Requirements

- **PHP**: 8.2 or higher
- **MySQL**: 5.7 or higher (via XAMPP)
- **Composer**: Latest version
- **Node.js**: 16 or higher (for admin dashboard)
- **Web Server**: Apache/Nginx or Laravel's built-in server

### 2. Environment Setup

#### Backend Setup
```bash
# Navigate to backend directory
cd backend

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=letstalk
DB_USERNAME=root
DB_PASSWORD=

# Run migrations and seeders
php artisan migrate:fresh --seed

# Start the server
php artisan serve
```

#### Admin Dashboard Setup
```bash
# The admin dashboard is static HTML/CSS/JS
# Simply place the admin folder in your web server directory
# or serve it using any static file server
```

## 🔧 Configuration

### 1. Database Configuration

Update your `.env` file with your XAMPP MySQL settings:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=letstalk
DB_USERNAME=root
DB_PASSWORD=
```

### 2. Payment Gateway Configuration

#### Stripe Configuration
```env
STRIPE_KEY=pk_test_your_stripe_public_key
STRIPE_SECRET=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
```

#### Paystack Configuration
```env
PAYSTACK_PUBLIC_KEY=pk_test_your_paystack_public_key
PAYSTACK_SECRET_KEY=sk_test_your_paystack_secret_key
PAYSTACK_WEBHOOK_SECRET=your_webhook_secret
```

#### Flutterwave Configuration
```env
FLUTTERWAVE_PUBLIC_KEY=FLWPUBK_your_flutterwave_public_key
FLUTTERWAVE_SECRET_KEY=FLWSECK_your_flutterwave_secret_key
FLUTTERWAVE_WEBHOOK_SECRET=your_webhook_secret
```

### 3. File Storage Configuration

For production, configure S3 or other cloud storage:

```env
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=your_bucket_name
```

### 4. Email Configuration

Configure SMTP for email notifications:

```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=your_email@gmail.com
MAIL_FROM_NAME="Let's Talk"
```

## 🧪 Testing

### 1. Run Complete System Test

```bash
# Run the comprehensive test script
php test_complete_system.php
```

This will test:
- ✅ Backend API endpoints
- ✅ Admin authentication
- ✅ Payment gateway settings
- ✅ User management
- ✅ Admin dashboard functionality

### 2. Manual Testing

#### Admin Dashboard Access
1. Open: `http://localhost/admin/login.html`
2. Login with: `admin@letstalk.com` / `admin123`
3. Navigate to Settings page
4. Verify payment gateway toggles are working

#### API Testing
```bash
# Test admin login
curl -X POST http://127.0.0.1:8000/api/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@letstalk.com","password":"admin123"}'

# Test getting settings
curl -X GET http://127.0.0.1:8000/api/admin/settings \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test updating payment settings
curl -X POST http://127.0.0.1:8000/api/admin/settings \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"stripe_enabled":true,"paystack_enabled":true,"flutterwave_enabled":true}'
```

## 🌐 Deployment

### 1. Production Server Setup

#### Using Apache
```apache
# Virtual host configuration
<VirtualHost *:80>
    ServerName yourdomain.com
    DocumentRoot /var/www/letstalk/backend/public
    
    <Directory /var/www/letstalk/backend/public>
        AllowOverride All
        Require all granted
    </Directory>
    
    # Admin dashboard
    Alias /admin /var/www/letstalk/admin
    <Directory /var/www/letstalk/admin>
        Require all granted
    </Directory>
</VirtualHost>
```

#### Using Nginx
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    root /var/www/letstalk/backend/public;
    
    index index.php index.html;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Admin dashboard
    location /admin {
        alias /var/www/letstalk/admin;
        try_files $uri $uri/ =404;
    }
}
```

### 2. SSL Configuration

Install SSL certificate for production:

```bash
# Using Let's Encrypt
sudo certbot --nginx -d yourdomain.com

# Or configure manually in your web server
```

### 3. Environment Optimization

```bash
# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Set proper permissions
sudo chown -R www-data:www-data /var/www/letstalk
sudo chmod -R 755 /var/www/letstalk
sudo chmod -R 775 /var/www/letstalk/backend/storage
```

## 🔐 Security Configuration

### 1. Admin Access Security

- Change default admin password after first login
- Enable two-factor authentication for admin accounts
- Use strong passwords
- Regularly rotate API keys

### 2. Payment Gateway Security

- Use test keys for development
- Switch to live keys only in production
- Configure webhook endpoints for payment notifications
- Monitor payment logs regularly

### 3. API Security

- Enable CORS properly for your domains
- Use rate limiting
- Monitor API usage
- Implement proper error handling

## 📊 Monitoring

### 1. System Health Monitoring

Access system health via admin dashboard:
- Database connectivity
- Cache status
- Storage availability
- Queue status

### 2. Payment Monitoring

Monitor payment gateways:
- Transaction success rates
- Failed payment reasons
- Webhook delivery status
- API response times

### 3. User Activity Monitoring

Track user activity:
- Registration rates
- Login patterns
- Chat usage
- Payment volume

## 🚨 Troubleshooting

### Common Issues

#### 1. Database Connection Issues
```bash
# Check MySQL service
sudo systemctl status mysql

# Test connection
mysql -u root -p -h 127.0.0.1

# Check .env configuration
php artisan config:clear
```

#### 2. Payment Gateway Issues
- Verify API keys are correct
- Check webhook endpoints are accessible
- Monitor payment gateway status pages
- Review error logs

#### 3. Admin Dashboard Issues
- Clear browser cache
- Check JavaScript console for errors
- Verify API endpoints are accessible
- Check CORS configuration

### Log Files

```bash
# Laravel logs
tail -f /var/www/letstalk/backend/storage/logs/laravel.log

# Web server logs
tail -f /var/log/apache2/error.log
tail -f /var/log/nginx/error.log

# Payment gateway logs
# Check individual gateway dashboards
```

## 📈 Performance Optimization

### 1. Database Optimization
```bash
# Optimize database
php artisan migrate:status
php artisan db:show

# Add indexes for frequently queried columns
# Monitor slow queries
```

### 2. Caching
```bash
# Enable Redis for caching
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 3. File Storage
- Use CDN for static assets
- Optimize image uploads
- Implement file compression

## 🔄 Updates and Maintenance

### 1. Regular Updates
```bash
# Update dependencies
composer update
npm update

# Run migrations
php artisan migrate

# Clear caches
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 2. Backup Strategy
```bash
# Database backup
php artisan backup:run

# File backup
# Implement automated backup to cloud storage
```

## 📞 Support

### Admin Credentials
- **Email**: admin@letstalk.com
- **Password**: admin123 (change after first login)

### API Documentation
- Base URL: `http://yourdomain.com/api`
- Admin endpoints: `/admin/*`
- Public endpoints: `/*`

### Payment Gateway Support
- **Stripe**: https://support.stripe.com
- **Paystack**: https://paystack.com/support
- **Flutterwave**: https://flutterwave.com/support

## ✅ Final Checklist

Before going live:

- [ ] All tests passing
- [ ] SSL certificate installed
- [ ] Payment gateways configured with live keys
- [ ] Admin password changed
- [ ] Backup system configured
- [ ] Monitoring set up
- [ ] Error logging configured
- [ ] Performance optimized
- [ ] Security measures implemented
- [ ] Documentation updated

---

**🎉 Congratulations! Your Let's Talk application is ready for deployment!**

For additional support or questions, please refer to the documentation or contact the development team.
