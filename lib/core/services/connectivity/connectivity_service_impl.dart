// Implementation factory - Native için
import 'connectivity_interface.dart';
import 'connectivity_native.dart' as impl;

ConnectivityInterface createConnectivity() {
  return impl.ConnectivityNative();
}

