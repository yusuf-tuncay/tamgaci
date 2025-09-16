// Facade with conditional exports to avoid importing native-only plugins on Web
export 'notification_service_io.dart'
    if (dart.library.html) 'notification_service_web.dart';
