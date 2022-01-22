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
                ListView(
                  children: [
                    SizedBox(
                      height: 300,
                      child: allowOneFileAtATime(),
                    ),
                    SizedBox(
                      height: 300,
                      child: allow5FilesAtATime(),
                    ),
                    SizedBox(
                      height: 300,
                      child: noFileLimit(),
                    ),
                  ],
                ),
                loadingData
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listView(List<DropData> dataList) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          var data = dataList[index];
          if (data.type == DropDataType.text) {
            return ListTile(
              title: Text(data.dropText!),
            );
          }
          if (data.type == DropDataType.image) {
            return SizedBox(height: 100, child: Image.file(data.dropFile!));
          }
          return ListTile(
            title: Text(data.dropFile!.path),
          );
        });
  }

  Widget allowOneFileAtATime() {
    return NativeDropView(
        allowedTotal: 1,
        borderColor: Colors.blue,
        borderWidth: 2,
        child: receivedData[0].isNotEmpty
            ? listView(receivedData[0])
            : const Center(
                child: Text("Drop one item here"),
              ),
        loading: (loading) {
          setState(() {
            loadingData = loading;
          });
        },
        dataReceived: (data) {
          setState(() {
            receivedData[0].addAll(data);
          });
        });
  }

  Widget allow5FilesAtATime() {
    return NativeDropView(
        allowedTotal: 5,
        borderColor: Colors.blue,
        borderWidth: 2,
        child: receivedData[1].isNotEmpty
            ? listView(receivedData[1])
            : const Center(
                child: Text("Drop up to 5 items here"),
              ),
        loading: (loading) {
          setState(() {
            loadingData = loading;
          });
        },
        dataReceived: (data) {
          setState(() {
            receivedData[1].addAll(data);
          });
        });
  }

  Widget noFileLimit() {
    return NativeDropView(
        borderColor: Colors.blue,
        borderWidth: 2,
        child: receivedData[2].isNotEmpty
            ? listView(receivedData[2])
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
            receivedData[2].addAll(data);
          });
        });
  }
}
