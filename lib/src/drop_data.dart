import 'dart:io';

enum DropDataType { text, url, image, video, audio, pdf, file }

class DropData {
  File? dropFile;
  String? dropText;
  DropDataType type;
  Map<String, dynamic>? metadata;
  DropData({this.dropFile, this.dropText, this.metadata, required this.type});
}
