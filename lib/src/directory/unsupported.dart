import 'dart:async';

import '../platform/platform.dart';

class DirUtils {
  final String path, fileName;
  final MockedPlatform platform;

  DirUtils(this.fileName, this.platform, [this.path]);

  Future writeFile(String data) {
    throw 'Platform Not Supported';
  }

  Future<String> readFile() {
    throw 'Platform Not Supported';
  }

  Future<bool> fileExists() {
    throw 'Platform Not Supported';
  }

  Future clear() {
    throw 'Platform Not Supported';
  }
}
