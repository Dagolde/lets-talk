<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Let's Talk</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen flex items-center justify-center">
    <div class="max-w-md w-full space-y-8 p-8">
        <div class="bg-white rounded-lg shadow-xl p-8">
            <!-- Header -->
            <div class="text-center mb-8">
                <div class="mx-auto h-16 w-16 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-full flex items-center justify-center mb-4">
                    <i class="fas fa-comments text-white text-2xl"></i>
                </div>
                <h2 class="text-3xl font-bold text-gray-900">Admin Login</h2>
                <p class="mt-2 text-sm text-gray-600">Let's Talk Management System</p>
            </div>

            <!-- Login Form -->
            <form id="loginForm" class="space-y-6">
                <div>
                    <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-envelope mr-2"></i>Email Address
                    </label>
                    <input id="email" name="email" type="email" required 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition duration-200"
                           placeholder="admin@letstalk.com">
                </div>

                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-lock mr-2"></i>Password
                    </label>
                    <input id="password" name="password" type="password" required 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition duration-200"
                           placeholder="••••••••">
                </div>

                <div class="flex items-center justify-between">
                    <div class="flex items-center">
                        <input id="remember" name="remember" type="checkbox" 
                               class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                        <label for="remember" class="ml-2 block text-sm text-gray-700">
                            Remember me
                        </label>
                    </div>
                    <a href="#" class="text-sm text-blue-600 hover:text-blue-500 transition duration-200">
                        Forgot password?
                    </a>
                </div>

                <button type="submit" 
                        class="w-full bg-gradient-to-r from-blue-500 to-indigo-600 text-white py-3 px-4 rounded-lg hover:from-blue-600 hover:to-indigo-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition duration-200 font-medium">
                    <i class="fas fa-sign-in-alt mr-2"></i>Sign In
                </button>
            </form>

            <!-- Status Messages -->
            <div id="statusMessage" class="mt-4 hidden">
                <div id="successMessage" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded hidden">
                    <i class="fas fa-check-circle mr-2"></i>
                    <span id="successText"></span>
                </div>
                <div id="errorMessage" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded hidden">
                    <i class="fas fa-exclamation-circle mr-2"></i>
                    <span id="errorText"></span>
                </div>
            </div>

            <!-- Loading Spinner -->
            <div id="loadingSpinner" class="mt-4 hidden text-center">
                <div class="inline-flex items-center">
                    <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span class="text-blue-600">Signing in...</span>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="text-center text-sm text-gray-500">
            <p>&copy; 2024 Let's Talk. All rights reserved.</p>
        </div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            const loadingSpinner = document.getElementById('loadingSpinner');
            const statusMessage = document.getElementById('statusMessage');
            const successMessage = document.getElementById('successMessage');
            const errorMessage = document.getElementById('errorMessage');
            
            // Show loading spinner
            loadingSpinner.classList.remove('hidden');
            statusMessage.classList.add('hidden');
            
            try {
                const response = await fetch('http://192.168.1.106:8000/api/admin/login', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
                    },
                    body: JSON.stringify({
                        email: email,
                        password: password
                    })
                });
                
                const data = await response.json();
                console.log('Login response:', data); // Debug log
                
                if (response.ok && data.token) {
                    // Store token
                    localStorage.setItem('admin_token', data.token);
                    localStorage.setItem('admin_user', JSON.stringify(data.user));
                    
                    // Show success message
                    document.getElementById('successText').textContent = data.message || 'Login successful! Redirecting...';
                    successMessage.classList.remove('hidden');
                    statusMessage.classList.remove('hidden');
                    
                    // Redirect to dashboard
                    setTimeout(() => {
                        window.location.href = '/admin/dashboard';
                    }, 1000);
                } else {
                    // Show error message
                    document.getElementById('errorText').textContent = data.message || 'Login failed. Please try again.';
                    errorMessage.classList.remove('hidden');
                    statusMessage.classList.remove('hidden');
                }
            } catch (error) {
                console.error('Login error:', error);
                document.getElementById('errorText').textContent = 'Network error. Please check your connection.';
                errorMessage.classList.remove('hidden');
                statusMessage.classList.remove('hidden');
            } finally {
                loadingSpinner.classList.add('hidden');
            }
        });
    </script>
</body>
</html>
