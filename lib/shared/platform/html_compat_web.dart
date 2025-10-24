import 'package:web/web.dart' as web;

class HtmlWindow {
  const HtmlWindow();

  void open(String url, String target) => web.window.open(url, target);

  void postMessage(Object? message) {
    // Web platformu için postMessage desteği
    // Şimdilik basit implementasyon - gelecekte web interop ile geliştirilecek
    try {
      final opener = web.window.opener;
      if (opener != null) {
        // PostMessage işlevselliği şimdilik devre dışı
        // Web interop ile daha gelişmiş implementasyon yapılacak
      }
    } catch (e) {
      // PostMessage desteklenmiyorsa sessizce geç
    }
  }

  void close() => web.window.close();
  void redirect(String url) => web.window.location.href = url;
}

const htmlWindow = HtmlWindow();
