// Facade with conditional exports to avoid importing dart:io on Web
export 'permission_service_io.dart'
    if (dart.library.html) 'permission_service_web.dart';
