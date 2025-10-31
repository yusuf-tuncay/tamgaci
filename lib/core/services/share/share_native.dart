// Native implementation - mobil/desktop için
import 'package:share_plus/share_plus.dart';
import 'share_interface.dart';

class ShareNative implements ShareInterface {
  @override
  Future<void> share(String text) async {
    await Share.share(text);
  }

  @override
  Future<void> shareXFiles(List<dynamic> files, {String? text}) async {
    final xFiles =
        files.map((f) => f is XFile ? f : XFile(f.toString())).toList();
    await Share.shareXFiles(xFiles.cast<XFile>(), text: text);
  }
}
