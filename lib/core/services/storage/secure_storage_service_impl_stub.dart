// Stub implementation factory
import 'secure_storage_interface.dart';
import 'secure_storage_stub.dart' as impl;

SecureStorageInterface createSecureStorage() {
  return impl.FlutterSecureStorageStub();
}

