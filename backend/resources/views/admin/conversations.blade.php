<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Conversations Management - Let's Talk Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-gray-100">
    <div class="min-h-screen">
        <!-- Navigation -->
        <nav class="bg-green-600 text-white shadow-lg">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-16">
                    <div class="flex items-center">
                        <h1 class="text-xl font-semibold">Let's Talk Admin</h1>
                    </div>
                    <div class="flex items-center space-x-4">
                        <a href="/admin/dashboard" class="hover:text-green-200">Dashboard</a>
                        <a href="/admin/users" class="hover:text-green-200">Users</a>
                        <a href="/admin/conversations" class="text-green-200 font-semibold">Conversations</a>
                        <a href="/admin/settings" class="hover:text-green-200">Settings</a>
                        <button onclick="logout()" class="hover:text-green-200">Logout</button>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Main Content -->
        <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
            <!-- Page Header -->
            <div class="px-4 py-6 sm:px-0">
                <div class="flex justify-between items-center">
                    <div>
                        <h2 class="text-2xl font-bold text-gray-900">Conversations Management</h2>
                        <p class="mt-1 text-sm text-gray-600">Manage conversations, contacts, and chat statistics</p>
                    </div>
                    <div class="flex space-x-3">
                        <button onclick="refreshData()" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
                            <i class="fas fa-sync-alt mr-2"></i>Refresh
                        </button>
                    </div>
                </div>
            </div>

            <!-- Statistics Cards -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Total Conversations</dt>
                                    <dd class="text-lg font-medium text-gray-900" id="totalConversations">-</dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Active Users</dt>
                                    <dd class="text-lg font-medium text-gray-900" id="activeUsers">-</dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Total Contacts</dt>
                                    <dd class="text-lg font-medium text-gray-900" id="totalContacts">-</dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="bg-white overflow-hidden shadow rounded-lg">
                    <div class="p-5">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <div class="w-8 h-8 bg-red-500 rounded-md flex items-center justify-center">
                                    <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"></path>
                                    </svg>
                                </div>
                            </div>
                            <div class="ml-5 w-0 flex-1">
                                <dl>
                                    <dt class="text-sm font-medium text-gray-500 truncate">Messages Today</dt>
                                    <dd class="text-lg font-medium text-gray-900" id="messagesToday">-</dd>
                                </dl>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabs -->
            <div class="bg-white shadow rounded-lg">
                <div class="border-b border-gray-200">
                    <nav class="-mb-px flex space-x-8 px-6">
                        <button onclick="showTab('conversations')" id="tab-conversations" class="tab-button py-4 px-1 border-b-2 border-green-500 font-medium text-sm text-green-600">
                            Conversations
                        </button>
                        <button onclick="showTab('contacts')" id="tab-contacts" class="tab-button py-4 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                            Contacts
                        </button>
                        <button onclick="showTab('analytics')" id="tab-analytics" class="tab-button py-4 px-1 border-b-2 border-transparent font-medium text-sm text-gray-500 hover:text-gray-700 hover:border-gray-300">
                            Analytics
                        </button>
                    </nav>
                </div>

                <!-- Conversations Tab -->
                <div id="conversations-content" class="tab-content p-6">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-medium text-gray-900">Recent Conversations</h3>
                        <div class="flex space-x-2">
                            <input type="text" id="conversationSearch" placeholder="Search conversations..." class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                            <select id="conversationFilter" class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                                <option value="">All Types</option>
                                <option value="direct">Direct</option>
                                <option value="group">Group</option>
                            </select>
                        </div>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Conversation</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Participants</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Message</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="conversationsTable" class="bg-white divide-y divide-gray-200">
                                <!-- Conversations will be loaded here -->
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Contacts Tab -->
                <div id="contacts-content" class="tab-content p-6 hidden">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-lg font-medium text-gray-900">User Contacts</h3>
                        <div class="flex space-x-2">
                            <input type="text" id="contactSearch" placeholder="Search contacts..." class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                            <select id="contactFilter" class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                                <option value="">All Users</option>
                                <option value="favorites">Favorites Only</option>
                            </select>
                        </div>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contact Count</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Favorite Count</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Sync</th>
                                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="contactsTable" class="bg-white divide-y divide-gray-200">
                                <!-- Contacts will be loaded here -->
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Analytics Tab -->
                <div id="analytics-content" class="tab-content p-6 hidden">
                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <div class="bg-white p-6 rounded-lg shadow">
                            <h3 class="text-lg font-medium text-gray-900 mb-4">Conversation Activity</h3>
                            <canvas id="conversationChart" width="400" height="200"></canvas>
                        </div>
                        <div class="bg-white p-6 rounded-lg shadow">
                            <h3 class="text-lg font-medium text-gray-900 mb-4">Message Volume</h3>
                            <canvas id="messageChart" width="400" height="200"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Check authentication
        const token = localStorage.getItem('admin_token');
        if (!token) {
            window.location.href = '/admin/login';
        }

        // Load initial data
        document.addEventListener('DOMContentLoaded', function() {
            loadStatistics();
            loadConversations();
            showTab('conversations');
        });

        // Tab functionality
        function showTab(tabName) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.add('hidden');
            });

            // Remove active class from all tab buttons
            document.querySelectorAll('.tab-button').forEach(button => {
                button.classList.remove('border-green-500', 'text-green-600');
                button.classList.add('border-transparent', 'text-gray-500');
            });

            // Show selected tab content
            document.getElementById(tabName + '-content').classList.remove('hidden');

            // Add active class to selected tab button
            document.getElementById('tab-' + tabName).classList.remove('border-transparent', 'text-gray-500');
            document.getElementById('tab-' + tabName).classList.add('border-green-500', 'text-green-600');

            // Load tab-specific data
            if (tabName === 'conversations') {
                loadConversations();
            } else if (tabName === 'contacts') {
                loadContacts();
            } else if (tabName === 'analytics') {
                loadAnalytics();
            }
        }

        // Load statistics
        async function loadStatistics() {
            try {
                const response = await fetch('/api/admin/conversations/stats', {
                    headers: {
                        'Authorization': 'Bearer ' + token,
                        'Accept': 'application/json'
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    document.getElementById('totalConversations').textContent = data.total_conversations || 0;
                    document.getElementById('activeUsers').textContent = data.active_users || 0;
                    document.getElementById('totalContacts').textContent = data.total_contacts || 0;
                    document.getElementById('messagesToday').textContent = data.messages_today || 0;
                }
            } catch (error) {
                console.error('Error loading statistics:', error);
            }
        }

        // Load conversations
        async function loadConversations() {
            try {
                const response = await fetch('/api/admin/conversations', {
                    headers: {
                        'Authorization': 'Bearer ' + token,
                        'Accept': 'application/json'
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    updateConversationsTable(data.data || []);
                }
            } catch (error) {
                console.error('Error loading conversations:', error);
            }
        }

        // Update conversations table
        function updateConversationsTable(conversations) {
            const tbody = document.getElementById('conversationsTable');
            tbody.innerHTML = '';

            conversations.forEach(conversation => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="flex items-center">
                            <div class="flex-shrink-0 h-10 w-10">
                                <div class="h-10 w-10 rounded-full bg-green-500 flex items-center justify-center">
                                    <span class="text-white font-medium">${conversation.name ? conversation.name.charAt(0).toUpperCase() : 'C'}</span>
                                </div>
                            </div>
                            <div class="ml-4">
                                <div class="text-sm font-medium text-gray-900">${conversation.name || 'Direct Chat'}</div>
                                <div class="text-sm text-gray-500">ID: ${conversation.id}</div>
                            </div>
                        </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${conversation.type === 'direct' ? 'bg-green-100 text-green-800' : 'bg-blue-100 text-blue-800'}">
                            ${conversation.type}
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        ${conversation.participants_count || 0} participants
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        ${conversation.last_message_at ? new Date(conversation.last_message_at).toLocaleString() : 'No messages'}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${conversation.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                            ${conversation.is_active ? 'Active' : 'Inactive'}
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button onclick="viewConversation(${conversation.id})" class="text-green-600 hover:text-green-900 mr-3">View</button>
                        <button onclick="deleteConversation(${conversation.id})" class="text-red-600 hover:text-red-900">Delete</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        // Load contacts
        async function loadContacts() {
            try {
                const response = await fetch('/api/admin/contacts', {
                    headers: {
                        'Authorization': 'Bearer ' + token,
                        'Accept': 'application/json'
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    updateContactsTable(data.data || []);
                }
            } catch (error) {
                console.error('Error loading contacts:', error);
            }
        }

        // Update contacts table
        function updateContactsTable(contacts) {
            const tbody = document.getElementById('contactsTable');
            tbody.innerHTML = '';

            contacts.forEach(contact => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="flex items-center">
                            <div class="flex-shrink-0 h-10 w-10">
                                <div class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center">
                                    <span class="text-white font-medium">${contact.user_name.charAt(0).toUpperCase()}</span>
                                </div>
                            </div>
                            <div class="ml-4">
                                <div class="text-sm font-medium text-gray-900">${contact.user_name}</div>
                                <div class="text-sm text-gray-500">${contact.user_email}</div>
                            </div>
                        </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        ${contact.contact_count}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        ${contact.favorite_count}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        ${contact.last_sync ? new Date(contact.last_sync).toLocaleString() : 'Never'}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button onclick="viewUserContacts(${contact.user_id})" class="text-blue-600 hover:text-blue-900">View Contacts</button>
                    </td>
                `;
                tbody.appendChild(row);
            });
        }

        // Load analytics
        async function loadAnalytics() {
            try {
                const response = await fetch('/api/admin/conversations/analytics', {
                    headers: {
                        'Authorization': 'Bearer ' + token,
                        'Accept': 'application/json'
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    createConversationChart(data.conversation_activity);
                    createMessageChart(data.message_volume);
                }
            } catch (error) {
                console.error('Error loading analytics:', error);
            }
        }

        // Create conversation chart
        function createConversationChart(data) {
            const ctx = document.getElementById('conversationChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels || [],
                    datasets: [{
                        label: 'Conversations',
                        data: data.values || [],
                        borderColor: 'rgb(34, 197, 94)',
                        backgroundColor: 'rgba(34, 197, 94, 0.1)',
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
        }

        // Create message chart
        function createMessageChart(data) {
            const ctx = document.getElementById('messageChart').getContext('2d');
            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: data.labels || [],
                    datasets: [{
                        label: 'Messages',
                        data: data.values || [],
                        backgroundColor: 'rgba(59, 130, 246, 0.5)',
                        borderColor: 'rgb(59, 130, 246)',
                        borderWidth: 1
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
        }

        // Refresh data
        function refreshData() {
            loadStatistics();
            const activeTab = document.querySelector('.tab-button.border-green-500').id.replace('tab-', '');
            showTab(activeTab);
        }

        // Logout
        function logout() {
            fetch('/api/admin/logout', {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer ' + token,
                    'Accept': 'application/json'
                }
            }).finally(() => {
                localStorage.removeItem('admin_token');
                window.location.href = '/admin/login';
            });
        }

        // Search and filter functionality
        document.getElementById('conversationSearch').addEventListener('input', function() {
            // Implement search functionality
        });

        document.getElementById('conversationFilter').addEventListener('change', function() {
            // Implement filter functionality
        });

        document.getElementById('contactSearch').addEventListener('input', function() {
            // Implement search functionality
        });

        document.getElementById('contactFilter').addEventListener('change', function() {
            // Implement filter functionality
        });
    </script>
</body>
</html>
