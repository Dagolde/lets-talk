<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - Let's Talk Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gray-50">
    <!-- Navigation -->
    <nav class="bg-white shadow-lg">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex items-center">
                    <div class="flex-shrink-0 flex items-center">
                        <i class="fas fa-comments text-blue-600 text-2xl mr-3"></i>
                        <span class="text-xl font-bold text-gray-900">Let's Talk Admin</span>
                    </div>
                </div>
                <div class="flex items-center space-x-4">
                    <div class="relative">
                        <button id="userMenuBtn" class="flex items-center space-x-2 text-gray-700 hover:text-gray-900">
                            <img id="userAvatar" class="h-8 w-8 rounded-full" src="https://via.placeholder.com/32" alt="User">
                            <span id="userName">Admin</span>
                            <i class="fas fa-chevron-down"></i>
                        </button>
                        <div id="userMenu" class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50 hidden">
                            <a href="/admin/dashboard" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                <i class="fas fa-tachometer-alt mr-2"></i>Dashboard
                            </a>
                            <hr class="my-1">
                            <a href="#" id="logoutBtn" class="block px-4 py-2 text-sm text-red-600 hover:bg-gray-100">
                                <i class="fas fa-sign-out-alt mr-2"></i>Logout
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <!-- Sidebar -->
    <div class="flex">
        <div class="w-64 bg-white shadow-lg min-h-screen">
            <div class="p-4">
                <nav class="space-y-2">
                    <a href="/admin/dashboard" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg">
                        <i class="fas fa-tachometer-alt mr-3"></i>
                        Dashboard
                    </a>
                    <a href="/admin/users" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg">
                        <i class="fas fa-users mr-3"></i>
                        Users
                    </a>
                    <a href="/admin/settings" class="flex items-center px-4 py-2 text-blue-600 bg-blue-50 rounded-lg">
                        <i class="fas fa-cog mr-3"></i>
                        Settings
                    </a>
                    <a href="/admin/analytics" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg">
                        <i class="fas fa-chart-bar mr-3"></i>
                        Analytics
                    </a>
                </nav>
            </div>
        </div>

        <!-- Main Content -->
        <div class="flex-1 p-8">
            <!-- Page Header -->
            <div class="mb-8">
                <h1 class="text-3xl font-bold text-gray-900">System Settings</h1>
                <p class="text-gray-600">Configure system-wide settings and preferences.</p>
            </div>

            <!-- Settings Form -->
            <div class="bg-white rounded-lg shadow p-6">
                <form id="settingsForm" class="space-y-6">
                    <!-- General Settings -->
                    <div>
                        <h3 class="text-lg font-medium text-gray-900 mb-4">General Settings</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">App Name</label>
                                <input type="text" id="appName" name="app_name" 
                                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">App Version</label>
                                <input type="text" id="appVersion" name="app_version" 
                                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            </div>
                        </div>
                    </div>

                    <!-- User Registration -->
                    <div>
                        <h3 class="text-lg font-medium text-gray-900 mb-4">User Registration</h3>
                        <div class="space-y-4">
                            <div class="flex items-center">
                                <input type="checkbox" id="registrationEnabled" name="registration_enabled" 
                                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                                <label for="registrationEnabled" class="ml-2 block text-sm text-gray-700">
                                    Enable new user registration
                                </label>
                            </div>
                            <div class="flex items-center">
                                <input type="checkbox" id="emailVerification" name="email_verification" 
                                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                                <label for="emailVerification" class="ml-2 block text-sm text-gray-700">
                                    Require email verification
                                </label>
                            </div>
                            <div class="flex items-center">
                                <input type="checkbox" id="phoneVerification" name="phone_verification" 
                                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                                <label for="phoneVerification" class="ml-2 block text-sm text-gray-700">
                                    Require phone verification
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Settings -->
                    <div>
                        <h3 class="text-lg font-medium text-gray-900 mb-4">Payment Settings</h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Default Currency</label>
                                <select id="defaultCurrency" name="default_currency" 
                                        class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                    <option value="USD">USD</option>
                                    <option value="EUR">EUR</option>
                                    <option value="GBP">GBP</option>
                                    <option value="NGN">NGN</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Transaction Fee (%)</label>
                                <input type="number" id="transactionFee" name="transaction_fee" step="0.01" min="0" max="10"
                                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            </div>
                        </div>
                    </div>

                    <!-- Security Settings -->
                    <div>
                        <h3 class="text-lg font-medium text-gray-900 mb-4">Security Settings</h3>
                        <div class="space-y-4">
                            <div class="flex items-center">
                                <input type="checkbox" id="twoFactorRequired" name="two_factor_required" 
                                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                                <label for="twoFactorRequired" class="ml-2 block text-sm text-gray-700">
                                    Require two-factor authentication for all users
                                </label>
                            </div>
                            <div class="flex items-center">
                                <input type="checkbox" id="sessionTimeout" name="session_timeout" 
                                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                                <label for="sessionTimeout" class="ml-2 block text-sm text-gray-700">
                                    Enable session timeout
                                </label>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Session Timeout (minutes)</label>
                                <input type="number" id="sessionTimeoutMinutes" name="session_timeout_minutes" min="5" max="1440"
                                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            </div>
                        </div>
                    </div>

                    <!-- Save Button -->
                    <div class="flex justify-end">
                        <button type="submit" 
                                class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                            <i class="fas fa-save mr-2"></i>Save Settings
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // Check authentication
        const token = localStorage.getItem('admin_token');
        if (!token) {
            window.location.href = '/admin/login';
        }

        // Load user info
        const user = JSON.parse(localStorage.getItem('admin_user') || '{}');
        document.getElementById('userName').textContent = user.name || 'Admin';
        if (user.avatar) {
            document.getElementById('userAvatar').src = user.avatar;
        }

        // Toggle user menu
        document.getElementById('userMenuBtn').addEventListener('click', function() {
            document.getElementById('userMenu').classList.toggle('hidden');
        });

        // Logout
        document.getElementById('logoutBtn').addEventListener('click', async function() {
            try {
                await fetch('http://192.168.1.106:8000/api/admin/logout', {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                });
            } catch (error) {
                console.error('Logout error:', error);
            } finally {
                localStorage.removeItem('admin_token');
                localStorage.removeItem('admin_user');
                window.location.href = '/admin/login';
            }
        });

        // Load settings
        async function loadSettings() {
            try {
                const response = await fetch('http://192.168.1.106:8000/api/admin/settings', {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    populateSettingsForm(data.data || {});
                }
            } catch (error) {
                console.error('Error loading settings:', error);
            }
        }

        function populateSettingsForm(settings) {
            // Populate form fields with settings data
            document.getElementById('appName').value = settings.app_name || 'Let\'s Talk';
            document.getElementById('appVersion').value = settings.app_version || '1.0.0';
            document.getElementById('registrationEnabled').checked = settings.registration_enabled !== false;
            document.getElementById('emailVerification').checked = settings.email_verification === true;
            document.getElementById('phoneVerification').checked = settings.phone_verification === true;
            document.getElementById('defaultCurrency').value = settings.default_currency || 'USD';
            document.getElementById('transactionFee').value = settings.transaction_fee || '2.5';
            document.getElementById('twoFactorRequired').checked = settings.two_factor_required === true;
            document.getElementById('sessionTimeout').checked = settings.session_timeout === true;
            document.getElementById('sessionTimeoutMinutes').value = settings.session_timeout_minutes || '30';
        }

        // Save settings
        document.getElementById('settingsForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(e.target);
            const settings = Object.fromEntries(formData.entries());
            
            // Convert checkboxes to boolean
            settings.registration_enabled = formData.get('registration_enabled') === 'on';
            settings.email_verification = formData.get('email_verification') === 'on';
            settings.phone_verification = formData.get('phone_verification') === 'on';
            settings.two_factor_required = formData.get('two_factor_required') === 'on';
            settings.session_timeout = formData.get('session_timeout') === 'on';

            try {
                const response = await fetch('http://192.168.1.106:8000/api/admin/settings', {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(settings)
                });

                if (response.ok) {
                    alert('Settings saved successfully!');
                } else {
                    alert('Failed to save settings');
                }
            } catch (error) {
                console.error('Error saving settings:', error);
                alert('Error saving settings');
            }
        });

        // Load settings on page load
        loadSettings();
    </script>
</body>
</html>
