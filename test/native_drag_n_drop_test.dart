import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_drag_n_drop/native_drag_n_drop.dart';

void main() {
  const MethodChannel channel = MethodChannel('native_drag_n_drop');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NativeDragNDrop.platformVersion, '42');
  });
}
