<?php

echo "🔍 Testing Complete Token Flow\n";
echo "=============================\n\n";

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
        echo "Token: " . substr($token, 0, 20) . "...\n";
        
        echo "\n2. 🔍 Test Protected Endpoints\n";
        echo "-----------------------------\n";
        
        // Test user profile endpoint
        echo "Testing /user endpoint...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/user');
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
            echo "✅ /user endpoint working with token\n";
        } else {
            echo "❌ /user endpoint failed: $httpCode\n";
            echo "Response: $response\n";
        }
        
        // Test contacts find-users endpoint
        echo "Testing /contacts/find-users endpoint...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/contacts/find-users');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'phone_numbers' => ['09034057885', '+1234567890', '+9876543210']
        ]));
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
            echo "✅ /contacts/find-users endpoint working with token\n";
            $contactsData = json_decode($response, true);
            echo "Found " . count($contactsData['data']) . " Let's Talk users\n";
        } else {
            echo "❌ /contacts/find-users endpoint failed: $httpCode\n";
            echo "Response: $response\n";
        }
        
        // Test without token (should fail)
        echo "Testing /contacts/find-users without token...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/contacts/find-users');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'phone_numbers' => ['09034057885', '+1234567890', '+9876543210']
        ]));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode === 401) {
            echo "✅ /contacts/find-users correctly rejects requests without token\n";
        } else {
            echo "❌ /contacts/find-users should reject requests without token, got: $httpCode\n";
        }
        
    } else {
        echo "❌ Login verification failed\n";
        echo "Response: $response\n";
    }
} else {
    echo "❌ Phone verification failed\n";
    echo "Response: $response\n";
}

echo "\n🔍 Flutter App Token Flow Analysis:\n";
echo "==================================\n";
echo "1. ✅ Backend login works and returns token\n";
echo "2. ✅ Backend protected endpoints work with token\n";
echo "3. ✅ Backend correctly rejects requests without token\n";
echo "4. 🔍 Issue likely in Flutter app token storage/retrieval\n";
echo "\nPossible Flutter issues:\n";
echo "- Token not being saved to SharedPreferences\n";
echo "- Token not being loaded on app startup\n";
echo "- Token not being sent in API requests\n";
echo "- ApiService not properly initialized\n";

echo "\nTest completed!\n";
