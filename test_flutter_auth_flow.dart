import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Testing Flutter Authentication Flow\n');
  print('=====================================\n');

  // Simulate the authentication flow
  await testAuthenticationFlow();
}

Future<void> testAuthenticationFlow() async {
  const baseUrl = 'http://192.168.1.106:8000/api';
  const testPhone = '09034057885';
  const testName = 'Test User';

  try {
    // Step 1: Send phone verification
    print('1. 📱 Sending phone verification...');
    final verificationResponse = await sendRequest(
      '$baseUrl/send-phone-verification',
      {
        'phone': testPhone,
        'name': testName,
      },
    );

    if (verificationResponse['success']) {
      print('✅ Phone verification sent successfully');
      
      // Step 2: Verify login code
      print('\n2. 🔐 Verifying login code...');
      final loginResponse = await sendRequest(
        '$baseUrl/verify-login-code',
        {
          'phone': testPhone,
          'code': '123456',
        },
      );

      if (loginResponse['success']) {
        final token = loginResponse['data']['token'];
        print('✅ Login successful!');
        print('🔑 Token: ${token.substring(0, 20)}...');
        
        // Step 3: Test protected endpoint
        print('\n3. 🔒 Testing protected endpoint...');
        final userResponse = await sendRequest(
          '$baseUrl/user',
          null,
          token: token,
        );

        if (userResponse['success']) {
          print('✅ Protected endpoint working with token');
          print('👤 User: ${userResponse['data']['name']}');
          
          // Step 4: Test contacts endpoint
          print('\n4. 📞 Testing contacts endpoint...');
          final contactsResponse = await sendRequest(
            '$baseUrl/contacts/find-users',
            {
              'phone_numbers': ['09034057885', '+1234567890', '+9876543210']
            },
            token: token,
            method: 'POST',
          );

          if (contactsResponse['success']) {
            print('✅ Contacts endpoint working with token');
            print('📱 Found ${contactsResponse['data'].length} Let\'s Talk users');
          } else {
            print('❌ Contacts endpoint failed: ${contactsResponse['message']}');
          }
          
        } else {
          print('❌ Protected endpoint failed: ${userResponse['message']}');
        }
        
      } else {
        print('❌ Login failed: ${loginResponse['message']}');
      }
      
    } else {
      print('❌ Phone verification failed: ${verificationResponse['message']}');
    }
    
  } catch (e) {
    print('❌ Error during authentication flow: $e');
  }
}

Future<Map<String, dynamic>> sendRequest(
  String url,
  Map<String, dynamic>? data, {
  String? token,
  String method = 'POST',
}) async {
  final client = HttpClient();
  
  try {
    final request = await client.openUrl(method, Uri.parse(url));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    if (token != null) {
      request.headers.set('Authorization', 'Bearer $token');
    }
    
    if (data != null) {
      request.write(jsonEncode(data));
    }
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    return jsonDecode(responseBody);
  } finally {
    client.close();
  }
}
