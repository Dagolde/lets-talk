import 'package:dio/dio.dart';

void main() async {
  print('🧪 Testing API Connection...\n');
  
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Test 1: Check if server is reachable
  print('Test 1: Server Connectivity...');
  try {
    final response = await dio.get('/admin/settings');
    print('✅ Server is reachable (Status: ${response.statusCode})');
  } catch (e) {
    print('❌ Server connection failed: $e');
    return;
  }

  // Test 2: Admin Login
  print('\nTest 2: Admin Login...');
  try {
    final response = await dio.post('/admin/login', data: {
      'email': 'admin@letstalk.com',
      'password': 'admin123',
    });
    
    if (response.data['success']) {
      print('✅ Admin login successful');
      print('   Token: ${response.data['token'].toString().substring(0, 20)}...');
      
      final token = response.data['token'];
      
      // Test 3: Get Dashboard with token
      print('\nTest 3: Dashboard Access...');
      try {
        final dashboardResponse = await dio.get('/admin/dashboard', options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ));
        
        if (dashboardResponse.data['success']) {
          print('✅ Dashboard access successful');
          final stats = dashboardResponse.data['data']['stats'];
          print('   Total Users: ${stats['total_users'] ?? 0}');
          print('   Active Chats: ${stats['active_chats'] ?? 0}');
        } else {
          print('❌ Dashboard access failed: ${dashboardResponse.data['message']}');
        }
      } catch (e) {
        print('❌ Dashboard access failed: $e');
      }
      
    } else {
      print('❌ Admin login failed: ${response.data['message']}');
    }
  } catch (e) {
    print('❌ Admin login failed: $e');
  }

  // Test 4: Check API endpoints
  print('\nTest 4: API Endpoints Check...');
  final endpoints = [
    '/admin/login',
    '/admin/dashboard',
    '/admin/settings',
    '/admin/users',
    '/admin/analytics',
  ];
  
  int workingEndpoints = 0;
  for (final endpoint in endpoints) {
    try {
      final response = await dio.get(endpoint);
      if (response.statusCode != 404) {
        workingEndpoints++;
        print('   ✅ $endpoint');
      } else {
        print('   ❌ $endpoint (404)');
      }
    } catch (e) {
      print('   ⚠️  $endpoint (Error: ${e.toString().substring(0, 50)}...)');
    }
  }
  
  print('\n📊 Results Summary:');
  print('   Working endpoints: $workingEndpoints/${endpoints.length}');
  
  if (workingEndpoints >= 3) {
    print('\n🎉 API connection test PASSED!');
    print('   The Flutter app can successfully connect to the backend.');
    print('   You can now proceed with building the mobile app.');
  } else {
    print('\n⚠️  API connection test PARTIALLY PASSED');
    print('   Some endpoints are working, but there might be issues.');
    print('   Please check your backend configuration.');
  }
  
  print('\n🚀 Next Steps:');
  print('   1. Run: flutter pub get');
  print('   2. Run: flutter run');
  print('   3. Test the mobile app features');
  print('   4. Configure payment gateways in admin panel');
}
