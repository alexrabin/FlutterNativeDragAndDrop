import 'package:flutter/material.dart';
import 'package:native_drag_n_drop/native_drag_n_drop.dart';
import 'package:native_drag_n_drop_example/src/dropped_image_list_title.dart';

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController _textFieldController = TextEditingController();
  double allowedItemsAtOnce = 5;
  DropViewController? _dropViewController;
  Map<DropDataType, bool> dataTypes = {
    DropDataType.text: true,
    DropDataType.image: true,
    DropDataType.video: true,
    DropDataType.url: true,
    DropDataType.pdf: true,
    DropDataType.audio: true,
    DropDataType.file: true
  };

  List<String> allowedFileExtensions = [];
  var panelActiveStatus = [false, false, false];
  late StateSetter _setState;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    _setState = setState;
                    return Column(
                      children: [
                        const SizedBox(
                          height: 12.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12.0))),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 18.0,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                      'Allowed items to be dropped at a time:'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(allowedItemsAtOnce != 0
                                      ? "${allowedItemsAtOnce.toInt()} items allowed"
                                      : "No limit"),
                                ),
                              ),
                              Slider(
                                value: allowedItemsAtOnce,
                                max: 20,
                                divisions: 20,
                                min: 0,
                                label: allowedItemsAtOnce.round().toString(),
                                onChanged: (value) {
                                  _setState(() {
                                    allowedItemsAtOnce = value;
                                  });
                                },
                              ),
                              const Divider(),
                              const Center(child: Text('Allowed data types:')),
                              ...dataTypes.keys.map((key) {
                                return CheckboxListTile(
                                    title: Text(key.toString()),
                                    value: dataTypes[key],
                                    onChanged: (bool? value) {
                                      _setState(() {
                                        dataTypes[key] = value!;
                                      });
                                    });
                              }).toList(),
                              const Divider(),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text('Allowed file extensions:')),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    _displayTextInputDialog(context);
                                  },
                                  child: const Text("Add extension")),
                              ...allowedFileExtensions.mapIndexed((ext, index) {
                                return ListTile(
                                  title: Text(
                                    ext,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _setState(() {
                                        allowedFileExtensions.removeAt(index);
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    );
                  });
                });
            if (_dropViewController != null) {
              _dropViewController!.refreshDropViewParams(
                  allowedTotal:
                      allowedItemsAtOnce == 0 ? -1 : allowedItemsAtOnce.toInt(),
                  allowedDropDataTypes: dataTypes.keys
                      .where((element) => dataTypes[element] == true)
                      .toList(),
                  allowedDropFileExtensions: allowedFileExtensions);
            }
          },
        ),
        title: const Text('Drag and Drop'),
      ),
      body: SafeArea(
        child: Center(
          child: ListView(
            children: [
              ListNativeDropView(
                allowedItemsAtOnce: allowedItemsAtOnce.toInt(),
                allowedDataTypes: dataTypes.keys
                    .where((element) => dataTypes[element] == true)
                    .toList(),
                allowedFileExtensions: allowedFileExtensions,
                created: (DropViewController controller) {
                  _dropViewController = controller;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Extension'),
            content: TextField(
              keyboardType: TextInputType.text,
              autocorrect: false,
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Extension name"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    valueText = '';
                    _textFieldController.text = '';
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () {
                  setState(() {
                    allowedFileExtensions.add(valueText);
                    valueText = '';
                    _textFieldController.text = '';

                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  String valueText = '';
}

class ListNativeDropView extends StatefulWidget {
  final int allowedItemsAtOnce;
  final List<DropDataType>? allowedDataTypes;
  final List<String>? allowedFileExtensions;
  final DropViewCreatedCallback created;
  const ListNativeDropView(
      {Key? key,
      required this.allowedItemsAtOnce,
      this.allowedDataTypes,
      this.allowedFileExtensions,
      required this.created})
      : super(key: key);

  @override
  _ListNativeDropViewState createState() => _ListNativeDropViewState();
}

class _ListNativeDropViewState extends State<ListNativeDropView> {
  bool loadingData = false;
  List<DropData> receivedData = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        receivedData.isNotEmpty
            ? TextButton(
                onPressed: () {
                  setState(() {
                    receivedData.clear();
                  });
                },
                child: const Text("Clear Data"))
            : Container(),
        Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: NativeDropView(
                  allowedTotal: widget.allowedItemsAtOnce,
                  allowedDropDataTypes: widget.allowedDataTypes,
                  allowedDropFileExtensions: widget.allowedFileExtensions,
                  created: widget.created,
                  child: receivedData.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
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
            ),
            loadingData
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container()
          ],
        ),
      ],
    );
  }
}
