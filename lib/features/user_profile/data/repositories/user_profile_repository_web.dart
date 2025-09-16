import 'package:shared_preferences/shared_preferences.dart';

Future<String> uploadProfilePhotoImpl(String userId, String base64Data) async {
  final prefs = await SharedPreferences.getInstance();
  final photoKey = 'profile_photo_$userId';
  await prefs.setString(photoKey, base64Data);
  return 'web_photo_$userId';
}

Future<void> deleteStoredPhotoImpl(String userId, String storedPath) async {
  final prefs = await SharedPreferences.getInstance();
  final photoKey = 'profile_photo_$userId';
  await prefs.remove(photoKey);
}
