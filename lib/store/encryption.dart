import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:logger/logger.dart';

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

  /// Choose the cipher
  /// AesGcm.with256bits secretKeyLength : 32
  final AesGcm _algorithm = AesGcm.with256bits();

  /// secret key.
  SecretKey? _secretKey;

  String _key;

  String get key => _key;

  String _keyHash;

  String get keyHash => _keyHash;

  Logger logger = Logger();

  ///
  Future<SecretKey> _initSecretKey() async {
    if (_secretKey != null) return _secretKey!;

    if (_key.isNotEmpty) {
      final argon = Argon2id(
        memory: 10 * 1000,
        parallelism: 1,
        iterations: 2,
        hashLength: _algorithm.secretKeyLength,
      );

      _secretKey = await argon.deriveKeyFromPassword(
        password: _key,
        nonce: sha256.convert(utf8.encode(_key)).bytes,
      );

      // final secretKeyBytes = await secretKey.extractBytes();
      _keyHash = base64Url.encode(await _secretKey!.extractBytes());
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
