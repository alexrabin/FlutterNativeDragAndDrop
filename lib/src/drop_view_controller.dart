import 'dart:io';

import 'package:flutter/services.dart';

///triggered when the data is dropped into the dropview
typedef DropViewLoadingCallback = void Function(bool loading);

///triggered when the drop data has been received
typedef DropViewDataReceivedCallback = void Function(
    List<DropData> receivedData);

typedef DropViewCreatedCallback = void Function(DropViewController controller);

class DropViewController {
  late MethodChannel _channel;
  final DropViewLoadingCallback loading;
  final DropViewDataReceivedCallback dataReceived;
  DropViewController(int id, this.loading, this.dataReceived) {
    _channel = MethodChannel('DropView/$id');
    _channel.setMethodCallHandler(_receivedData);
  }
  Future<void> _receivedData(MethodCall call) async {
    switch (call.method) {
      case 'loadingData':
        loading(true);
        break;
      case 'receivedDropData':
        List<dynamic> data = call.arguments as List<dynamic>;
        List<Map<String, dynamic>> receivedData =
            data.map((e) => Map<String, dynamic>.from(e)).toList();

        dataReceived(_processData(receivedData));
        break;
    }
  }

  List<DropData> _processData(List<Map<String, dynamic>> data) {
    List<DropData> dropDataList = [];
    for (var d in data) {
      if (d['text'] != null) {
        //add text
        var text = d['text'] as String;
        var fileType = d['fileType'] as String?;
        var dropData = DropData(
            type: DropDataType.text,
            dropText: text,
            metadata: fileType != null ? {'fileType': fileType} : {});
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
    loading(false);
    return dropDataList;
  }

  /// Refreshes the params of the NativeDropView
  ///
  /// Set allowedTotal = -1 if you don't want to have a limit
  refreshDropViewParams(int? allowedTotal, List<DropDataType>? dataTypes,
      List<String>? fileExts) async {
    await _channel.invokeMethod("updateParams", {
      'allowedTotal': allowedTotal,
      'allowedDropDataTypes':
          dataTypes?.map((dropDataType) => dropDataType.name).toList(),
      'allowedDropFileExtensions': fileExts
    });
  }
}

enum DropDataType { text, url, image, video, audio, pdf, file }

class DropData {
  File? dropFile;
  String? dropText;
  DropDataType type;
  Map<String, dynamic>? metadata;
  DropData({this.dropFile, this.dropText, this.metadata, required this.type});
}
