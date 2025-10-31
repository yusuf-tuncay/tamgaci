// Stub implementation for WebAssembly - dart:html kullanmaz
import 'package:flutter/foundation.dart';
import 'share_interface.dart';

class ShareStub implements ShareInterface {
  @override
  Future<void> share(String text) async {
    debugPrint('Share (stub): $text');
  }
  
  @override
  Future<void> shareXFiles(List<dynamic> files, {String? text}) async {
    debugPrint('Share files (stub): ${files.length} files');
    if (text != null) debugPrint('Text: $text');
  }
}
