// Cross-platform ImageProvider factory for profile photo paths
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'profile_image_provider_io.dart'
    if (dart.library.html) 'profile_image_provider_web.dart';

ImageProvider imageProviderFromPath(String path) {
  if (kIsWeb) {
    return NetworkImage(path);
  }
  return fileImageImpl(path);
}
