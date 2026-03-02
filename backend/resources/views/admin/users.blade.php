<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - Let's Talk Admin</title>
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
                    <a href="/admin/users" class="flex items-center px-4 py-2 text-blue-600 bg-blue-50 rounded-lg">
                        <i class="fas fa-users mr-3"></i>
                        Users
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
                <h1 class="text-3xl font-bold text-gray-900">User Management</h1>
                <p class="text-gray-600">Manage all users in the system.</p>
            </div>

            <!-- Search and Filter -->
            <div class="bg-white rounded-lg shadow p-6 mb-6">
                <div class="flex flex-col md:flex-row gap-4">
                    <div class="flex-1">
                        <input type="text" id="searchInput" placeholder="Search users..." 
                               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    </div>
                    <div class="flex gap-2">
                        <select id="statusFilter" class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500">
                            <option value="">All Status</option>
                            <option value="active">Active</option>
                            <option value="suspended">Suspended</option>
                            <option value="blocked">Blocked</option>
                        </select>
                        <button id="addUserBtn" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                            <i class="fas fa-plus mr-2"></i>Add User
                        </button>
                    </div>
                </div>
            </div>

            <!-- Users Table -->
            <div class="bg-white rounded-lg shadow overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-200">
                    <h3 class="text-lg font-semibold text-gray-900">Users</h3>
                </div>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Phone</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="usersTableBody" class="bg-white divide-y divide-gray-200">
                            <!-- Users will be loaded here -->
                        </tbody>
                    </table>
                </div>
                <!-- Pagination -->
                <div id="pagination" class="px-6 py-4 border-t border-gray-200">
                    <!-- Pagination will be loaded here -->
                </div>
            </div>
        </div>
    </div>

    <!-- Add User Modal -->
    <div id="addUserModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
        <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
            <div class="mt-3">
                <h3 class="text-lg font-medium text-gray-900 mb-4">Add New User</h3>
                <form id="addUserForm">
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Name</label>
                        <input type="text" id="userName" name="name" required 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
                        <input type="email" id="userEmail" name="email" required 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Phone</label>
                        <input type="text" id="userPhone" name="phone" required 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Password</label>
                        <input type="password" id="userPassword" name="password" required 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    <div class="flex justify-end space-x-3">
                        <button type="button" onclick="closeAddUserModal()" 
                                class="px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50">
                            Cancel
                        </button>
                        <button type="submit" 
                                class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                            Add User
                        </button>
                    </div>
                </form>
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

        // Load users
        async function loadUsers(page = 1, search = '', status = '') {
            try {
                let url = `http://192.168.1.106:8000/api/admin/users?page=${page}`;
                if (search) url += `&search=${encodeURIComponent(search)}`;
                if (status) url += `&status=${encodeURIComponent(status)}`;

                const response = await fetch(url, {
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                });

                if (response.ok) {
                    const data = await response.json();
                    updateUsersTable(data.data);
                    updatePagination(data.data);
                } else {
                    console.error('Failed to load users:', response.status);
                }
            } catch (error) {
                console.error('Error loading users:', error);
            }
        }

        function updateUsersTable(users) {
            const tbody = document.getElementById('usersTableBody');
            tbody.innerHTML = '';

            if (users.data && users.data.length > 0) {
                users.data.forEach(user => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="flex-shrink-0 h-10 w-10">
                                    <img class="h-10 w-10 rounded-full" src="${user.avatar || 'https://via.placeholder.com/40'}" alt="${user.name}">
                                </div>
                                <div class="ml-4">
                                    <div class="text-sm font-medium text-gray-900">${user.name}</div>
                                    <div class="text-sm text-gray-500">ID: ${user.id}</div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${user.email || 'N/A'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${user.phone || 'N/A'}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusClass(user.status)}">
                                ${user.status || 'active'}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            ${new Date(user.created_at).toLocaleDateString()}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <button onclick="editUser(${user.id})" class="text-blue-600 hover:text-blue-900 mr-3" title="Edit User">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button onclick="toggleUserStatus(${user.id}, '${user.status}')" class="text-yellow-600 hover:text-yellow-900 mr-3" title="Toggle Status">
                                <i class="fas fa-ban"></i>
                            </button>
                            <button onclick="deleteUser(${user.id})" class="text-red-600 hover:text-red-900" title="Delete User">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    `;
                    tbody.appendChild(row);
                });
            } else {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="6" class="px-6 py-4 text-center text-gray-500">
                            No users found
                        </td>
                    </tr>
                `;
            }
        }

        function updatePagination(users) {
            const pagination = document.getElementById('pagination');
            if (users.current_page && users.last_page > 1) {
                let paginationHtml = '<div class="flex items-center justify-between">';
                paginationHtml += `<div class="text-sm text-gray-700">Showing ${users.from} to ${users.to} of ${users.total} results</div>`;
                paginationHtml += '<div class="flex space-x-2">';
                
                // Previous button
                if (users.prev_page_url) {
                    paginationHtml += `<button onclick="loadUsers(${users.current_page - 1})" class="px-3 py-1 border border-gray-300 rounded-md hover:bg-gray-50">Previous</button>`;
                }
                
                // Page numbers
                for (let i = 1; i <= users.last_page; i++) {
                    if (i === users.current_page) {
                        paginationHtml += `<span class="px-3 py-1 bg-blue-600 text-white rounded-md">${i}</span>`;
                    } else {
                        paginationHtml += `<button onclick="loadUsers(${i})" class="px-3 py-1 border border-gray-300 rounded-md hover:bg-gray-50">${i}</button>`;
                    }
                }
                
                // Next button
                if (users.next_page_url) {
                    paginationHtml += `<button onclick="loadUsers(${users.current_page + 1})" class="px-3 py-1 border border-gray-300 rounded-md hover:bg-gray-50">Next</button>`;
                }
                
                paginationHtml += '</div></div>';
                pagination.innerHTML = paginationHtml;
            } else {
                pagination.innerHTML = '';
            }
        }

        function getStatusClass(status) {
            switch (status) {
                case 'active':
                    return 'bg-green-100 text-green-800';
                case 'suspended':
                    return 'bg-yellow-100 text-yellow-800';
                case 'blocked':
                    return 'bg-red-100 text-red-800';
                default:
                    return 'bg-gray-100 text-gray-800';
            }
        }

        // Event listeners
        document.getElementById('addUserBtn').addEventListener('click', function() {
            document.getElementById('addUserModal').classList.remove('hidden');
        });

        document.getElementById('searchInput').addEventListener('input', function() {
            const search = this.value;
            const status = document.getElementById('statusFilter').value;
            loadUsers(1, search, status);
        });

        document.getElementById('statusFilter').addEventListener('change', function() {
            const search = document.getElementById('searchInput').value;
            const status = this.value;
            loadUsers(1, search, status);
        });

        document.getElementById('addUserForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const userData = {
                name: formData.get('name'),
                email: formData.get('email'),
                phone: formData.get('phone'),
                password: formData.get('password')
            };

            try {
                const response = await fetch('http://192.168.1.106:8000/api/admin/users', {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(userData)
                });

                if (response.ok) {
                    alert('User created successfully!');
                    closeAddUserModal();
                    loadUsers(); // Reload users
                } else {
                    const error = await response.json();
                    alert('Error creating user: ' + (error.message || 'Unknown error'));
                }
            } catch (error) {
                console.error('Error creating user:', error);
                alert('Error creating user');
            }
        });

        function closeAddUserModal() {
            document.getElementById('addUserModal').classList.add('hidden');
            document.getElementById('addUserForm').reset();
        }

        function editUser(userId) {
            // Implement edit user functionality
            console.log('Edit user:', userId);
            alert('Edit user functionality will be implemented');
        }

        async function toggleUserStatus(userId, currentStatus) {
            const action = currentStatus === 'active' ? 'block' : 'unblock';
            const reason = prompt('Enter reason for ' + action + 'ing user (optional):');
            
            try {
                const response = await fetch(`http://192.168.1.106:8000/api/admin/users/${userId}/status`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        action: action,
                        reason: reason
                    })
                });

                if (response.ok) {
                    alert('User status updated successfully!');
                    loadUsers(); // Reload users
                } else {
                    const error = await response.json();
                    alert('Error updating user status: ' + (error.message || 'Unknown error'));
                }
            } catch (error) {
                console.error('Error updating user status:', error);
                alert('Error updating user status');
            }
        }

        async function deleteUser(userId) {
            if (confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
                try {
                    const response = await fetch(`http://192.168.1.106:8000/api/admin/users/${userId}`, {
                        method: 'DELETE',
                        headers: {
                            'Authorization': `Bearer ${token}`,
                            'Content-Type': 'application/json'
                        }
                    });

                    if (response.ok) {
                        alert('User deleted successfully!');
                        loadUsers(); // Reload users
                    } else {
                        const error = await response.json();
                        alert('Error deleting user: ' + (error.message || 'Unknown error'));
                    }
                } catch (error) {
                    console.error('Error deleting user:', error);
                    alert('Error deleting user');
                }
            }
        }

        // Load users on page load
        loadUsers();
    </script>
</body>
</html>
