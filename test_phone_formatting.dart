import 'dart:io';

void main() {
  print('🔍 Testing Phone Number Formatting for WhatsApp\n');
  print('===============================================\n');

  // Test phone numbers
  final testNumbers = [
    '09034057885',      // Nigerian number with leading 0
    '+2349034057885',   // Nigerian number with country code
    '2349034057885',    // Nigerian number without +
    '9034057885',       // Nigerian number without leading 0
    '+1234567890',      // US number
    '1234567890',       // US number without +
    '08012345678',      // Another Nigerian number
    '080 1234 5678',    // Number with spaces
    '080-1234-5678',    // Number with dashes
    '(080) 1234-5678',  // Number with parentheses
  ];

  for (final number in testNumbers) {
    final formatted = formatPhoneForWhatsApp(number);
    print('📱 Original: $number');
    print('✅ Formatted: $formatted');
    print('🔗 WhatsApp URL: https://wa.me/$formatted?text=Test');
    print('---');
  }
}

String formatPhoneForWhatsApp(String phoneNumber) {
  // Remove all non-digit characters
  String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  
  // Remove leading zeros
  while (cleanNumber.startsWith('0')) {
    cleanNumber = cleanNumber.substring(1);
  }
  
  // If it starts with country code (e.g., 234 for Nigeria), keep it
  // If it doesn't have country code, assume it's a local number and add country code
  if (cleanNumber.length == 10) {
    // Nigerian number without country code, add 234
    cleanNumber = '234$cleanNumber';
  } else if (cleanNumber.length == 11 && cleanNumber.startsWith('0')) {
    // Nigerian number with leading 0, replace with 234
    cleanNumber = '234${cleanNumber.substring(1)}';
  }
  
  return cleanNumber;
}
