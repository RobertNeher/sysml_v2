import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> saveFile(String fileName, String content) async {
  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Save Project',
    fileName: '$fileName.json',
    type: FileType.custom,
    allowedExtensions: ['json'],
  );

  if (outputFile != null) {
    // Force .json extension if missing from user input in dialog
    if (!outputFile.toLowerCase().endsWith('.json')) {
      outputFile += '.json';
    }
    final file = File(outputFile);
    await file.writeAsString(content);
  }
}
