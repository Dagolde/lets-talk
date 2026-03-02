<?php

echo "🔍 Testing Logout and Navigation\n";
echo "================================\n\n";

// First, login as a user to get a token
echo "1. Logging in as a test user...\n";
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
        echo "✅ User login successful, token obtained\n\n";
        
        // Test accessing a protected endpoint with the token
        echo "2. Testing access to protected endpoint...\n";
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
        
        if ($httpCode === 200) {
            echo "✅ Protected endpoint accessible with token\n";
            
            // Test logout
            echo "\n3. Testing logout...\n";
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/logout');
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $token,
                'Accept: application/json'
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            if ($httpCode === 200) {
                echo "✅ Logout successful\n";
                
                // Test that the token is now invalid
                echo "\n4. Testing that token is invalid after logout...\n";
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
                
                if ($httpCode === 401) {
                    echo "✅ Token is properly invalidated after logout\n";
                    echo "✅ User should be redirected to login page\n";
                } else {
                    echo "❌ Token still valid after logout (HTTP $httpCode)\n";
                }
            } else {
                echo "❌ Logout failed: $httpCode\n";
                echo "Response: $response\n";
            }
        } else {
            echo "❌ Protected endpoint not accessible: $httpCode\n";
            echo "Response: $response\n";
        }
    } else {
        echo "❌ Failed to get user token: $httpCode\n";
        echo "Response: $response\n";
    }
} else {
    echo "❌ Failed to send phone verification: $httpCode\n";
    echo "Response: $response\n";
}

echo "\n🎯 Logout and navigation testing completed!\n";
echo "\n📱 Mobile App Logout Flow:\n";
echo "1. User taps logout button in profile page\n";
echo "2. AuthProvider.logout() is called\n";
echo "3. API service clears token and calls /logout endpoint\n";
echo "4. Local storage is cleared\n";
echo "5. Navigation to /phone-verification page\n";
echo "6. User is now on the login page\n";
