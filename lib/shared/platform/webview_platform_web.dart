import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class WebViewPlatformConfigurer {
  const WebViewPlatformConfigurer();

  void configure() {
    WebViewPlatform.instance = WebWebViewPlatform();
  }
}


