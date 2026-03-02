// Admin Dashboard JavaScript
class AdminDashboard {
    constructor() {
        this.apiBaseUrl = 'http://127.0.0.1:8000/api';
        this.currentPage = 'dashboard';
        this.charts = {};
        this.token = localStorage.getItem('admin_token');
        this.init();
    }

    init() {
        this.checkAuth();
        this.setupEventListeners();
        this.loadDashboard();
        this.setupCharts();
    }

    checkAuth() {
        if (!this.token) {
            window.location.href = 'login.html';
            return;
        }
        
        // Verify token is still valid
        this.verifyToken();
    }

    async verifyToken() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/dashboard`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                localStorage.removeItem('admin_token');
                localStorage.removeItem('admin_user');
                window.location.href = 'login.html';
            }
        } catch (error) {
            console.error('Token verification failed:', error);
            localStorage.removeItem('admin_token');
            localStorage.removeItem('admin_user');
            window.location.href = 'login.html';
        }
    }

    logout() {
        // Clear local storage
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_user');
        localStorage.removeItem('admin_remember');
        
        // Redirect to login page
        window.location.href = 'login.html';
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const page = item.dataset.page;
                this.navigateToPage(page);
            });
        });

        // Sidebar toggle
        document.getElementById('sidebarToggle').addEventListener('click', () => {
            this.toggleSidebar();
        });

        // Search functionality
        document.querySelector('.search-box input').addEventListener('input', (e) => {
            this.handleSearch(e.target.value);
        });

        // User filters
        document.getElementById('userStatusFilter').addEventListener('change', (e) => {
            this.filterUsers(e.target.value);
        });

        document.getElementById('userSearch').addEventListener('input', (e) => {
            this.searchUsers(e.target.value);
        });

        // Modal close events
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeModal(e.target.id);
            }
        });

        // Logout functionality
        const logoutBtn = document.getElementById('logoutBtn');
        if (logoutBtn) {
            logoutBtn.addEventListener('click', (e) => {
                e.preventDefault();
                this.logout();
            });
        }
    }

    navigateToPage(page) {
        // Update navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-page="${page}"]`).classList.add('active');

        // Update page content
        document.querySelectorAll('.page').forEach(p => {
            p.classList.remove('active');
        });
        document.getElementById(page).classList.add('active');

        // Update page title and description
        this.updatePageHeader(page);

        // Load page-specific content
        this.loadPageContent(page);
    }

    updatePageHeader(page) {
        const titles = {
            dashboard: 'Dashboard',
            users: 'User Management',
            chats: 'Chats Management',
            payments: 'Payments Management',
            analytics: 'Analytics',
            settings: 'Settings',
            system: 'System Health'
        };

        const descriptions = {
            dashboard: 'Welcome to Let\'s Talk Admin Dashboard',
            users: 'Manage users, view profiles, and control access',
            chats: 'Monitor conversations and manage chat settings',
            payments: 'Track transactions and manage payment gateways',
            analytics: 'View detailed analytics and reports',
            settings: 'Configure app settings and preferences',
            system: 'Monitor system health and performance'
        };

        document.getElementById('pageTitle').textContent = titles[page];
        document.getElementById('pageDescription').textContent = descriptions[page];
    }

    async loadPageContent(page) {
        switch (page) {
            case 'dashboard':
                await this.loadDashboard();
                break;
            case 'users':
                await this.loadUsers();
                break;
            case 'settings':
                await this.loadSettings();
                break;
            case 'analytics':
                await this.loadAnalytics();
                break;
            case 'system':
                await this.loadSystemHealth();
                break;
        }
    }

    async loadDashboard() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/dashboard`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });
            const data = await response.json();

            if (response.ok) {
                this.updateDashboardStats(data);
                this.updateRecentActivity(data.recent_activities || []);
            } else {
                console.error('Failed to load dashboard:', data.message);
            }
        } catch (error) {
            console.error('Error loading dashboard:', error);
            this.showError('Failed to load dashboard data');
        }
    }

    updateDashboardStats(data) {
        document.getElementById('totalUsers').textContent = data.total_users || 0;
        document.getElementById('totalMessages').textContent = data.total_messages || 0;
        document.getElementById('totalPayments').textContent = data.total_payments || 0;
        document.getElementById('totalRevenue').textContent = `$${(data.total_revenue || 0).toLocaleString()}`;
    }

    updateRecentActivity(activities) {
        const container = document.getElementById('recentActivity');
        container.innerHTML = '';

        if (activities.length === 0) {
            container.innerHTML = '<p class="text-gray-500">No recent activity</p>';
            return;
        }

        activities.forEach(activity => {
            const activityItem = document.createElement('div');
            activityItem.className = 'activity-item';
            activityItem.innerHTML = `
                <div class="activity-icon">
                    <i class="fas ${this.getActivityIcon(activity.type)}"></i>
                </div>
                <div class="activity-content">
                    <p class="activity-text">${activity.description}</p>
                    <span class="activity-time">${this.formatTime(activity.created_at)}</span>
                </div>
            `;
            container.appendChild(activityItem);
        });
    }

    getActivityIcon(type) {
        const icons = {
            'user_registered': 'fa-user-plus',
            'user_login': 'fa-sign-in-alt',
            'payment_completed': 'fa-credit-card',
            'message_sent': 'fa-comment',
            'default': 'fa-info-circle'
        };
        return icons[type] || icons.default;
    }

    formatTime(timestamp) {
        const date = new Date(timestamp);
        const now = new Date();
        const diff = now - date;
        const minutes = Math.floor(diff / 60000);
        const hours = Math.floor(diff / 3600000);
        const days = Math.floor(diff / 86400000);

        if (minutes < 60) return `${minutes}m ago`;
        if (hours < 24) return `${hours}h ago`;
        return `${days}d ago`;
    }

    async loadUsers() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/users`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });
            const data = await response.json();

            if (response.ok) {
                this.renderUsersTable(data.users || []);
            } else {
                console.error('Failed to load users:', data.message);
            }
        } catch (error) {
            console.error('Error loading users:', error);
            this.showError('Failed to load users');
        }
    }

    renderUsersTable(users) {
        const tbody = document.getElementById('usersTableBody');
        tbody.innerHTML = '';

        users.forEach(user => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>
                    <div class="user-info">
                        <img src="${user.avatar || 'https://via.placeholder.com/40'}" alt="${user.name}" class="user-avatar">
                        <div>
                            <div class="user-name">${user.name}</div>
                            <div class="user-email">${user.email}</div>
                        </div>
                    </div>
                </td>
                <td>${user.phone}</td>
                <td>
                    <span class="status-badge ${this.getStatusClass(user.status)}">
                        ${user.status}
                    </span>
                </td>
                <td>${this.formatTime(user.last_seen_at)}</td>
                <td>
                    <div class="user-actions">
                        <button class="action-btn edit" onclick="adminDashboard.editUser(${user.id})">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="action-btn block" onclick="adminDashboard.toggleUserStatus(${user.id})">
                            <i class="fas fa-ban"></i>
                        </button>
                        <button class="action-btn delete" onclick="adminDashboard.deleteUser(${user.id})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            `;
            tbody.appendChild(row);
        });
    }

    getStatusClass(status) {
        const classes = {
            'active': 'status-active',
            'blocked': 'status-blocked',
            'suspended': 'status-suspended'
        };
        return classes[status] || 'status-active';
    }

    async loadSettings() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/settings`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });
            const data = await response.json();

            if (response.ok) {
                this.populateSettings(data.settings || {});
            } else {
                console.error('Failed to load settings:', data.message);
            }
        } catch (error) {
            console.error('Error loading settings:', error);
            this.showError('Failed to load settings');
        }
    }

    populateSettings(settings) {
        // Populate form fields with current settings
        Object.keys(settings).forEach(key => {
            const element = document.getElementById(key);
            if (element) {
                if (element.type === 'checkbox') {
                    element.checked = settings[key] === 'true' || settings[key] === true;
                } else {
                    element.value = settings[key];
                }
            }
        });
    }

    async saveSettings() {
        const settings = {
            app_name: document.getElementById('appName').value,
            registration_enabled: document.getElementById('registrationEnabled').checked,
            phone_verification_required: document.getElementById('phoneVerificationRequired').checked,
            stripe_enabled: document.getElementById('stripeEnabled').checked,
            paystack_enabled: document.getElementById('paystackEnabled').checked,
            flutterwave_enabled: document.getElementById('flutterwaveEnabled').checked
        };

        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/settings`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(settings)
            });

            const data = await response.json();

            if (response.ok) {
                this.showSuccess('Settings saved successfully');
            } else {
                this.showError(data.message || 'Failed to save settings');
            }
        } catch (error) {
            console.error('Error saving settings:', error);
            this.showError('Failed to save settings');
        }
    }

    async loadAnalytics() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/analytics`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });
            const data = await response.json();

            if (response.ok) {
                this.renderAnalytics(data);
            } else {
                console.error('Failed to load analytics:', data.message);
            }
        } catch (error) {
            console.error('Error loading analytics:', error);
            this.showError('Failed to load analytics');
        }
    }

    renderAnalytics(data) {
        // Implement analytics rendering
        console.log('Analytics data:', data);
    }

    async loadSystemHealth() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/system-health`, {
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });
            const data = await response.json();

            if (response.ok) {
                this.renderSystemHealth(data);
            } else {
                console.error('Failed to load system health:', data.message);
            }
        } catch (error) {
            console.error('Error loading system health:', error);
            this.showError('Failed to load system health');
        }
    }

    renderSystemHealth(data) {
        // Implement system health rendering
        console.log('System health data:', data);
    }

    setupCharts() {
        // User Growth Chart
        const ctx = document.getElementById('userGrowthChart');
        if (ctx) {
            this.charts.userGrowth = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                    datasets: [{
                        label: 'Users',
                        data: [12, 19, 3, 5, 2, 3],
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        tension: 0.4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }
    }

    toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.querySelector('.main-content');
        
        sidebar.classList.toggle('collapsed');
        mainContent.classList.toggle('expanded');
    }

    handleSearch(query) {
        // Implement search functionality
        console.log('Search query:', query);
    }

    filterUsers(status) {
        // Implement user filtering
        console.log('Filter users by status:', status);
    }

    searchUsers(query) {
        // Implement user search
        console.log('Search users:', query);
    }

    showAddUserModal() {
        document.getElementById('addUserModal').classList.add('show');
    }

    closeModal(modalId) {
        document.getElementById(modalId).classList.remove('show');
    }

    async addUser() {
        const form = document.getElementById('addUserForm');
        const formData = new FormData(form);
        const userData = Object.fromEntries(formData.entries());

        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/users`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(userData)
            });

            const data = await response.json();

            if (response.ok) {
                this.showSuccess('User added successfully');
                this.closeModal('addUserModal');
                form.reset();
                this.loadUsers(); // Refresh users list
            } else {
                this.showError(data.message || 'Failed to add user');
            }
        } catch (error) {
            console.error('Error adding user:', error);
            this.showError('Failed to add user');
        }
    }

    async editUser(userId) {
        // Implement user editing
        console.log('Edit user:', userId);
    }

    async toggleUserStatus(userId) {
        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/users/${userId}/status`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ action: 'toggle' })
            });

            const data = await response.json();

            if (response.ok) {
                this.showSuccess('User status updated successfully');
                this.loadUsers(); // Refresh users list
            } else {
                this.showError(data.message || 'Failed to update user status');
            }
        } catch (error) {
            console.error('Error updating user status:', error);
            this.showError('Failed to update user status');
        }
    }

    async deleteUser(userId) {
        if (!confirm('Are you sure you want to delete this user?')) {
            return;
        }

        try {
            const response = await fetch(`${this.apiBaseUrl}/admin/users/${userId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${this.token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });

            const data = await response.json();

            if (response.ok) {
                this.showSuccess('User deleted successfully');
                this.loadUsers(); // Refresh users list
            } else {
                this.showError(data.message || 'Failed to delete user');
            }
        } catch (error) {
            console.error('Error deleting user:', error);
            this.showError('Failed to delete user');
        }
    }

    showSuccess(message) {
        this.showNotification(message, 'success');
    }

    showError(message) {
        this.showNotification(message, 'error');
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'}"></i>
                <span>${message}</span>
            </div>
            <button class="notification-close" onclick="this.parentElement.remove()">
                <i class="fas fa-times"></i>
            </button>
        `;

        // Add to page
        document.body.appendChild(notification);

        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 5000);
    }
}

// Global functions for HTML onclick handlers
function showAddUserModal() {
    adminDashboard.showAddUserModal();
}

function closeModal(modalId) {
    adminDashboard.closeModal(modalId);
}

function addUser() {
    adminDashboard.addUser();
}

function saveSettings() {
    adminDashboard.saveSettings();
}

function resetSettings() {
    if (confirm('Are you sure you want to reset all settings to default?')) {
        // Implement reset functionality
        console.log('Reset settings');
    }
}

// Initialize admin dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.adminDashboard = new AdminDashboard();
});

// Add notification styles
const notificationStyles = `
    .notification {
        position: fixed;
        top: 20px;
        right: 20px;
        background: white;
        border-radius: 0.5rem;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        padding: 1rem;
        display: flex;
        align-items: center;
        gap: 0.75rem;
        z-index: 3000;
        animation: slideIn 0.3s ease;
    }

    .notification-success {
        border-left: 4px solid #10b981;
    }

    .notification-error {
        border-left: 4px solid #ef4444;
    }

    .notification-content {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }

    .notification-content i {
        font-size: 1.125rem;
    }

    .notification-success .notification-content i {
        color: #10b981;
    }

    .notification-error .notification-content i {
        color: #ef4444;
    }

    .notification-close {
        background: none;
        border: none;
        color: #94a3b8;
        cursor: pointer;
        padding: 0.25rem;
        border-radius: 0.25rem;
        transition: background-color 0.2s;
    }

    .notification-close:hover {
        background-color: #f1f5f9;
    }

    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
`;

// Add styles to document
const styleSheet = document.createElement('style');
styleSheet.textContent = notificationStyles;
document.head.appendChild(styleSheet);
