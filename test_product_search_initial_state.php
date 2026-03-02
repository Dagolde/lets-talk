<?php

// Test script to verify product search initial state
echo "Testing Product Search Initial State...\n\n";

// Test 1: No query provided
echo "Test 1: No query provided\n";
echo "Expected: Empty results array\n";

$url = 'http://localhost:8000/api/product-search';
$headers = [
    'Content-Type: application/json',
    'Accept: application/json',
    'Authorization: Bearer test_token' // You'll need a valid token
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_HTTPGET, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n\n";

// Test 2: With query provided
echo "Test 2: With query provided\n";
echo "Expected: Search results from Google\n";

$url = 'http://localhost:8000/api/product-search?query=iPhone';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_HTTPGET, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n\n";

// Test 3: Suggestions endpoint
echo "Test 3: Product suggestions\n";
echo "Expected: Search suggestions from Google\n";

$url = 'http://localhost:8000/api/product-search/suggestions?query=iPhone';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_HTTPGET, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n\n";

echo "Testing completed!\n";
?>
