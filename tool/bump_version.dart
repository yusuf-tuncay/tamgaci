import 'dart:io';

void main(List<String> args) async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml not found.');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);
  if (match == null) {
    stderr.writeln('Version line not found in pubspec.yaml');
    exit(1);
  }

  final major = int.parse(match.group(1)!);
  final minor = int.parse(match.group(2)!);
  final patch = int.parse(match.group(3)!);
  final build = int.parse(match.group(4)!);

  final newPatch = patch + 1;
  final newBuild = build + 1;
  final newVersion = '$major.$minor.$newPatch+$newBuild';

  final updatedPubspec = pubspecContent.replaceFirst(match.group(0)!, 'version: $newVersion');
  pubspecFile.writeAsStringSync(updatedPubspec);
  stdout.writeln('pubspec.yaml updated to $newVersion');

  // Update web/index.html (version strings)
  final indexFile = File('web/index.html');
  if (indexFile.existsSync()) {
    var indexContent = indexFile.readAsStringSync();

    // Replace meta ETag content
    indexContent = _replaceOrInsertMeta(indexContent, 'ETag', newVersion);

    // Replace JS const version = '...'
    indexContent = indexContent.replaceAll(
      RegExp("const\\s+version\\s*=\\s*'[^']*';"),
      "const version = '$newVersion';",
    );

    // Replace flutter_bootstrap.js query param v=...
    indexContent = indexContent.replaceAll(
      RegExp('flutter_bootstrap\\.js\\?v=[^&"\']*'),
      "flutter_bootstrap.js?v=$newVersion",
    );

    indexFile.writeAsStringSync(indexContent);
    stdout.writeln('web/index.html updated to $newVersion');
  }

  // Update firebase.json ETag
  final firebaseFile = File('firebase.json');
  if (firebaseFile.existsSync()) {
    var firebaseContent = firebaseFile.readAsStringSync();
    firebaseContent = firebaseContent.replaceAll(RegExp(r'("ETag"\s*:\s*")([^"]*)(")'), '"ETag": "$newVersion"');
    firebaseFile.writeAsStringSync(firebaseContent);
    stdout.writeln('firebase.json ETag updated to $newVersion');
  }

  // Stage changes if running in CI (optional local convenience)
  try {
    await _run('git', ['add', 'pubspec.yaml', 'web/index.html', 'firebase.json']);
  } catch (_) {}

  stdout.writeln('Version bump complete: $newVersion');
}

String _replaceOrInsertMeta(String html, String httpEquiv, String value) {
  final metaRegex = RegExp(
      '<meta[^>]*http-equiv="$httpEquiv"[^>]*content="[^"]*"[^>]*>',
      caseSensitive: false);
  if (metaRegex.hasMatch(html)) {
    return html.replaceAll(metaRegex,
        '<meta http-equiv="$httpEquiv" content="$value" />');
  }
  // Insert after other meta tags near the top of head
  final headIndex = html.indexOf('</head>');
  if (headIndex != -1) {
    final insertion = '  <meta http-equiv="$httpEquiv" content="$value" />\n';
    return html.replaceFirst('</head>', '$insertion</head>');
  }
  return html;
}

Future<void> _run(String cmd, List<String> args) async {
  final result = await Process.run(cmd, args);
  if (result.exitCode != 0) {
    throw ProcessException(cmd, args, result.stderr.toString(), result.exitCode);
  }
}

