# native_drag_n_drop

A package that allows you to add native drag and drop support into your flutter app.

![dragndropexample](https://user-images.githubusercontent.com/15949910/150646463-8c3c6c87-8d41-4a26-a824-ac1455524fee.gif)


## Currently supported features
* Support iPadOS 11 and iOS 15 and above
* Only has drop support (can drag data from outside of the app and drop into your flutter application)
* Supports text, urls, images, videos, audio, and pdfs
* Can drop multiple items at once

## Usage

```dart
import 'package:native_drag_n_drop/native_drag_n_drop.dart';

List<DropData> receivedData = [];

@override
Widget build(BuildContext context) {
    return NativeDropView(
    allowedTotal: 5,
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
    dataReceived: (data) {
        setState(() {
            receivedData.addAll(data);
        });
    });
}

```

The dataReceivedCallback returns `List<DropData>`. 

```dart
enum DropDataType { text, url, image, video, audio, pdf }

class DropData {
  File? dropFile;
  String? dropText;
  Map<String, dynamic>? metadata;
  DropDataType type;
  DropData({this.dropFile, this.dropText, this.metadata, required this.type});
}
```
It is safe to assume that if the dataType is text or url then the dropText will be non null.

As for image, video, audio, pdf it is safe to assume the dropFile will be non null

## Todo

- [x] specify the number of items allowed to be dropped at a time
- [ ] Only allow certain data types
- [ ] Android Support
- [ ] Drag support (Dragging data within app to a source outside of flutter app)

## Contributing

This is a very early release. I will take as much help as possible.

Please make a pr and show an example if possible.

<details>
  <summary>These are some resources that may help you when it comes to adding drag and drop support: </summary>
    
- [Flutter Platform Views](https://docs.flutter.dev/development/platform-integration/platform-views?tab=android-platform-views-java-tab)
- [An example of how to use flutter platform views](https://github.com/ryan-alfi/flutter-platform-view)
- [iOS Drag and Drop Docs](https://developer.apple.com/documentation/uikit/drag_and_drop)
- [iOS make a uiview a drop desitination](https://developer.apple.com/documentation/uikit/drag_and_drop/making_a_view_into_a_drop_destination)
- [iOS make a uiview into a drag source](https://developer.apple.com/documentation/uikit/drag_and_drop/making_a_view_into_a_drag_source)


</details>
