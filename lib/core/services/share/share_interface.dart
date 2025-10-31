// Abstract interface for share implementations
abstract class ShareInterface {
  Future<void> share(String text);
  Future<void> shareXFiles(List<dynamic> files, {String? text});
}

