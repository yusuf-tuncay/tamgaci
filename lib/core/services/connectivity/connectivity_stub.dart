// Stub implementation for WebAssembly - dart:html kullanmaz
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_interface.dart';

class ConnectivityStub implements ConnectivityInterface {
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return ConnectivityResult.wifi; // Varsayılan olarak bağlı
  }
  
  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => ConnectivityResult.wifi,
    );
  }
}
