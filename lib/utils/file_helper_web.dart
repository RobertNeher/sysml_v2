import 'dart:html' as html;

Future<void> saveFile(String fileName, String content) async {
  final blob = html.Blob([content], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute("download", "$fileName.json")
    ..click();
  html.Url.revokeObjectUrl(url);
}
