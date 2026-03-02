<?php

echo "Testing Logout Flow...\n\n";

// Test 1: Try to logout without token (should return 401)
echo "1. Testing logout without authentication token...\n";
$url = 'http://192.168.1.106:8000/api/logout';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status Code: $httpCode\n";
echo "Response: $response\n\n";

if ($httpCode === 401) {
    echo "✅ Expected 401 Unauthorized - logout requires authentication\n\n";
} else {
    echo "❌ Unexpected response - logout should require authentication\n\n";
}

// Test 2: Login first, then logout
echo "2. Testing login and logout flow...\n";

// First, register a test user
echo "   a. Registering test user...\n";
$registerUrl = 'http://192.168.1.106:8000/api/send-phone-verification';
$registerData = [
    'phone' => '09034057886',
    'name' => 'Test User'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $registerUrl);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($registerData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$registerResponse = curl_exec($ch);
$registerHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($registerHttpCode === 200) {
    echo "   ✅ Phone verification sent\n";
    
    // Now verify and register
    echo "   b. Verifying OTP and registering...\n";
    $verifyUrl = 'http://192.168.1.106:8000/api/verify-phone-and-register';
    $verifyData = [
        'phone' => '09034057886',
        'name' => 'Test User',
        'otp' => '123456'
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $verifyUrl);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($verifyData));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    
    $verifyResponse = curl_exec($ch);
    $verifyHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($verifyHttpCode === 201) {
        $verifyData = json_decode($verifyResponse, true);
        $token = $verifyData['data']['token'];
        echo "   ✅ User registered successfully\n";
        echo "   Token: " . substr($token, 0, 20) . "...\n\n";
        
        // Now test logout with valid token
        echo "   c. Testing logout with valid token...\n";
        $logoutUrl = 'http://192.168.1.106:8000/api/logout';
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $logoutUrl);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json',
            'Authorization: Bearer ' . $token
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        
        $logoutResponse = curl_exec($ch);
        $logoutHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "   HTTP Status Code: $logoutHttpCode\n";
        echo "   Response: $logoutResponse\n\n";
        
        if ($logoutHttpCode === 200) {
            echo "   ✅ Logout successful!\n\n";
        } else {
            echo "   ❌ Logout failed!\n\n";
        }
        
        // Test 3: Try to logout again with the same token (should fail)
        echo "   d. Testing logout with expired token...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $logoutUrl);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json',
            'Authorization: Bearer ' . $token
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        
        $logoutResponse2 = curl_exec($ch);
        $logoutHttpCode2 = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "   HTTP Status Code: $logoutHttpCode2\n";
        echo "   Response: $logoutResponse2\n\n";
        
        if ($logoutHttpCode2 === 401) {
            echo "   ✅ Expected 401 - token was properly invalidated\n";
        } else {
            echo "   ❌ Unexpected response - token should be invalid\n";
        }
        
    } else {
        echo "   ❌ User registration failed: $verifyResponse\n";
    }
} else {
    echo "   ❌ Phone verification failed: $registerResponse\n";
}

echo "\nTest completed.\n";
?>
