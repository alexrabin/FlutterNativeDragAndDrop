import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_drag_n_drop/src/drop_data.dart';
import 'package:native_drag_n_drop/src/drop_view_controller.dart';

class NativeDropView extends StatefulWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  ///the child container in the dropview
  final Widget child;

  ///background color of the dropview
  final Color? backgroundColor;

  /// border color of the dropview
  final Color? borderColor;

  ///border width of the dropview
  final int? borderWidth;

  ///triggered when the data is dropped into the dropview
  final DropViewLoadingCallback loading;

  ///triggered when the data has been received
  final DropViewDataReceivedCallback dataReceived;

  /// triggered when a controller has been initiated
  final DropViewCreatedCallback? created;

  /// number of items allowed to be dropped at a time
  ///
  /// When [allowedTotal] is 0 there is no limit
  final int allowedTotal;

  /// Restrict the types of data that can be dropped.
  final List<DropDataType>? allowedDropDataTypes;

  /// Restrict the types of files that can be dropped in addition to files allowed by `allowedDropDataTypes`. All file types included in `allowedDropDataTypes` will be accepted if this is null.
  ///
  /// Note that this won't affect files if their data type is included in `allowedDropDataTypes`
  final List<String>? allowedDropFileExtensions;

  /// Receive all dropped items if at least one item is allowed. Defaults to true
  /// 
  /// Disable this to only receive items that have been allowed in `allowedDropDataTypes` and `allowedDropFileExtensions`
  /// 
  /// It is recommended to keep this enabled, and instead give feedback to the user when they have dropped an item that is not allowed.
  final bool receiveNonAllowedItems;

  /// A widget that adds drag and drop functionality
  ///
  /// Must set allowedDropDataTypes or allowedDropFileExtensions
  const NativeDropView(
      {Key? key,
      required this.child,
      this.allowedTotal = 0,
      this.allowedDropDataTypes,
      this.allowedDropFileExtensions,
      this.receiveNonAllowedItems = true,
      required this.loading,
      required this.dataReceived,
      this.backgroundColor,
      this.borderColor,
      this.borderWidth,
      this.created})
      : assert((borderColor == null && borderWidth == null) ||
            (borderColor != null && borderWidth != null) ||
            allowedDropDataTypes != null ||
            allowedDropFileExtensions != null ||
            allowedTotal >= 0),
        super(key: key);

  @override
  State<NativeDropView> createState() => _NativeDropViewState();
}

class _NativeDropViewState extends State<NativeDropView> {
  late DropViewController _dropController;

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
                "allowedDropDataTypes": widget.allowedDropDataTypes
                    ?.map((dropDataType) => dropDataType.name)
                    .toList(),
                "allowedDropFileExtensions": widget.allowedDropFileExtensions
                    ?.map((fileExt) => fileExt.toLowerCase())
                    .toList(),
                "receiveNonAllowedItems": widget.receiveNonAllowedItems,
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
    _dropController =
        DropViewController(id, widget.loading, widget.dataReceived);
    if (widget.created != null) {
      widget.created!(_dropController);
    }
  }
}
