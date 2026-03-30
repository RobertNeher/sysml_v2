import 'dart:convert';
import 'package:file_picker/file_picker.dart';

// Conditional import for web
import 'file_helper_stub.dart'
    if (dart.library.html) 'file_helper_web.dart'
    if (dart.library.io) 'file_helper_io.dart';

class FileHelper {
  static Future<void> saveProject(String fileName, String content) async {
    await saveFile(fileName, content);
  }

  static Future<String?> openProject() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.bytes != null) {
      return utf8.decode(result.files.single.bytes!);
    }
    return null;
  }
}
