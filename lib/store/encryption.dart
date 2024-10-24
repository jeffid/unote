import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';

import '/utils/logger.dart';

/// sha Digest
crypto.Digest sha(String str, {crypto.Hash hash = crypto.sha256}) {
  return hash.convert(utf8.encode(str));
}

/// sha string
String shaStr(String str, {crypto.Hash hash = crypto.sha256}) {
  return sha(str, hash: hash).toString();
}

/// md5 string
String m5Str(String str) {
  return shaStr(str, hash: crypto.md5);
}

/// sha-1 string
String s1Str(String str) {
  return shaStr(str, hash: crypto.sha1);
}

/// sha-256 string
/// sha256: 256b > 32B > 64 Hex
String s256Str(String str) {
  return shaStr(str, hash: crypto.sha256);
}

/// password hash string
String pwdHashStr(String str) {
  return shaStr(List.filled(3, str).join('-'), hash: crypto.sha256);
}

///
class Encryption {
  /// Encryption
  /// [key] is a plaintext key entered by the user
  /// [keyHash] is the hash code converted by [key]. use for [SecretKey]
  Encryption({String key = '', String keyHash = ''})
      : _key = key.trim(),
        _keyHash = keyHash.trim() {
    if (_key.isEmpty && _keyHash.isEmpty) {
      throw ArgumentError('Either a key or a keyHash must be provided.');
    }
    // _secretKey = initSecretKey();
  }

  static const int secretKeyLength = 32;

  static Argon2id _argon = Argon2id(
    memory: 10 * 1000,
    parallelism: 1,
    iterations: 2,
    hashLength: secretKeyLength,
  );

  /// Choose the cipher
  /// AesGcm.with256bits secretKeyLength : 32
  final AesGcm _algorithm = AesGcm.with256bits();

  /// secret key.
  SecretKey? _secretKey;

  String _key;

  String get key => _key;

  String _keyHash;

  String get keyHash => _keyHash;

  ///
  static Future<(SecretKey, String)> argonHash(String key, String nonce) async {
    SecretKey secretKey = await _argon.deriveKeyFromPassword(
      password: key,
      // nonce: crypto.sha256.convert(utf8.encode(nonce)).bytes,
      nonce: sha(nonce).bytes,
    );

    String keyHash = base64Url.encode(await secretKey.extractBytes());

    return (secretKey, keyHash);
  }

  ///
  static Future<bool> isHashEqual(
      String key, String nonce, String targetHash) async {
    final res = await argonHash(key, nonce);
    return res.$2 == targetHash;
  }

  ///
  static void hashEqual(
      String key, String nonce, String targetHash, Function(bool) fn) async {
    isHashEqual(key, nonce, targetHash).then(fn);
  }

  ///
  Future<SecretKey> _initSecretKey() async {
    if (_secretKey != null) return _secretKey!;

    if (_key.isNotEmpty) {
      final res = await argonHash(key, key);
      _secretKey = res.$1;
      _keyHash = res.$2;
    } else {
      _secretKey = SecretKey(base64Url.decode(_keyHash));
    }

    return _secretKey!;
  }

  /// Encrypt
  Future<String> encrypt(String clearText) async {
    // await _initSecretKey();
    final SecretBox secretBox = await _algorithm.encryptString(
      clearText.trim(),
      secretKey: await _initSecretKey(),
      // secretKey: _secretKey!,
    );

    return base64Url.encode(secretBox.concatenation());
  }

  /// Decrypt
  Future<(String, bool)> decrypt(String cipherText) async {
    String clearText = '';
    bool isDecryptSuccess = false;
    try {
      final SecretBox secretBox = SecretBox.fromConcatenation(
        base64Url.decode(cipherText),
        nonceLength: AesGcm.defaultNonceLength,
        macLength: AesGcm.aesGcmMac.macLength,
      );

      clearText = await _algorithm.decryptString(
        secretBox,
        secretKey: await _initSecretKey(),
      );
      isDecryptSuccess = true;
    } on SecretBoxAuthenticationError catch (e) {
      logger.d('auth err:: $e');
    } catch (e) {
      logger.d(e);
    }

    return (clearText, isDecryptSuccess);
  }
}
