<?php

echo "Testing Token Storage and Retrieval...\n\n";

// Test 1: Login and get a token
echo "1. Logging in to get a token...\n";

// Send login code
$loginUrl = 'http://192.168.1.106:8000/api/send-login-code';
$loginData = ['phone' => '09034057885'];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $loginUrl);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$loginResponse = curl_exec($ch);
$loginHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($loginHttpCode === 200) {
    echo "✅ Login code sent successfully\n";
    
    // Verify login code
    $verifyUrl = 'http://192.168.1.106:8000/api/verify-login-code';
    $verifyData = [
        'phone' => '09034057885',
        'code' => '123456'
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
    
    if ($verifyHttpCode === 200) {
        $verifyData = json_decode($verifyResponse, true);
        if ($verifyData['success'] && isset($verifyData['data']['token'])) {
            $token = $verifyData['data']['token'];
            echo "✅ Login successful! Token obtained.\n";
            echo "Token: " . substr($token, 0, 20) . "...\n\n";
            
            // Test 2: Test multiple protected endpoints with the same token
            echo "2. Testing multiple protected endpoints...\n";
            
            $endpoints = [
                '/user' => 'User Profile',
                '/chats' => 'Chats',
                '/product-search' => 'Product Search',
                '/notifications' => 'Notifications',
                '/contacts' => 'Contacts',
                '/qr-codes' => 'QR Codes',
                '/payments' => 'Payments',
                '/wallet' => 'Wallet'
            ];
            
            foreach ($endpoints as $endpoint => $name) {
                echo "   Testing $name endpoint...\n";
                
                $ch = curl_init();
                curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api' . $endpoint);
                curl_setopt($ch, CURLOPT_HTTPGET, true);
                curl_setopt($ch, CURLOPT_HTTPHEADER, [
                    'Content-Type: application/json',
                    'Accept: application/json',
                    'Authorization: Bearer ' . $token
                ]);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_TIMEOUT, 10);
                
                $response = curl_exec($ch);
                $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                curl_close($ch);
                
                if ($httpCode === 200) {
                    echo "   ✅ $name endpoint accessible (200)\n";
                } elseif ($httpCode === 401) {
                    echo "   ❌ $name endpoint unauthorized (401)\n";
                } else {
                    echo "   ⚠️  $name endpoint returned $httpCode\n";
                }
            }
            
            echo "\n3. Testing logout...\n";
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
            
            if ($logoutHttpCode === 200) {
                echo "✅ Logout successful!\n";
            } else {
                echo "❌ Logout failed with status $logoutHttpCode\n";
            }
            
        } else {
            echo "❌ Login verification failed - no token received.\n";
        }
    } else {
        echo "❌ Login verification failed with status $verifyHttpCode.\n";
    }
} else {
    echo "❌ Failed to send login code with status $loginHttpCode.\n";
}

echo "\nTest completed.\n";
?>
