import 'dart:async';

import 'package:universal_html/html.dart' as html;

import '../platform/platform.dart';

class DirUtils {
  final String path, fileName;
  final MockedPlatform platform;

  DirUtils(this.fileName, this.platform, [this.path]);

  html.Storage get _localStorage => html.window.localStorage;

  Future writeFile(String data) async {
    _localStorage.update(
      fileName,
      (val) => data,
      ifAbsent: () => data,
    );
    return;
  }

  Future<String> readFile() async {
    final data = _localStorage.entries.firstWhere(
      (i) => i.key == fileName,
      orElse: () => null,
    );
    return data?.value;
  }

  Future<bool> fileExists() async {
    return _localStorage != null && _localStorage.containsKey(fileName);
  }

  Future clear() async {
    _localStorage.clear();
  }

  Future<bool> exists() async {
    return _localStorage != null && _localStorage.containsKey(fileName);
  }
}
