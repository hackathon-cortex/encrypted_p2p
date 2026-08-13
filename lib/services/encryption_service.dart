import 'dart:convert';

class EncryptionService {
  String encrypt(String message) {
    final bytes = utf8.encode(message);
    return base64Encode(bytes);
  }

  String decrypt(String encryptedMessage) {
    try {
      final bytes = base64Decode(encryptedMessage);
      return utf8.decode(bytes);
    } catch (_) {
      return encryptedMessage;
    }
  }
}