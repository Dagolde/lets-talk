<?php

// Test admin login flow
echo "Testing Admin Login Flow...\n\n";

// Test 1: Check if admin login endpoint exists
echo "1. Testing admin login endpoint...\n";
$url = 'http://192.168.1.106:8000/api/admin/login';

$data = [
    'email' => 'admin@letstalk.com',
    'password' => 'admin123'
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
    echo "Response Analysis:\n";
    echo "- Has 'success' field: " . (isset($responseData['success']) ? 'Yes' : 'No') . "\n";
    echo "- Has 'token' field: " . (isset($responseData['token']) ? 'Yes' : 'No') . "\n";
    echo "- Has 'user' field: " . (isset($responseData['user']) ? 'Yes' : 'No') . "\n";
    echo "- Has 'message' field: " . (isset($responseData['message']) ? 'Yes' : 'No') . "\n";
    
    if (isset($responseData['token'])) {
        echo "\n2. Testing admin dashboard endpoint with token...\n";
        
        $dashboardUrl = 'http://192.168.1.106:8000/api/admin/dashboard';
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $dashboardUrl);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $responseData['token'],
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);
        
        $dashboardResponse = curl_exec($ch);
        $dashboardHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "Dashboard HTTP Status Code: $dashboardHttpCode\n";
        echo "Dashboard Response: $dashboardResponse\n\n";
    }
} else {
    echo "Login failed with status code: $httpCode\n";
}

echo "Test completed.\n";
?>
