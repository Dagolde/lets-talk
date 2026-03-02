<?php
/**
 * Simple Server Test
 */

echo "=== Simple Server Test ===\n\n";

$url = 'http://127.0.0.1:8000/api/admin/dashboard';

echo "Testing URL: $url\n\n";

// Test 1: Basic connection
echo "Test 1: Basic Connection... ";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

if ($error) {
    echo "❌ FAILED (cURL Error: $error)\n";
} else {
    echo "✅ SUCCESS (HTTP Code: $httpCode)\n";
    echo "Response: " . substr($response, 0, 200) . "...\n";
}

// Test 2: Check if server is listening
echo "\nTest 2: Port Check... ";
$connection = @fsockopen('127.0.0.1', 8000, $errno, $errstr, 5);
if ($connection) {
    echo "✅ SUCCESS (Port 8000 is open)\n";
    fclose($connection);
} else {
    echo "❌ FAILED (Port 8000 is not accessible: $errstr)\n";
}

// Test 3: Try a simple GET request
echo "\nTest 3: Simple GET Request... ";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://127.0.0.1:8000');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 5);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

if ($error) {
    echo "❌ FAILED (cURL Error: $error)\n";
} else {
    echo "✅ SUCCESS (HTTP Code: $httpCode)\n";
    if ($httpCode === 200) {
        echo "Laravel server is responding!\n";
    } else {
        echo "Server responded with code: $httpCode\n";
    }
}

echo "\n=== Test Complete ===\n";
?>
