import 'dart:io';

enum DropDataType { text, url, image, video, audio, pdf, custom }

class DropData {
  File? dropFile;
  String? dropText;
  Map<String, dynamic>? metadata;
  DropDataType type;
  DropData({this.dropFile, this.dropText, this.metadata, required this.type});
}
