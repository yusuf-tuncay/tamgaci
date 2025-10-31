// Abstract interface for connectivity implementations
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityInterface {
  Future<ConnectivityResult> checkConnectivity();
  Stream<ConnectivityResult> get onConnectivityChanged;
}

