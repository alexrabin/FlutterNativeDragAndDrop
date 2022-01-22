import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_drag_n_drop/src/drop_view_controller.dart';

class NativeDropView extends StatefulWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  ///the child container in the dropview
  final Widget child;

  ///width of the dropview
  final double? width;

  //height of the dropview
  final double? height;

  ///background color of the dropview
  final Color? backgroundColor;

  /// border color of the dropview
  final Color? borderColor;

  //border width of the dropview
  final int? borderWidth;

  ///triggered when the data is dropped into the dropview
  final DropViewLoadingCallback loading;

  ///triggered when the data has been received
  final DropViewDataReceivedCallback dataReceived;

  /// number of items allowed to be dropped
  /// When [allowedTotal] is null there is no limit
  final int? allowedTotal;

  const NativeDropView(
      {Key? key,
      required this.child,
      this.width,
      this.height,
      this.backgroundColor,
      this.borderColor,
      this.borderWidth,
      required this.loading,
      required this.dataReceived,
      this.allowedTotal})
      : assert((borderColor == null && borderWidth == null) ||
            (borderColor != null && borderWidth != null)),
        super(key: key);

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
                "allowedTotal": widget.allowedTotal,
                "width": widget.width ?? MediaQuery.of(context).size.width,
                "height": widget.height ?? MediaQuery.of(context).size.height,
                "backgroundColor": widget.backgroundColor != null
                    ? [
                        widget.backgroundColor!.red,
                        widget.backgroundColor!.green,
                        widget.backgroundColor!.blue,
                        widget.backgroundColor!.alpha
                      ]
                    : [],
                "borderColor": widget.borderColor != null
                    ? [
                        widget.borderColor!.red,
                        widget.borderColor!.green,
                        widget.borderColor!.blue,
                        widget.borderColor!.alpha
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
    dropController =
        DropViewController(id, widget.loading, widget.dataReceived);
  }
}
