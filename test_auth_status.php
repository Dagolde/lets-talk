<?php

echo "Testing Authentication Status...\n\n";

// Test 1: Check if the test user exists and can login
echo "1. Testing user authentication...\n";

// First, try to send login code to the test phone
$loginUrl = 'http://192.168.1.106:8000/api/send-login-code';
$loginData = [
    'phone' => '09034057885'
];

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

echo "Login Code Request - HTTP Status: $loginHttpCode\n";
echo "Response: $loginResponse\n\n";

if ($loginHttpCode === 200) {
    echo "✅ User exists and can receive login codes\n\n";
    
    // Now try to verify login code
    echo "2. Testing login verification...\n";
    $verifyLoginUrl = 'http://192.168.1.106:8000/api/verify-login-code';
    $verifyLoginData = [
        'phone' => '09034057885',
        'code' => '123456' // Using the predictable test code
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $verifyLoginUrl);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($verifyLoginData));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    
    $verifyLoginResponse = curl_exec($ch);
    $verifyLoginHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "Login Verification - HTTP Status: $verifyLoginHttpCode\n";
    echo "Response: $verifyLoginResponse\n\n";
    
    if ($verifyLoginHttpCode === 200) {
        $verifyData = json_decode($verifyLoginResponse, true);
        if ($verifyData['success'] && isset($verifyData['data']['token'])) {
            $token = $verifyData['data']['token'];
            echo "✅ Login successful! Token obtained.\n";
            echo "Token: " . substr($token, 0, 20) . "...\n\n";
            
            // Test 3: Try to access a protected endpoint
            echo "3. Testing protected endpoint access...\n";
            $protectedUrl = 'http://192.168.1.106:8000/api/user';
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $protectedUrl);
            curl_setopt($ch, CURLOPT_HTTPGET, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'Accept: application/json',
                'Authorization: Bearer ' . $token
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 10);
            
            $protectedResponse = curl_exec($ch);
            $protectedHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            echo "Protected Endpoint - HTTP Status: $protectedHttpCode\n";
            echo "Response: $protectedResponse\n\n";
            
            if ($protectedHttpCode === 200) {
                echo "✅ Authentication working correctly!\n";
                echo "User can access protected endpoints.\n\n";
            } else {
                echo "❌ Authentication failed for protected endpoints.\n\n";
            }
            
            // Test 4: Try to access chats endpoint
            echo "4. Testing chats endpoint...\n";
            $chatsUrl = 'http://192.168.1.106:8000/api/chats';
            
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $chatsUrl);
            curl_setopt($ch, CURLOPT_HTTPGET, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json',
                'Accept: application/json',
                'Authorization: Bearer ' . $token
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_TIMEOUT, 10);
            
            $chatsResponse = curl_exec($ch);
            $chatsHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            echo "Chats Endpoint - HTTP Status: $chatsHttpCode\n";
            echo "Response: $chatsResponse\n\n";
            
            if ($chatsHttpCode === 200) {
                echo "✅ Chats endpoint accessible!\n";
            } else {
                echo "❌ Chats endpoint failed!\n";
            }
            
        } else {
            echo "❌ Login verification failed - no token received.\n";
        }
    } else {
        echo "❌ Login verification failed.\n";
    }
} else {
    echo "❌ User does not exist or cannot receive login codes.\n";
    echo "This suggests the user registration may have failed.\n\n";
}

echo "\nTest completed.\n";
?>
