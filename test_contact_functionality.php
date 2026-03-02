<?php

echo "🔍 Testing Contact Functionality\n";
echo "================================\n\n";

// Test data
$testPhone = '09034057885';
$testName = 'Test User';

// Step 1: Login to get token
echo "1. Logging in to get authentication token...\n";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/send-phone-verification');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'phone' => $testPhone,
    'name' => $testName
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Send verification response: $httpCode\n";
echo "Response: $response\n\n";

$responseData = json_decode($response, true);

if ($httpCode === 200 && $responseData['success']) {
    echo "✅ Phone verification sent successfully\n";
    
    // Step 2: Verify login code
    echo "2. Verifying login code...\n";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/verify-login-code');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'phone' => $testPhone,
        'code' => '123456'
    ]));
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "Verify login code response: $httpCode\n";
    echo "Response: $response\n\n";
    
    $verifyData = json_decode($response, true);
    
    if ($httpCode === 200 && $verifyData['success']) {
        echo "✅ Login successful! Token obtained.\n";
        $token = $verifyData['data']['token'];
        
        // Step 3: Test contact endpoints
        echo "3. Testing contact endpoints...\n";
        
        // Test getting contacts
        echo "3a. Getting user contacts...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/contacts');
        curl_setopt($ch, CURLOPT_HTTPGET, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "Get contacts response: $httpCode\n";
        echo "Response: $response\n\n";
        
        // Test finding Let's Talk users
        echo "3b. Finding Let's Talk users...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/contacts/find-users');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'phone_numbers' => ['09034057885', '+1234567890', '+9876543210']
        ]));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "Find users response: $httpCode\n";
        echo "Response: $response\n\n";
        
        // Test creating a contact
        echo "3c. Creating a new contact...\n";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/contacts');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'name' => 'John Doe',
            'phone' => '+1234567890',
            'email' => 'john.doe@example.com'
        ]));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $token,
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        echo "Create contact response: $httpCode\n";
        echo "Response: $response\n\n";
        
        $contactData = json_decode($response, true);
        
        if ($httpCode === 201 && $contactData['success']) {
            echo "✅ Contact created successfully\n";
            $contactId = $contactData['data']['id'];
            
            // Test toggling favorite
            echo "3d. Toggling contact favorite status...\n";
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, "http://192.168.1.106:8000/api/contacts/$contactId/favorite");
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $token,
                'Accept: application/json'
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            echo "Toggle favorite response: $httpCode\n";
            echo "Response: $response\n\n";
            
            // Test syncing contacts
            echo "3e. Syncing contacts...\n";
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, 'http://192.168.1.106:8000/api/contacts/sync');
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
                'contacts' => [
                    [
                        'name' => 'Jane Smith',
                        'phone' => '+9876543210',
                        'email' => 'jane.smith@example.com'
                    ],
                    [
                        'name' => 'Mike Johnson',
                        'phone' => '+5555555555',
                        'email' => 'mike.johnson@example.com'
                    ]
                ]
            ]));
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Authorization: Bearer ' . $token,
                'Content-Type: application/json',
                'Accept: application/json'
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            
            echo "Sync contacts response: $httpCode\n";
            echo "Response: $response\n\n";
            
        } else {
            echo "❌ Failed to create contact\n";
        }
        
    } else {
        echo "❌ Login verification failed\n";
    }
} else {
    echo "❌ Phone verification failed\n";
}

echo "\n🎯 Contact functionality testing completed!\n";
