import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class KeystoreService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _masterKeyAlias = 'master_key';
  static const String _encryptionKeyAlias = 'encryption_key';
  static const String _authTokenAlias = 'auth_token';
  static const String _refreshTokenAlias = 'refresh_token';
  static const String _biometricKeyAlias = 'biometric_key';
  static const String _walletPinAlias = 'wallet_pin';
  static const String _encryptionIvAlias = 'encryption_iv';

  // Initialize keystore service
  static Future<void> initialize() async {
    try {
      // Check if master key exists, if not create one
      final masterKey = await _storage.read(key: _masterKeyAlias);
      if (masterKey == null) {
        await _generateMasterKey();
      }
    } catch (e) {
      print('Failed to initialize keystore: $e');
    }
  }

  // Generate master key
  static Future<void> _generateMasterKey() async {
    try {
      final key = Key.fromSecureRandom(32);
      await _storage.write(key: _masterKeyAlias, value: base64Encode(key.bytes));
    } catch (e) {
      throw Exception('Failed to generate master key: $e');
    }
  }

  // Get master key
  static Future<Key> _getMasterKey() async {
    try {
      final keyString = await _storage.read(key: _masterKeyAlias);
      if (keyString == null) {
        throw Exception('Master key not found');
      }
      return Key(base64Decode(keyString));
    } catch (e) {
      throw Exception('Failed to get master key: $e');
    }
  }

  // Generate encryption key
  static Future<Key> _generateEncryptionKey() async {
    try {
      final key = Key.fromSecureRandom(32);
      await _storage.write(key: _encryptionKeyAlias, value: base64Encode(key.bytes));
      return key;
    } catch (e) {
      throw Exception('Failed to generate encryption key: $e');
    }
  }

  // Get encryption key
  static Future<Key> _getEncryptionKey() async {
    try {
      final keyString = await _storage.read(key: _encryptionKeyAlias);
      if (keyString == null) {
        return await _generateEncryptionKey();
      }
      return Key(base64Decode(keyString));
    } catch (e) {
      throw Exception('Failed to get encryption key: $e');
    }
  }

  // Generate IV
  static Future<IV> _generateIV() async {
    try {
      final iv = IV.fromSecureRandom(16);
      await _storage.write(key: _encryptionIvAlias, value: base64Encode(iv.bytes));
      return iv;
    } catch (e) {
      throw Exception('Failed to generate IV: $e');
    }
  }

  // Get IV
  static Future<IV> _getIV() async {
    try {
      final ivString = await _storage.read(key: _encryptionIvAlias);
      if (ivString == null) {
        return await _generateIV();
      }
      return IV(base64Decode(ivString));
    } catch (e) {
      throw Exception('Failed to get IV: $e');
    }
  }

  // Encrypt data
  static Future<String> encryptData(String data) async {
    try {
      final key = await _getEncryptionKey();
      final iv = await _getIV();
      final encrypter = Encrypter(AES(key));
      final encrypted = encrypter.encrypt(data, iv: iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to encrypt data: $e');
    }
  }

  // Decrypt data
  static Future<String> decryptData(String encryptedData) async {
    try {
      final key = await _getEncryptionKey();
      final iv = await _getIV();
      final encrypter = Encrypter(AES(key));
      final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt data: $e');
    }
  }

  // Store sensitive data securely
  static Future<void> storeSecureData(String key, String value) async {
    try {
      final encryptedValue = await encryptData(value);
      await _storage.write(key: key, value: encryptedValue);
    } catch (e) {
      throw Exception('Failed to store secure data: $e');
    }
  }

  // Retrieve sensitive data securely
  static Future<String?> getSecureData(String key) async {
    try {
      final encryptedValue = await _storage.read(key: key);
      if (encryptedValue == null) {
        return null;
      }
      return await decryptData(encryptedValue);
    } catch (e) {
      throw Exception('Failed to retrieve secure data: $e');
    }
  }

  // Store authentication token
  static Future<void> storeAuthToken(String token) async {
    try {
      await storeSecureData(_authTokenAlias, token);
    } catch (e) {
      throw Exception('Failed to store auth token: $e');
    }
  }

  // Get authentication token
  static Future<String?> getAuthToken() async {
    try {
      return await getSecureData(_authTokenAlias);
    } catch (e) {
      throw Exception('Failed to get auth token: $e');
    }
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    try {
      await storeSecureData(_refreshTokenAlias, token);
    } catch (e) {
      throw Exception('Failed to store refresh token: $e');
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await getSecureData(_refreshTokenAlias);
    } catch (e) {
      throw Exception('Failed to get refresh token: $e');
    }
  }

  // Store wallet PIN
  static Future<void> storeWalletPin(String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      await storeSecureData(_walletPinAlias, hashedPin);
    } catch (e) {
      throw Exception('Failed to store wallet PIN: $e');
    }
  }

  // Verify wallet PIN
  static Future<bool> verifyWalletPin(String pin) async {
    try {
      final storedHash = await getSecureData(_walletPinAlias);
      if (storedHash == null) {
        return false;
      }
      final inputHash = _hashPin(pin);
      return storedHash == inputHash;
    } catch (e) {
      throw Exception('Failed to verify wallet PIN: $e');
    }
  }

  // Hash PIN
  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Store biometric key
  static Future<void> storeBiometricKey(String key) async {
    try {
      await storeSecureData(_biometricKeyAlias, key);
    } catch (e) {
      throw Exception('Failed to store biometric key: $e');
    }
  }

  // Get biometric key
  static Future<String?> getBiometricKey() async {
    try {
      return await getSecureData(_biometricKeyAlias);
    } catch (e) {
      throw Exception('Failed to get biometric key: $e');
    }
  }

  // Store API keys
  static Future<void> storeApiKey(String service, String apiKey) async {
    try {
      final key = 'api_key_$service';
      await storeSecureData(key, apiKey);
    } catch (e) {
      throw Exception('Failed to store API key: $e');
    }
  }

  // Get API key
  static Future<String?> getApiKey(String service) async {
    try {
      final key = 'api_key_$service';
      return await getSecureData(key);
    } catch (e) {
      throw Exception('Failed to get API key: $e');
    }
  }

  // Store payment method details
  static Future<void> storePaymentMethod(String methodId, Map<String, dynamic> details) async {
    try {
      final key = 'payment_method_$methodId';
      final jsonData = jsonEncode(details);
      await storeSecureData(key, jsonData);
    } catch (e) {
      throw Exception('Failed to store payment method: $e');
    }
  }

  // Get payment method details
  static Future<Map<String, dynamic>?> getPaymentMethod(String methodId) async {
    try {
      final key = 'payment_method_$methodId';
      final jsonData = await getSecureData(key);
      if (jsonData == null) {
        return null;
      }
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get payment method: $e');
    }
  }

  // Store user credentials
  static Future<void> storeCredentials(String username, String password) async {
    try {
      final key = 'credentials_$username';
      final credentials = {
        'username': username,
        'password': password,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final jsonData = jsonEncode(credentials);
      await storeSecureData(key, jsonData);
    } catch (e) {
      throw Exception('Failed to store credentials: $e');
    }
  }

  // Get user credentials
  static Future<Map<String, dynamic>?> getCredentials(String username) async {
    try {
      final key = 'credentials_$username';
      final jsonData = await getSecureData(key);
      if (jsonData == null) {
        return null;
      }
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get credentials: $e');
    }
  }

  // Store encryption key for specific data
  static Future<void> storeDataKey(String dataId, String key) async {
    try {
      final storageKey = 'data_key_$dataId';
      await storeSecureData(storageKey, key);
    } catch (e) {
      throw Exception('Failed to store data key: $e');
    }
  }

  // Get encryption key for specific data
  static Future<String?> getDataKey(String dataId) async {
    try {
      final storageKey = 'data_key_$dataId';
      return await getSecureData(storageKey);
    } catch (e) {
      throw Exception('Failed to get data key: $e');
    }
  }

  // Delete secure data
  static Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to delete secure data: $e');
    }
  }

  // Clear all secure data
  static Future<void> clearAllSecureData() async {
    try {
      await _storage.deleteAll();
      // Reinitialize master key
      await _generateMasterKey();
    } catch (e) {
      throw Exception('Failed to clear secure data: $e');
    }
  }

  // Check if keystore is available
  static Future<bool> isKeystoreAvailable() async {
    try {
      final testKey = 'test_availability';
      await _storage.write(key: testKey, value: 'test');
      await _storage.delete(key: testKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get keystore information
  static Future<Map<String, dynamic>> getKeystoreInfo() async {
    try {
      final isAvailable = await isKeystoreAvailable();
      final hasMasterKey = await _storage.read(key: _masterKeyAlias) != null;
      final hasEncryptionKey = await _storage.read(key: _encryptionKeyAlias) != null;
      final hasAuthToken = await _storage.read(key: _authTokenAlias) != null;
      final hasWalletPin = await _storage.read(key: _walletPinAlias) != null;

      return {
        'available': isAvailable,
        'has_master_key': hasMasterKey,
        'has_encryption_key': hasEncryptionKey,
        'has_auth_token': hasAuthToken,
        'has_wallet_pin': hasWalletPin,
      };
    } catch (e) {
      throw Exception('Failed to get keystore info: $e');
    }
  }

  // Generate secure random string
  static String generateSecureRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Generate secure random bytes
  static Uint8List generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  // Hash data with SHA-256
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Hash data with salt
  static String hashDataWithSalt(String data, String salt) {
    final saltedData = data + salt;
    return hashData(saltedData);
  }

  // Generate salt
  static String generateSalt() {
    return generateSecureRandomString(32);
  }

  // Verify hash
  static bool verifyHash(String data, String salt, String hash) {
    final computedHash = hashDataWithSalt(data, salt);
    return computedHash == hash;
  }
}
