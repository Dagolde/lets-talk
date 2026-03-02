<?php

// Test script to verify real product search functionality
echo "Testing Real Product Search Service...\n\n";

// Test 1: Search for iPhone
echo "Test 1: Searching for 'iPhone'\n";
echo "Expected: Real product data from Amazon, eBay, Walmart, Best Buy\n\n";

$url = 'http://localhost:8000/api/product-search?query=iPhone';
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
curl_setopt($ch, CURLOPT_TIMEOUT, 60); // Longer timeout for real searches

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
if ($httpCode == 200) {
    $data = json_decode($response, true);
    if (isset($data['data']['results'])) {
        $results = $data['data']['results'];
        echo "Found " . count($results) . " products\n";
        
        foreach (array_slice($results, 0, 3) as $index => $product) {
            echo "\nProduct " . ($index + 1) . ":\n";
            echo "  Name: " . $product['name'] . "\n";
            echo "  Price: $" . $product['price'] . "\n";
            echo "  Retailer: " . $product['retailer'] . "\n";
            echo "  Image: " . $product['image'] . "\n";
            echo "  URL: " . $product['url'] . "\n";
        }
    } else {
        echo "No results found\n";
    }
} else {
    echo "Error: $response\n";
}

echo "\n" . str_repeat("=", 50) . "\n\n";

// Test 2: Search for Samsung TV
echo "Test 2: Searching for 'Samsung TV'\n";
echo "Expected: Real product data from multiple retailers\n\n";

$url = 'http://localhost:8000/api/product-search?query=Samsung TV';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_HTTPGET, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 60);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
if ($httpCode == 200) {
    $data = json_decode($response, true);
    if (isset($data['data']['results'])) {
        $results = $data['data']['results'];
        echo "Found " . count($results) . " products\n";
        
        foreach (array_slice($results, 0, 3) as $index => $product) {
            echo "\nProduct " . ($index + 1) . ":\n";
            echo "  Name: " . $product['name'] . "\n";
            echo "  Price: $" . $product['price'] . "\n";
            echo "  Retailer: " . $product['retailer'] . "\n";
            echo "  Image: " . $product['image'] . "\n";
            echo "  URL: " . $product['url'] . "\n";
        }
    } else {
        echo "No results found\n";
    }
} else {
    echo "Error: $response\n";
}

echo "\n" . str_repeat("=", 50) . "\n\n";

// Test 3: Product suggestions
echo "Test 3: Product suggestions for 'MacBook'\n";
echo "Expected: Search suggestions from Google\n\n";

$url = 'http://localhost:8000/api/product-search/suggestions?query=MacBook';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_HTTPGET, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
if ($httpCode == 200) {
    $data = json_decode($response, true);
    if (isset($data['data'])) {
        $suggestions = $data['data'];
        echo "Found " . count($suggestions) . " suggestions:\n";
        foreach ($suggestions as $suggestion) {
            echo "  - $suggestion\n";
        }
    } else {
        echo "No suggestions found\n";
    }
} else {
    echo "Error: $response\n";
}

echo "\nTesting completed!\n";
echo "\nKey Features to Verify:\n";
echo "1. Real product images (not placeholder URLs)\n";
echo "2. Actual store links (Amazon, eBay, Walmart, Best Buy)\n";
echo "3. Real product names and descriptions\n";
echo "4. Actual prices from retailers\n";
echo "5. Multiple retailer options for each product\n";
?>
