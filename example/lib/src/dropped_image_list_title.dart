import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:native_drag_n_drop/native_drag_n_drop.dart';

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
