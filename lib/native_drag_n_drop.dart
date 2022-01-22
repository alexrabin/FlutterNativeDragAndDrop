import 'dart:async';

import 'package:flutter/services.dart';
export 'package:native_drag_n_drop/src/drop_view_controller.dart';
export 'package:native_drag_n_drop/src/native_drop_view.dart';

class NativeDragNDrop {
  static const MethodChannel _channel = MethodChannel('native_drag_n_drop');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
