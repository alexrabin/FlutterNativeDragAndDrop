# native_drag_n_drop

<p align="center">
  <img src="https://user-images.githubusercontent.com/15949910/150895221-6a4e58f8-4238-43e6-8549-4e626389985b.png" width=250/>
</p>
<p align="center">
 
 <a href="https://pub.dartlang.org/packages/native_drag_n_drop">
    <img alt="native_drag_n_drop" src="https://img.shields.io/pub/v/native_drag_n_drop.svg">
  </a>
 <a href="https://www.paypal.com/donate/?hosted_button_id=6ZB3J8WR4CNV8">
    <img alt="Donate" src="https://img.shields.io/badge/Donate-PayPal-blue.svg">
  </a>
 <a href="https://www.buymeacoffee.com/alexrabin">
    <img alt="Buy me a coffee" src="https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg">
  </a>
<img alt="GitHub issues" src="https://img.shields.io/github/issues/alexrabin/FlutterNativeDragAndDrop?color=red">
  <img src="https://img.shields.io/github/license/alexrabin/FlutterNativeDragAndDrop">
  <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/alexrabin/FlutterNativeDragAndDrop?style=social">
</p>

A package that allows you to add native drag and drop support into your flutter app.

![iPadDropExample](https://user-images.githubusercontent.com/15949910/150702838-817e24cd-9494-43e3-a077-64a036393b0a.gif)

<img src="https://user-images.githubusercontent.com/15949910/150670673-c19d7d65-f9b0-4a3f-8e2a-aae8b241e28d.gif" width="500"/>

<img src="https://user-images.githubusercontent.com/15949910/151897557-0e1d9ecf-487c-437c-b301-b8c955ab2efa.gif" width="500"/>

## Currently supported features
* Support iPadOS 11, iOS 15, and Android 8.0 and above
* Only has drop support (can drag data from outside of the app and drop into your flutter application)
* Supports text, urls, images, videos, audio, pdfs, and custom file extensions
* Can drop multiple items at once
* Can add allowed number of items to be dragged at a time (iOS only. Android doesn't have this capability)
## Usage

```dart
import 'package:native_drag_n_drop/native_drag_n_drop.dart';

List<DropData> receivedData = [];

@override
Widget build(BuildContext context) {
    return NativeDropView(
    allowedTotal: 5, //Allowed total only works on iOS (Android has limitations)
    allowedDropDataTypes: const [DropDataType.text, DropDataType.image, DropDataType.video],
    allowedDropFileExtensions: ['apk', 'dart'],
    receiveNonAllowedItems: false,
    child: receivedData.isNotEmpty
        ? ListView.builder(
            itemCount: receivedData.length,
            itemBuilder: (context, index) {
                var data = receivedData[index];
                if (data.type == DropDataType.text) {
                    return ListTile(
                    title: Text(data.dropText!),
                    );
                }

                return ListTile(
                    title: Text(data.dropFile!.path),
                );
            })
        : const Center(
            child: Text("Drop data here"),
        ),
    loading: (loading) {
        // display loading indicator / hide loading indicator
    },
    dataReceived: (List<DropData> data) {
        setState(() {
            receivedData.addAll(data);
        });
    });
}

```

The dataReceived callback returns `List<DropData>`. 

```dart
enum DropDataType { text, url, image, video, audio, pdf, file}

class DropData {
  File? dropFile;
  String? dropText;
  Map<String, dynamic>? metadata;
  DropDataType type;
  DropData({this.dropFile, this.dropText, this.metadata, required this.type});
}
```
It is safe to assume that if the dataType is text or url then the dropText will be non null.

As for image, video, audio, pdf, file it is safe to assume the dropFile will be non null

All files are saved to the temp directory on the device so if you want to save the file to the device [copy its data to a file in the documents directory](https://programmingwithswift.com/how-to-save-a-file-locally-with-flutter/). 
## Todo

- [x] specify the number of items allowed to be dropped at a time
- [x] Only allow certain data types
- [x] Android Support
- [ ] Drag support (Dragging data within app to a source outside of flutter app)
