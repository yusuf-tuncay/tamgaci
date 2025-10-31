// Implementation factory - Web için
import 'secure_storage_interface.dart';
import 'secure_storage_web.dart' as impl;

SecureStorageInterface createSecureStorage() {
  return impl.SecureStorageWeb();
}

