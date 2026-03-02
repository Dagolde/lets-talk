void main() {
  print('🔍 Testing WhatsApp Phone Number Fix\n');
  print('====================================\n');

  // Test phone numbers
  final testNumbers = [
    '09034057885',      // Nigerian number with leading 0
    '+2349034057885',   // Nigerian number with country code
    '2349034057885',    // Nigerian number without +
    '9034057885',       // Nigerian number without leading 0
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
  
  print('🔧 Phone formatting steps:');
  print('  Original: $phoneNumber');
  print('  After removing non-digits: $cleanNumber');
  
  // Remove leading zeros
  while (cleanNumber.startsWith('0')) {
    cleanNumber = cleanNumber.substring(1);
    print('  After removing leading 0: $cleanNumber');
  }
  
  // Handle different number formats
  if (cleanNumber.length == 10) {
    // Nigerian number without country code, add 234
    cleanNumber = '234$cleanNumber';
    print('  Added country code (10 digits): $cleanNumber');
  } else if (cleanNumber.length == 11 && cleanNumber.startsWith('0')) {
    // Nigerian number with leading 0, replace with 234
    cleanNumber = '234${cleanNumber.substring(1)}';
    print('  Replaced leading 0 with country code: $cleanNumber');
  } else if (cleanNumber.length == 12 && cleanNumber.startsWith('234')) {
    // Already has Nigerian country code
    print('  Already has country code: $cleanNumber');
  } else if (cleanNumber.length == 11 && !cleanNumber.startsWith('0')) {
    // Nigerian number without leading 0, add country code
    cleanNumber = '234$cleanNumber';
    print('  Added country code (11 digits): $cleanNumber');
  } else if (cleanNumber.length >= 10 && cleanNumber.length <= 15) {
    // Assume it's already properly formatted
    print('  Assuming already formatted: $cleanNumber');
  } else {
    // Unknown format, try to make it work
    print('  Unknown format, using as is: $cleanNumber');
  }
  
  print('  Final formatted number: $cleanNumber');
  return cleanNumber;
}
