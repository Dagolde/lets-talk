<?php

echo "🔍 Testing Logout Endpoint\n";
echo "=========================\n\n";

// Test data
$testPhone = '09034057885';
$testName = 'Test User';

// Step 1: Login to get token
echo "1. 🔐 Authentication Test\n";
echo "-------------------------\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/send-phone-verification');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'phone' => $testPhone,
    'name' => $testName
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

$responseData = json_decode($response, true);

if ($httpCode === 200 && $responseData['success']) {
    echo "✅ Phone verification sent successfully\n";
    
    // Verify login code
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/verify-login-code');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'phone' => $testPhone,
        'code' => '123456'
    ]));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    $verifyData = json_decode($response, true);
    
    if ($httpCode === 200 && $verifyData['success']) {
        echo "✅ Login successful! Token obtained.\n";
        $token = $verifyData['data']['token'];
        
        echo "\n2. 🚪 Logout Test\n";
        echo "----------------\n";
        
        // Test logout
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/logout');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "Logout Response Code: $httpCode\n";
        echo "Logout Response: $response\n";
        
        if ($httpCode === 200) {
            echo "✅ Logout successful!\n";
        } else {
            echo "❌ Logout failed with status code: $httpCode\n";
            echo "Response: $response\n";
        }
        
    } else {
        echo "❌ Login verification failed\n";
        echo "Response: $response\n";
    }
} else {
    echo "❌ Phone verification failed\n";
    echo "Response: $response\n";
}

echo "\n🔍 Debug Information:\n";
echo "====================\n";

// Check if Laravel is running
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/user');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 5);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Laravel API Status: $httpCode\n";
echo "Response: $response\n";

echo "\nTest completed!\n";
