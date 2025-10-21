import 'package:web/web.dart' as web;

class HtmlWindow {
  const HtmlWindow();

  void open(String url, String target) => web.window.open(url, target);
  void postMessage(Object? message) {
    // Web platformu için postMessage desteği - şimdilik devre dışı
    // TODO: Web interop ile düzeltilecek
  }

  void close() => web.window.close();
  void redirect(String url) => web.window.location.href = url;
}

const htmlWindow = HtmlWindow();
