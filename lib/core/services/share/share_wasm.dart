// WebAssembly implementation - dart:html kullanmaz
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'share_interface.dart';

class ShareWasm implements ShareInterface {
  @override
  Future<void> share(String text) async {
    // WebAssembly uyumlu paylaşım - Clipboard API kullan
    try {
      await Clipboard.setData(ClipboardData(text: text));
      debugPrint('WebAssembly share: Metin panoya kopyalandı: $text');
    } catch (e) {
      debugPrint('WebAssembly share hatası: $e');
    }
  }
  
  @override
  Future<void> shareXFiles(List<dynamic> files, {String? text}) async {
    // WebAssembly uyumlu dosya paylaşımı
    debugPrint('WebAssembly share files: ${files.length} dosya');
    if (text != null && text.isNotEmpty) {
      await share(text);
    }
  }
}
