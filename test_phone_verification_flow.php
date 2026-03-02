<?php

echo "🔍 Testing Phone Verification Flow for Existing Users\n";
echo "==================================================\n\n";

// Test data
$testPhone = '09034057885';
$testName = 'Test User';

// Step 1: Check if user exists
echo "1. Checking if user exists in database...\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/user');
curl_setopt($ch, CURLOPT_HTTPGET, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Database check response: $httpCode\n";
echo "Response: $response\n\n";

// Step 2: Send phone verification (this should trigger login flow for existing user)
echo "2. Sending phone verification for existing user...\n";
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

echo "Send verification response: $httpCode\n";
echo "Response: $response\n\n";

$responseData = json_decode($response, true);

if ($httpCode === 200 && $responseData['success']) {
    echo "✅ Phone verification sent successfully\n";
    
    // Step 3: Try to verify with the test code
    echo "3. Verifying with test code (123456)...\n";
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
    
    echo "Verify login code response: $httpCode\n";
    echo "Response: $response\n\n";
    
    $verifyData = json_decode($response, true);
    
    if ($httpCode === 200 && $verifyData['success']) {
        echo "✅ Login successful! Token obtained.\n";
        $token = $verifyData['data']['token'];
        
        // Step 4: Test accessing protected endpoint
        echo "4. Testing protected endpoint access...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/user');
        curl_setopt($ch, CURLOPT_HTTPGET, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "Protected endpoint response: $httpCode\n";
        echo "Response: $response\n\n";
        
        if ($httpCode === 200) {
            echo "✅ Protected endpoint accessible with token\n";
        } else {
            echo "❌ Protected endpoint not accessible\n";
        }
    } else {
        echo "❌ Login verification failed\n";
    }
} else {
    echo "❌ Phone verification failed\n";
}

echo "\n🎯 Phone verification flow testing completed!\n";
