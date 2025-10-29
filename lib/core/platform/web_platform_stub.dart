// WebAssembly uyumlu stub dosyası
// Bu dosya web platformu dışında kullanılır

class WebPlatformStub {
  static bool get isWeb => false;
  static bool get isWasmSupported => false;
}

// Stub sınıfları
class SecureStorageWebStub {
  static Future<void> init() async {}
  static Future<void> dispose() async {}
}

class SharePlusWebStub {
  static Future<void> init() async {}
  static Future<void> dispose() async {}
}

class ConnectivityWebStub {
  static Future<void> init() async {}
  static Future<void> dispose() async {}
}
