<?php
/**
 * Admin API Test
 */

echo "=== Admin API Test ===\n\n";

$baseUrl = 'http://127.0.0.1:8000/api';

// Test 1: Admin Login
echo "Test 1: Admin Login... ";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $baseUrl . '/admin/login');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'email' => 'admin@letstalk.com',
    'password' => 'admin123'
]));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'Content-Type: application/json'
]);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

if ($error) {
    echo "❌ FAILED (cURL Error: $error)\n";
} else {
    echo "✅ SUCCESS (HTTP Code: $httpCode)\n";
    $data = json_decode($response, true);
    if ($httpCode === 200 && isset($data['token'])) {
        echo "✅ Login successful! Token received.\n";
        $token = $data['token'];
        
        // Test 2: Get Dashboard
        echo "\nTest 2: Get Dashboard... ";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $baseUrl . '/admin/dashboard');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Accept: application/json',
            'Content-Type: application/json',
            'Authorization: Bearer ' . $token
        ]);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            echo "❌ FAILED (cURL Error: $error)\n";
        } else {
            echo "✅ SUCCESS (HTTP Code: $httpCode)\n";
            $data = json_decode($response, true);
            if ($httpCode === 200) {
                echo "✅ Dashboard data retrieved successfully!\n";
                if (isset($data['data']['stats'])) {
                    echo "✅ Stats data present: " . count($data['data']['stats']) . " statistics\n";
                }
            } else {
                echo "❌ Dashboard request failed: " . ($data['message'] ?? 'Unknown error') . "\n";
            }
        }
        
        // Test 3: Get Settings
        echo "\nTest 3: Get Settings... ";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $baseUrl . '/admin/settings');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Accept: application/json',
            'Content-Type: application/json',
            'Authorization: Bearer ' . $token
        ]);
        curl_setopt($ch, CURLOPT_TIMEOUT, 10);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            echo "❌ FAILED (cURL Error: $error)\n";
        } else {
            echo "✅ SUCCESS (HTTP Code: $httpCode)\n";
            $data = json_decode($response, true);
            if ($httpCode === 200) {
                echo "✅ Settings retrieved successfully!\n";
                if (isset($data['settings'])) {
                    $paymentSettings = ['stripe_enabled', 'paystack_enabled', 'flutterwave_enabled'];
                    $found = 0;
                    foreach ($paymentSettings as $setting) {
                        if (isset($data['settings'][$setting])) {
                            $found++;
                        }
                    }
                    echo "✅ Payment gateway settings found: $found/3\n";
                }
            } else {
                echo "❌ Settings request failed: " . ($data['message'] ?? 'Unknown error') . "\n";
            }
        }
        
    } else {
        echo "❌ Login failed: " . ($data['message'] ?? 'Unknown error') . "\n";
    }
}

echo "\n=== Test Complete ===\n";
?>
