<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Let's Talk</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                        <button id="notificationsBtn" class="p-2 text-gray-400 hover:text-gray-600">
                            <i class="fas fa-bell text-xl"></i>
                            <span id="notificationCount" class="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center hidden">0</span>
                        </button>
                    </div>
                    <div class="relative">
                        <button id="userMenuBtn" class="flex items-center space-x-2 text-gray-700 hover:text-gray-900">
                            <img id="userAvatar" class="h-8 w-8 rounded-full" src="https://via.placeholder.com/32" alt="User">
                            <span id="userName">Admin</span>
                            <i class="fas fa-chevron-down"></i>
                        </button>
                        <div id="userMenu" class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50 hidden">
                            <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                <i class="fas fa-user mr-2"></i>Profile
                            </a>
                            <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                                <i class="fas fa-cog mr-2"></i>Settings
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
                    <a href="/admin/dashboard" class="flex items-center px-4 py-2 text-blue-600 bg-blue-50 rounded-lg">
                        <i class="fas fa-tachometer-alt mr-3"></i>
                        Dashboard
                    </a>
                    <a href="/admin/users" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg">
                        <i class="fas fa-users mr-3"></i>
                        Users
                    </a>
                    <a href="/admin/conversations" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg">
                        <i class="fas fa-comments mr-3"></i>
                        Conversations
                    </a>
                    <a href="/admin/settings" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-lg">
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
                <h1 class="text-3xl font-bold text-gray-900">Dashboard</h1>
                <p class="text-gray-600">Welcome back! Here's what's happening with your system.</p>
            </div>

            <!-- Stats Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <div class="bg-white rounded-lg shadow p-6">
                    <div class="flex items-center">
                        <div class="p-3 rounded-full bg-blue-100 text-blue-600">
                            <i class="fas fa-users text-2xl"></i>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Total Users</p>
                            <p id="totalUsers" class="text-2xl font-semibold text-gray-900">0</p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow p-6">
                    <div class="flex items-center">
                        <div class="p-3 rounded-full bg-green-100 text-green-600">
                            <i class="fas fa-comments text-2xl"></i>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Active Chats</p>
                            <p id="activeChats" class="text-2xl font-semibold text-gray-900">0</p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow p-6">
                    <div class="flex items-center">
                        <div class="p-3 rounded-full bg-yellow-100 text-yellow-600">
                            <i class="fas fa-credit-card text-2xl"></i>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Total Payments</p>
                            <p id="totalPayments" class="text-2xl font-semibold text-gray-900">$0</p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-lg shadow p-6">
                    <div class="flex items-center">
                        <div class="p-3 rounded-full bg-purple-100 text-purple-600">
                            <i class="fas fa-chart-line text-2xl"></i>
                        </div>
                        <div class="ml-4">
                            <p class="text-sm font-medium text-gray-600">Revenue</p>
                            <p id="totalRevenue" class="text-2xl font-semibold text-gray-900">$0</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
                <div class="bg-white rounded-lg shadow p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">User Growth</h3>
                    <canvas id="userGrowthChart" width="400" height="200"></canvas>
                </div>

                <div class="bg-white rounded-lg shadow p-6">
                    <h3 class="text-lg font-semibold text-gray-900 mb-4">Payment Activity</h3>
                    <canvas id="paymentChart" width="400" height="200"></canvas>
                </div>
            </div>

            <!-- Recent Activity -->
            <div class="bg-white rounded-lg shadow">
                <div class="px-6 py-4 border-b border-gray-200">
                    <h3 class="text-lg font-semibold text-gray-900">Recent Activity</h3>
                </div>
                <div class="p-6">
                    <div id="recentActivity" class="space-y-4">
                        <!-- Activity items will be loaded here -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Check authentication
        const token = localStorage.getItem('admin_token');
        console.log('Dashboard token:', token); // Debug log
        if (!token) {
            console.log('No token found, redirecting to login'); // Debug log
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

        // Load dashboard data
        async function loadDashboardData() {
            try {
                const response = await fetch('http://192.168.1.106:8000/api/admin/dashboard', {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    updateDashboard(data.data);
                }
            } catch (error) {
                console.error('Error loading dashboard data:', error);
            }
        }

        function updateDashboard(data) {
            // Update stats
            document.getElementById('totalUsers').textContent = data.stats.total_users || 0;
            document.getElementById('activeChats').textContent = data.stats.active_chats || 0;
            document.getElementById('totalPayments').textContent = `$${(data.stats.total_payment_volume || 0).toFixed(2)}`;
            document.getElementById('totalRevenue').textContent = `$${(data.stats.total_payment_volume || 0).toFixed(2)}`;

            // Update charts
            updateCharts(data);
            
            // Update recent activity
            updateRecentActivity(data);
        }

        function updateCharts(data) {
            // User Growth Chart
            const userCtx = document.getElementById('userGrowthChart').getContext('2d');
            new Chart(userCtx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                    datasets: [{
                        label: 'New Users',
                        data: [12, 19, 3, 5, 2, 3],
                        borderColor: 'rgb(59, 130, 246)',
                        backgroundColor: 'rgba(59, 130, 246, 0.1)',
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });

            // Payment Chart
            const paymentCtx = document.getElementById('paymentChart').getContext('2d');
            new Chart(paymentCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Completed', 'Pending', 'Failed'],
                    datasets: [{
                        data: [70, 20, 10],
                        backgroundColor: [
                            'rgb(34, 197, 94)',
                            'rgb(251, 191, 36)',
                            'rgb(239, 68, 68)'
                        ]
                    }]
                },
                options: {
                    responsive: true
                }
            });
        }

        function updateRecentActivity(data) {
            const container = document.getElementById('recentActivity');
            container.innerHTML = '';

            if (data.recent_users && data.recent_users.length > 0) {
                data.recent_users.forEach(user => {
                    const activityItem = document.createElement('div');
                    activityItem.className = 'flex items-center space-x-3';
                    activityItem.innerHTML = `
                        <div class="flex-shrink-0">
                            <img class="h-8 w-8 rounded-full" src="${user.avatar || 'https://via.placeholder.com/32'}" alt="${user.name}">
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm font-medium text-gray-900">${user.name}</p>
                            <p class="text-sm text-gray-500">New user registered</p>
                        </div>
                        <div class="text-sm text-gray-500">
                            ${new Date(user.created_at).toLocaleDateString()}
                        </div>
                    `;
                    container.appendChild(activityItem);
                });
            } else {
                container.innerHTML = '<p class="text-gray-500">No recent activity</p>';
            }
        }

        // Load data on page load
        loadDashboardData();

        // Refresh data every 30 seconds
        setInterval(loadDashboardData, 30000);
    </script>
</body>
</html>
