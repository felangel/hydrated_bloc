import 'dart:async';
import 'dart:convert';

import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DirUtils {
  final String path, fileName;

  DirUtils(this.fileName, [this.path]);

  Future writeFile(Map<String, dynamic> data) async {
    try {
      File _file = await _getFile();
      _file.writeAsStringSync(json.encode(data));
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, dynamic>> readFile() async {
    File _file = await _getFile();

    try {
      final content = await _file.readAsString();
      try {
        final _data = json.decode(content) as Map<String, dynamic>;
        return _data;
      } catch (err) {
        _file.writeAsStringSync('{}');
        throw err;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<bool> fileExists() async {
    File _file = await _getFile();
    return _file.existsSync();
  }

  Future clear() async {
    File _file = await _getFile();
    return _file.deleteSync();
  }

  Future<File> _getFile() async {
    final dir = await _getDocumentDir();
    final _path = path ?? dir.path;
    final _file = File('$_path/$fileName');
    return _file;
  }

  Future<Directory> _getDocumentDir() async {
    if (Platform.isMacOS || Platform.isLinux) {
      return Directory('${Platform.environment['HOME']}/.config');
    } else if (Platform.isWindows) {
      return Directory('${Platform.environment['UserProfile']}\\.config');
    }
    return await getApplicationDocumentsDirectory();
  }
}
