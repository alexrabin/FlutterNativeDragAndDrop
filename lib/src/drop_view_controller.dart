import 'dart:io';

import 'package:flutter/services.dart';

typedef DropViewLoadingCallback = void Function(bool loading);
typedef DropViewDataReceivedCallback = void Function(
    List<DropData> receivedData);

class DropViewController {
  late MethodChannel _channel;
  final DropViewLoadingCallback loadingCallback;
  final DropViewDataReceivedCallback dataReceivedCallback;
  DropViewController(int id, this.loadingCallback, this.dataReceivedCallback) {
    _channel = MethodChannel('DropView/$id');
    _channel.setMethodCallHandler(_receivedData);
  }
  Future<void> _receivedData(MethodCall call) async {
    switch (call.method) {
      case 'loadingData':
        loadingCallback(true);
        break;
      case 'receivedDropData':
        List<dynamic> data = call.arguments as List<dynamic>;
        List<Map<String, dynamic>> receivedData =
            data.map((e) => Map<String, dynamic>.from(e)).toList();

        dataReceivedCallback(_processData(receivedData));
        break;
    }
  }

  List<DropData> _processData(List<Map<String, dynamic>> data) {
    List<DropData> dropDataList = [];
    for (var d in data) {
      if (d['text'] != null) {
        //add text
        var text = d['text'] as String;
        var dropData = DropData(type: DropDataType.text, dropText: text);
        dropDataList.add(dropData);
      } else if (d['url'] != null) {
        //add url
        var url = d['url'] as String;
        var dropData = DropData(type: DropDataType.text, dropText: url);
        dropDataList.add(dropData);
      } else if (d['image'] != null) {
        //add image
        var imageFile = File(d['image'] as String);
        var dropData = DropData(type: DropDataType.image, dropFile: imageFile);
        dropDataList.add(dropData);
      } else if (d['video'] != null) {
        //add video
        var videoFile = File(d['video'] as String);
        var dropData = DropData(type: DropDataType.video, dropFile: videoFile);
        dropDataList.add(dropData);
      } else if (d['audio'] != null) {
        // add audio
        var audioFile = File(d['audio'] as String);
        var dropData = DropData(type: DropDataType.audio, dropFile: audioFile);
        dropDataList.add(dropData);
      } else if (d['pdf'] != null) {
        //add pdf
        var pdf = File(d['pdf'] as String);
        var dropData = DropData(type: DropDataType.pdf, dropFile: pdf);
        dropDataList.add(dropData);
      } else if (d['file'] != null) {
        //add pdf
        var file = File(d['file'] as String);
        var dropData = DropData(type: DropDataType.file, dropFile: file);
        dropDataList.add(dropData);
      }
    }
    loadingCallback(false);
    return dropDataList;
  }
}

enum DropDataType { text, url, image, video, audio, pdf, file }

class DropData {
  File? dropFile;
  String? dropText;
  DropDataType type;
  DropData({this.dropFile, this.dropText, required this.type});
}
