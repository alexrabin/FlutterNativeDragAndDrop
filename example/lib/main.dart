import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_drag_n_drop/native_drag_n_drop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loadingData = false;
  List<List<DropData>> receivedData = [[], [], []];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Drag and Drop Example'),
        ),
        body: SafeArea(
          child: Center(
            child: Stack(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      NativeDropView(
                          allowedDropDataTypes: const <DropDataType>[
                            DropDataType.image,
                          ],
                          allowedDropFileExtensions: const <String>[
                            'epub',
                            'apk',
                          ],
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
                                    if (data.type == DropDataType.image) {
                                      return DroppedImageListTile(
                                        dropData: data,
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
                            setState(() {
                              loadingData = loading;
                            });
                          },
                          dataReceived: (data) {
                            setState(() {
                              receivedData.addAll(data);
                            });
                          }),
                      loadingData
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class DroppedImageListTile extends StatelessWidget {
  const DroppedImageListTile({Key? key, required this.dropData})
      : super(key: key);

  final DropData dropData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: dropData.dropFile?.readAsBytes(),
      builder: (
        BuildContext context,
        AsyncSnapshot snapshot,
      ) {
        if (snapshot.hasError) {
          return ListTile(
            title: Text(snapshot.error!.toString()),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: MemoryImage(snapshot.data!),
            ),
            title: Text(dropData.dropFile?.path ?? 'Path unknown'),
          );
        }

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.white,
            child: CircularProgressIndicator(),
          ),
          title: Text(dropData.dropFile?.path ?? 'Path unknown'),
        );
      },
    );
  }
}
