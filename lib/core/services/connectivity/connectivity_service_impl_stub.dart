// Stub implementation factory
import 'connectivity_interface.dart';
import 'connectivity_stub.dart' as impl;

ConnectivityInterface createConnectivity() {
  return impl.ConnectivityStub();
}

