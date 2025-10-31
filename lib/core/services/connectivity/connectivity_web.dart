// Web implementation - HTML renderer için (dart:html kullanır)
import 'package:connectivity_plus/connectivity_plus.dart';
import 'connectivity_interface.dart';

class ConnectivityWeb implements ConnectivityInterface {
  static final Connectivity _connectivity = Connectivity();
  
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }
  
  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
