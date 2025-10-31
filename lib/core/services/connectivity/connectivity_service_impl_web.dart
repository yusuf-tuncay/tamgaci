// Implementation factory - Web için
import 'connectivity_interface.dart';
import 'connectivity_web.dart' as impl;

ConnectivityInterface createConnectivity() {
  return impl.ConnectivityWeb();
}

