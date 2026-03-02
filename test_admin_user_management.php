<?php

echo "🔍 Testing Admin User Management\n";
echo "================================\n\n";

// First, login as admin
echo "1. Logging in as admin...\n";
$loginData = [
    'email' => 'admin@letstalk.com',
    'password' => 'admin123'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/admin/login');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$responseData = json_decode($response, true);

if ($httpCode === 200 && isset($responseData['token'])) {
    $token = $responseData['token'];
    echo "✅ Admin login successful\n\n";
    
    // Test getting users
    echo "2. Testing get users...\n";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/admin/users');
    curl_setopt($ch, CURLOPT_HTTPGET, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode === 200) {
        $usersData = json_decode($response, true);
        echo "✅ Get users successful\n";
        echo "   Total users: " . ($usersData['data']['total'] ?? 0) . "\n";
        echo "   Current page: " . ($usersData['data']['current_page'] ?? 1) . "\n";
        echo "   Users per page: " . ($usersData['data']['per_page'] ?? 20) . "\n";
        
        if (isset($usersData['data']['data']) && count($usersData['data']['data']) > 0) {
            echo "   Sample user: " . $usersData['data']['data'][0]['name'] . " (ID: " . $usersData['data']['data'][0]['id'] . ")\n";
        }
    } else {
        echo "❌ Get users failed: $httpCode\n";
        echo "Response: $response\n";
    }
    
    // Test creating a user
    echo "\n3. Testing create user...\n";
    $newUserData = [
        'name' => 'Test User ' . time(),
        'email' => 'test' . time() . '@example.com',
        'phone' => '+1234567890' . time(),
        'password' => 'password123'
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/admin/users');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($newUserData));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode === 200 || $httpCode === 201) {
        $createData = json_decode($response, true);
        echo "✅ Create user successful\n";
        echo "   Created user: " . $createData['user']['name'] . " (ID: " . $createData['user']['id'] . ")\n";
        $createdUserId = $createData['user']['id'];
        
        // Test updating user status
        echo "\n4. Testing update user status...\n";
        $statusData = [
            'action' => 'block',
            'reason' => 'Test blocking'
        ];
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "http://192.168.1.106:8000/api/admin/users/{$createdUserId}/status");
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($statusData));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode === 200) {
            echo "✅ Update user status successful\n";
            
            // Test unblocking user
            echo "\n5. Testing unblock user...\n";
            $unblockData = [
                'action' => 'unblock',
                'reason' => 'Test unblocking'
            ];
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, "http://192.168.1.106:8000/api/admin/users/{$createdUserId}/status");
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($unblockData));
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $token,
                'Content-Type: application/json',
                'Accept: application/json'
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            if ($httpCode === 200) {
                echo "✅ Unblock user successful\n";
                
                // Test deleting user
                echo "\n6. Testing delete user...\n";
                $ch = curl_init();
                curl_setopt($ch, CURLOPT_URL, "http://192.168.1.106:8000/api/admin/users/{$createdUserId}");
                curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
                curl_setopt($ch, CURLOPT_HTTPHEADER, [
                    'Authorization: Bearer ' . $token,
                    'Accept: application/json'
                ]);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                $response = curl_exec($ch);
                $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                curl_close($ch);
                
                if ($httpCode === 200) {
                    echo "✅ Delete user successful\n";
                } else {
                    echo "❌ Delete user failed: $httpCode\n";
                    echo "Response: $response\n";
                }
            } else {
                echo "❌ Unblock user failed: $httpCode\n";
                echo "Response: $response\n";
            }
        } else {
            echo "❌ Update user status failed: $httpCode\n";
            echo "Response: $response\n";
        }
    } else {
        echo "❌ Create user failed: $httpCode\n";
        echo "Response: $response\n";
    }
    
    // Test dashboard
    echo "\n7. Testing admin dashboard...\n";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/admin/dashboard');
    curl_setopt($ch, CURLOPT_HTTPGET, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($httpCode === 200) {
        $dashboardData = json_decode($response, true);
        echo "✅ Dashboard successful\n";
        echo "   Total users: " . ($dashboardData['data']['stats']['total_users'] ?? 0) . "\n";
        echo "   Active chats: " . ($dashboardData['data']['stats']['active_chats'] ?? 0) . "\n";
        echo "   Total payments: " . ($dashboardData['data']['stats']['total_payments'] ?? 0) . "\n";
    } else {
        echo "❌ Dashboard failed: $httpCode\n";
        echo "Response: $response\n";
    }
    
} else {
    echo "❌ Admin login failed: $httpCode\n";
    echo "Response: $response\n";
}

echo "\n🎯 Admin user management testing completed!\n";
