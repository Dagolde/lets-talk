<?php

echo "Testing Network Connection...\n\n";

// Test if the server is running on the network IP
$url = 'http://192.168.1.106:8000';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_NOBODY, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "Testing connection to: $url\n";
echo "HTTP Status Code: $httpCode\n";

if ($error) {
    echo "cURL Error: $error\n";
} else {
    echo "Connection successful!\n";
}

// Test the API endpoint
echo "\nTesting API endpoint...\n";
$apiUrl = 'http://192.168.1.106:8000/api/admin/login';

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_NOBODY, true);

$apiResponse = curl_exec($ch);
$apiHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$apiError = curl_error($ch);
curl_close($ch);

echo "API URL: $apiUrl\n";
echo "API HTTP Status Code: $apiHttpCode\n";

if ($apiError) {
    echo "API cURL Error: $apiError\n";
} else {
    echo "API endpoint accessible!\n";
}

echo "\nTest completed.\n";
?>
