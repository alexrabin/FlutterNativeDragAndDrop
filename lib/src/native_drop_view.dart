import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_drag_n_drop/src/drop_view_controller.dart';

typedef DropViewCreatedCallback = void Function(DropViewController controller);

class NativeDropView extends StatefulWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();
  final Widget child;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final int? borderWidth;
  final DropViewLoadingCallback loadingCallback;
  final DropViewDataReceivedCallback dataReceivedCallback;

  const NativeDropView(
      {Key? key,
      required this.child,
      this.width,
      this.height,
      this.backgroundColor,
      this.borderColor,
      this.borderWidth,
      required this.loadingCallback,
      required this.dataReceivedCallback})
      : super(key: key);

  @override
  State<NativeDropView> createState() => _NativeDropViewState();
}

class _NativeDropViewState extends State<NativeDropView> {
  late DropViewController dropController;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Stack(
        children: [
          widget.child,
          IgnorePointer(
            child: UiKitView(
              viewType: 'DropPlatformView',
              onPlatformViewCreated: _onPlatformViewCreated,
              creationParams: {
                "width": widget.width ?? MediaQuery.of(context).size.width,
                "height": widget.height ?? MediaQuery.of(context).size.height,
                "backgroundColor": widget.backgroundColor != null
                    ? [
                        widget.backgroundColor!.red,
                        widget.backgroundColor!.green,
                        widget.backgroundColor!.blue
                      ]
                    : [],
                "borderColor": widget.borderColor != null
                    ? [
                        widget.borderColor!.red,
                        widget.borderColor!.green,
                        widget.borderColor!.blue
                      ]
                    : [],
                "borderWidth": widget.borderWidth ?? 0,
              },
              creationParamsCodec: NativeDropView._decoder,
            ),
          ),
        ],
      );
    }
    return Container(
      child: widget.child,
    );
  }

  void _onPlatformViewCreated(int id) {
    dropController = DropViewController(
        id, widget.loadingCallback, widget.dataReceivedCallback);
  }
}
