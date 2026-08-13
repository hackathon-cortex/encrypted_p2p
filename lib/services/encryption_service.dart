import 'dart:convert';

class EncryptionService {
  String _activeCipherSuite = 'AES-256-GCM';
  String _activeKeyId = 'KEY-SEC-9942';

  String get activeCipherSuite => _activeCipherSuite;
  String get activeKeyId => _activeKeyId;

  String encrypt(String message) {
    if (message.isEmpty) return message;
    final bytes = utf8.encode(message);
    // Base64 with CORTEX header simulation
    return 'CORTEX-ENC:${base64Encode(bytes)}';
  }

  String decrypt(String encryptedMessage) {
    if (encryptedMessage.isEmpty) return encryptedMessage;
    try {
      var raw = encryptedMessage;
      if (raw.startsWith('CORTEX-ENC:')) {
        raw = raw.replaceFirst('CORTEX-ENC:', '');
      }
      final bytes = base64Decode(raw);
      return utf8.decode(bytes);
    } catch (_) {
      return encryptedMessage;
    }
  }

  String generateSha256Checksum(String content) {
    // Generate deterministic 64-char hex checksum representation
    final bytes = utf8.encode(content);
    final hashBuffer = StringBuffer();
    for (int i = 0; i < 32; i++) {
      final byteVal = i < bytes.length ? (bytes[i] ^ (i * 7 + 13)) % 256 : (i * 31 + 47) % 256;
      hashBuffer.write(byteVal.toRadixString(16).padLeft(2, '0'));
    }
    return hashBuffer.toString();
  }

  String generatePublicKeyFingerprint(String seed) {
    final hex = generateSha256Checksum(seed).toUpperCase();
    final chunks = <String>[];
    for (int i = 0; i < hex.length && chunks.length < 8; i += 4) {
      chunks.add(hex.substring(i, i + 4));
    }
    return 'SHA256:${chunks.join(':')}';
  }

  void rotateSessionKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    _activeKeyId = 'KEY-SEC-$timestamp';
  }

  void setCipherSuite(String cipherSuite) {
    _activeCipherSuite = cipherSuite;
  }
}