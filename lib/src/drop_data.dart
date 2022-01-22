import 'dart:io';

enum DropDataType { text, url, image, video, audio, pdf, custom }

class DropData {
  File? dropFile;
  String? dropText;
  DropDataType type;
  DropData({this.dropFile, this.dropText, required this.type});
}
