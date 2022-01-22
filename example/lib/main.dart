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
  List<DropData> receivedData = [];
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
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      NativeDropView(
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
                          loadingCallback: (loading) {
                            setState(() {
                              loadingData = loading;
                            });
                          },
                          dataReceivedCallback: (data) {
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
