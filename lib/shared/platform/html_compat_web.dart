import 'dart:html' as html;

class HtmlWindow {
  const HtmlWindow();

  void open(String url, String target) => html.window.open(url, target);
  void postMessage(Object? message) => html.window.opener?.postMessage(message, '*');
  void close() => html.window.close();
  void redirect(String url) => html.window.location.href = url;
}

const htmlWindow = HtmlWindow();


