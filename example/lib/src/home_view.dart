import 'dart:io';
import 'dart:math';
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
  final TextEditingController _textFieldController = TextEditingController();
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
  bool _receiveNonAllowedItems = true;
  List<String> allowedFileExtensions = [];
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
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: StatefulBuilder(builder: (context, setState) {
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
                          Expanded(
                            child: ListView(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                        'Allowed items to be dropped at a time:'),
                                  ),
                                ),
                                if (Platform.isAndroid)
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                          "Cannot change allowed limit on Android"),
                                    ),
                                  ),
                                if (Platform.isIOS)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(allowedItemsAtOnce != 0
                                          ? "${allowedItemsAtOnce.toInt()} items allowed"
                                          : "No limit"),
                                    ),
                                  ),
                                if (Platform.isIOS)
                                  Slider(
                                    value: allowedItemsAtOnce,
                                    max: 20,
                                    divisions: 20,
                                    min: 0,
                                    label:
                                        allowedItemsAtOnce.round().toString(),
                                    onChanged: (value) {
                                      _setState(() {
                                        allowedItemsAtOnce = value;
                                      });
                                    },
                                  ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CheckboxListTile(
                                      title: const Text(
                                          "Receive non-allowed items if at least one item is allowed"),
                                      value: _receiveNonAllowedItems,
                                      subtitle: Row(
                                        children: [
                                          TextButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        content: const Text(
                                                            "It is recommended to keep this enabled, and instead give feedback to the user when they have dropped an item that is not allowed."),
                                                        actions: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  "Awesome!"))
                                                        ],
                                                      );
                                                    });
                                              },
                                              icon: const Icon(Icons.info),
                                              label: const Text(
                                                  "Why would I want this?")),
                                          const Spacer()
                                        ],
                                      ),
                                      onChanged: (bool? value) {
                                        _setState(() {
                                          _receiveNonAllowedItems = value!;
                                        });
                                      }),
                                ),
                                const Divider(),
                                const Center(
                                    child: Text('Allowed data types:')),
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                      child: Row(
                                    children: [
                                      const Text('Allowed file extensions:'),
                                      const Spacer(),
                                      ElevatedButton(
                                          onPressed: () {
                                            _displayTextInputDialog(context);
                                          },
                                          child: const Text("Add extension")),
                                    ],
                                  )),
                                ),
                                ...allowedFileExtensions
                                    .mapIndexed((ext, index) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          ext,
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            _setState(() {
                                              allowedFileExtensions
                                                  .removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                      const Divider()
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  );
                });
            if (_dropViewController != null) {
              _dropViewController!.refreshDropViewParams(
                  allowedTotal: allowedItemsAtOnce.toInt(),
                  allowedDropDataTypes: dataTypes.keys
                      .where((element) => dataTypes[element] == true)
                      .toList(),
                  allowedDropFileExtensions: allowedFileExtensions,
                  receiveNonAllowedItems: _receiveNonAllowedItems);
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
                receiveNonAllowedItems: _receiveNonAllowedItems,
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
  final bool receiveNonAllowedItems;
  const ListNativeDropView(
      {Key? key,
      required this.allowedItemsAtOnce,
      this.allowedDataTypes,
      this.allowedFileExtensions,
      required this.created,
      this.receiveNonAllowedItems = false})
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
    return SafeArea(
      child: Column(
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
                    receiveNonAllowedItems: widget.receiveNonAllowedItems,
                    created: widget.created,
                    child: receivedData.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: receivedData.length,
                            itemBuilder: (context, index) {
                              return Dismissible(
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (d) {
                                    receivedData.removeAt(index);
                                    setState(() {});
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Spacer(),
                                        Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                  key: Key(Random().nextInt(10000).toString()),
                                  child: Builder(
                                    builder: (context) {
                                      var data = receivedData[index];
                                      if (data.type == DropDataType.text ||
                                          data.type == DropDataType.url) {
                                        return ListTile(
                                          title: Text(data.dropText!),
                                          subtitle: Text(data.type.toString()),
                                        );
                                      }
                                      if (data.type == DropDataType.image) {
                                        return DroppedImageListTile(
                                          dropData: data,
                                        );
                                      }

                                      return ListTile(
                                        title: Text(data.dropFile!.path),
                                        subtitle: Text(data.type.toString()),
                                      );
                                    },
                                  ));
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
      ),
    );
  }
}
