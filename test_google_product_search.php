<?php

// Test script to verify Google-based product search
echo "Testing Google Product Search Service...\n\n";

// Test 1: Search for iPhone
echo "Test 1: Searching for 'iPhone'\n";
echo "Expected: Real product data from Google search with direct purchase links\n\n";

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
            
            // Check if URL is a real purchase link
            if (strpos($product['url'], 'amazon.com') !== false) {
                echo "  ✓ Direct Amazon link\n";
            } elseif (strpos($product['url'], 'ebay.com') !== false) {
                echo "  ✓ Direct eBay link\n";
            } elseif (strpos($product['url'], 'walmart.com') !== false) {
                echo "  ✓ Direct Walmart link\n";
            } elseif (strpos($product['url'], 'bestbuy.com') !== false) {
                echo "  ✓ Direct Best Buy link\n";
            } else {
                echo "  ? Generic search link\n";
            }
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
echo "Expected: Real product data with direct purchase links\n\n";

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
echo "1. Real product names from Google search\n";
echo "2. Direct purchase links to retailer websites\n";
echo "3. Actual prices from search results\n";
echo "4. Retailer identification (Amazon, eBay, Walmart, etc.)\n";
echo "5. Google search suggestions\n";
echo "\nHow it works:\n";
echo "- Searches Google Shopping first for structured product data\n";
echo "- Falls back to regular Google search for product information\n";
echo "- Extracts real product names, prices, and purchase links\n";
echo "- Provides direct links to buy products from retailer websites\n";
?>
