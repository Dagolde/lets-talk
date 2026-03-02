<?php

echo "Testing Phone Verification Flow...\n\n";

// Test 1: Send phone verification
echo "1. Testing send phone verification...\n";
$url = 'http://192.168.1.106:8000/api/send-phone-verification';

$data = [
    'phone' => '09034057885',
    'name' => 'Ephraim Yusuf'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
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

if ($httpCode === 200) {
    $responseData = json_decode($response, true);
    echo "Phone verification sent successfully!\n";
    
    // For testing, we'll use a mock OTP code
    $mockOtp = '123456';
    echo "Using mock OTP code: $mockOtp\n\n";
    
    // Test 2: Verify OTP and register
    echo "2. Testing verify OTP and register...\n";
    $verifyUrl = 'http://192.168.1.106:8000/api/verify-phone-and-register';
    
    $verifyData = [
        'phone' => '09034057885',
        'name' => 'Ephraim Yusuf',
        'otp' => $mockOtp
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
    
    echo "HTTP Status Code: $verifyHttpCode\n";
    echo "Response: $verifyResponse\n\n";
    
    if ($verifyHttpCode === 201) {
        echo "✅ Phone verification and registration successful!\n";
    } else {
        echo "❌ Phone verification and registration failed!\n";
    }
} else {
    echo "❌ Failed to send phone verification!\n";
}

echo "\nTest completed.\n";
?>
