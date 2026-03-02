// Admin Login JavaScript
class AdminLogin {
    constructor() {
        this.apiBaseUrl = 'http://127.0.0.1:8000/api';
        this.isLoading = false;
        this.init();
    }

    init() {
        this.setupEventListeners();
        this.checkAuthStatus();
    }

    setupEventListeners() {
        const loginForm = document.getElementById('loginForm');
        const togglePassword = document.getElementById('togglePassword');
        const passwordInput = document.getElementById('password');
        const forgotPasswordLink = document.getElementById('forgotPassword');

        // Form submission
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleLogin();
        });

        // Password visibility toggle
        togglePassword.addEventListener('click', () => {
            this.togglePasswordVisibility();
        });

        // Forgot password
        forgotPasswordLink.addEventListener('click', (e) => {
            e.preventDefault();
            this.handleForgotPassword();
        });

        // Real-time validation
        const emailInput = document.getElementById('email');
        emailInput.addEventListener('blur', () => {
            this.validateEmail(emailInput.value);
        });

        passwordInput.addEventListener('blur', () => {
            this.validatePassword(passwordInput.value);
        });

        // Enter key navigation
        emailInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                passwordInput.focus();
            }
        });

        passwordInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                loginForm.dispatchEvent(new Event('submit'));
            }
        });
    }

    async checkAuthStatus() {
        const token = localStorage.getItem('admin_token');
        if (token) {
            try {
                const response = await fetch(`${this.apiBaseUrl}/admin/dashboard`, {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    }
                });

                if (response.ok) {
                    // User is already authenticated, redirect to dashboard
                    window.location.href = 'index.html';
                } else {
                    // Token is invalid, remove it
                    localStorage.removeItem('admin_token');
                }
            } catch (error) {
                console.error('Auth check failed:', error);
                localStorage.removeItem('admin_token');
            }
        }
    }

    async handleLogin() {
        if (this.isLoading) return;

        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        const remember = document.getElementById('remember').checked;

        // Validate inputs
        if (!this.validateEmail(email) || !this.validatePassword(password)) {
            return;
        }

        this.setLoadingState(true);

        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/login`, {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    email: email,
                    password: password,
                    remember: remember
                })
            });

            const data = await response.json();

            if (response.ok) {
                // Store token
                localStorage.setItem('admin_token', data.token);
                localStorage.setItem('admin_user', JSON.stringify(data.user));
                
                if (remember) {
                    localStorage.setItem('admin_remember', 'true');
                }

                this.showNotification('Success', 'Login successful! Redirecting...', 'success');
                
                // Redirect to dashboard after a short delay
                setTimeout(() => {
                    window.location.href = 'index.html';
                }, 1000);
            } else {
                this.handleLoginError(data);
            }
        } catch (error) {
            console.error('Login error:', error);
            this.showNotification('Error', 'Network error. Please check your connection.', 'error');
        } finally {
            this.setLoadingState(false);
        }
    }

    handleLoginError(data) {
        let message = 'Login failed. Please try again.';
        
        if (data.errors) {
            if (data.errors.email) {
                message = data.errors.email[0];
                this.showFieldError('email', data.errors.email[0]);
            } else if (data.errors.password) {
                message = data.errors.password[0];
                this.showFieldError('password', data.errors.password[0]);
            }
        } else if (data.message) {
            message = data.message;
        }

        this.showNotification('Login Failed', message, 'error');
    }

    validateEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const isValid = emailRegex.test(email);
        
        if (!email) {
            this.showFieldError('email', 'Email is required');
            return false;
        } else if (!isValid) {
            this.showFieldError('email', 'Please enter a valid email address');
            return false;
        } else {
            this.clearFieldError('email');
            return true;
        }
    }

    validatePassword(password) {
        if (!password) {
            this.showFieldError('password', 'Password is required');
            return false;
        } else if (password.length < 6) {
            this.showFieldError('password', 'Password must be at least 6 characters');
            return false;
        } else {
            this.clearFieldError('password');
            return true;
        }
    }

    showFieldError(fieldName, message) {
        const inputGroup = document.querySelector(`#${fieldName}`).closest('.input-group');
        const existingError = inputGroup.querySelector('.error-message');
        
        inputGroup.classList.add('error');
        
        if (!existingError) {
            const errorDiv = document.createElement('div');
            errorDiv.className = 'error-message';
            errorDiv.innerHTML = `<i class="fas fa-exclamation-circle"></i>${message}`;
            inputGroup.appendChild(errorDiv);
        } else {
            existingError.innerHTML = `<i class="fas fa-exclamation-circle"></i>${message}`;
        }
    }

    clearFieldError(fieldName) {
        const inputGroup = document.querySelector(`#${fieldName}`).closest('.input-group');
        const errorMessage = inputGroup.querySelector('.error-message');
        
        inputGroup.classList.remove('error');
        if (errorMessage) {
            errorMessage.remove();
        }
    }

    togglePasswordVisibility() {
        const passwordInput = document.getElementById('password');
        const toggleBtn = document.getElementById('togglePassword');
        const icon = toggleBtn.querySelector('i');

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            icon.className = 'fas fa-eye-slash';
        } else {
            passwordInput.type = 'password';
            icon.className = 'fas fa-eye';
        }
    }

    async handleForgotPassword() {
        const email = document.getElementById('email').value.trim();
        
        if (!email) {
            this.showNotification('Error', 'Please enter your email address first', 'warning');
            document.getElementById('email').focus();
            return;
        }

        if (!this.validateEmail(email)) {
            return;
        }

        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/forgot-password`, {
                method: 'POST',
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ email: email })
            });

            const data = await response.json();

            if (response.ok) {
                this.showNotification('Success', 'Password reset link sent to your email', 'success');
            } else {
                this.showNotification('Error', data.message || 'Failed to send reset link', 'error');
            }
        } catch (error) {
            console.error('Forgot password error:', error);
            this.showNotification('Error', 'Network error. Please try again.', 'error');
        }
    }

    setLoadingState(loading) {
        this.isLoading = loading;
        const loginBtn = document.getElementById('loginBtn');
        const btnText = loginBtn.querySelector('.btn-text');
        const btnLoading = loginBtn.querySelector('.btn-loading');

        if (loading) {
            loginBtn.disabled = true;
            btnText.style.display = 'none';
            btnLoading.style.display = 'flex';
        } else {
            loginBtn.disabled = false;
            btnText.style.display = 'inline';
            btnLoading.style.display = 'none';
        }
    }

    showNotification(title, message, type = 'info') {
        const container = document.getElementById('notificationContainer');
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        
        const iconMap = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle'
        };

        notification.innerHTML = `
            <i class="${iconMap[type]}"></i>
            <div class="notification-content">
                <div class="notification-title">${title}</div>
                <div class="notification-message">${message}</div>
            </div>
        `;

        container.appendChild(notification);

        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 5000);

        // Remove on click
        notification.addEventListener('click', () => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        });
    }
}

// Initialize login functionality when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.adminLogin = new AdminLogin();
});

// Add some visual feedback for form interactions
document.addEventListener('DOMContentLoaded', () => {
    const inputs = document.querySelectorAll('input');
    
    inputs.forEach(input => {
        input.addEventListener('focus', () => {
            input.closest('.form-group').classList.add('focused');
        });
        
        input.addEventListener('blur', () => {
            input.closest('.form-group').classList.remove('focused');
        });
    });
});

// Add keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + Enter to submit form
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.dispatchEvent(new Event('submit'));
        }
    }
    
    // Escape to clear form
    if (e.key === 'Escape') {
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.reset();
            document.querySelectorAll('.error-message').forEach(msg => msg.remove());
            document.querySelectorAll('.input-group').forEach(group => group.classList.remove('error'));
        }
    }
});
