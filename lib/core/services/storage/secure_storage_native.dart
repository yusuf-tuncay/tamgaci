// Native implementation - mobil/desktop için
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'secure_storage_interface.dart';

class SecureStorageNative implements SecureStorageInterface {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  @override
  Future<String?> read(String key) => _storage.read(key: key);
  
  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
  
  @override
  Future<void> deleteAll() => _storage.deleteAll();
  
  @override
  Future<Map<String, String>> readAll() => _storage.readAll();
}
