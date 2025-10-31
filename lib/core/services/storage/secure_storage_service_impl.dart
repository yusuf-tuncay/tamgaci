// Implementation factory - Native için
import 'secure_storage_interface.dart';
import 'secure_storage_native.dart' as impl;

SecureStorageInterface createSecureStorage() {
  return impl.SecureStorageNative();
}

