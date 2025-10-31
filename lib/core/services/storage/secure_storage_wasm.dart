// WebAssembly implementation - dart:html kullanmaz
import 'secure_storage_interface.dart';

class SecureStorageWasm implements SecureStorageInterface {
  static final Map<String, String> _storage = {};
  
  @override
  Future<String?> read(String key) async {
    // WebAssembly uyumlu localStorage alternatifi
    // SharedPreferences veya in-memory storage kullanılabilir
    return _storage[key];
  }
  
  @override
  Future<void> write(String key, String value) async {
    _storage[key] = value;
  }
  
  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }
  
  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }
  
  @override
  Future<Map<String, String>> readAll() async {
    return Map.from(_storage);
  }
}
