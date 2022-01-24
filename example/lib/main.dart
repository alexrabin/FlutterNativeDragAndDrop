import 'package:flutter/material.dart';
import 'package:native_drag_n_drop/native_drag_n_drop.dart';
import 'package:native_drag_n_drop_example/src/home_view.dart';

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
    return const MaterialApp(home: HomeView());
  }
}
