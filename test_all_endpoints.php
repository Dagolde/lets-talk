<?php

echo "🔍 Testing All API Endpoints for 500 Errors\n";
echo "==========================================\n\n";

// First, get a valid token by logging in
echo "1. Getting authentication token...\n";
$loginData = [
    'phone' => '09034057885',
    'name' => 'Test User'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/send-phone-verification');
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

if ($httpCode === 200) {
    echo "✅ Phone verification sent successfully\n";
    
    // Now verify OTP and get token
    $verifyData = [
        'phone' => '09034057885',
        'name' => 'Test User',
        'otp' => '123456'
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/verify-phone-and-register');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($verifyData));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    $responseData = json_decode($response, true);
    
    if ($httpCode === 200 && isset($responseData['data']['token'])) {
        $token = $responseData['data']['token'];
        echo "✅ Authentication successful, token obtained\n\n";
        
        // Test all endpoints
        $endpoints = [
            '/user' => 'GET',
            '/chats' => 'GET',
            '/product-search' => 'GET',
            '/notifications' => 'GET',
            '/contacts' => 'GET',
            '/qr-codes' => 'GET',
            '/payments' => 'GET',
            '/wallet' => 'GET',
        ];
        
        foreach ($endpoints as $endpoint => $method) {
            echo "Testing $method $endpoint...\n";
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api' . $endpoint);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $token,
                'Accept: application/json'
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            $error = curl_error($ch);
            curl_close($ch);
            
            if ($error) {
                echo "❌ cURL Error: $error\n";
            } elseif ($httpCode === 500) {
                echo "❌ 500 Error on $endpoint\n";
                $responseData = json_decode($response, true);
                if (isset($responseData['message'])) {
                    echo "   Error: " . $responseData['message'] . "\n";
                }
            } elseif ($httpCode === 200 || $httpCode === 201) {
                echo "✅ Success ($httpCode)\n";
            } else {
                echo "⚠️  Status: $httpCode\n";
            }
            echo "\n";
        }
        
    } else {
        echo "❌ Failed to get token: $httpCode\n";
        echo "Response: $response\n";
    }
} else {
    echo "❌ Failed to send phone verification: $httpCode\n";
    echo "Response: $response\n";
}

echo "🎯 Testing completed!\n";
