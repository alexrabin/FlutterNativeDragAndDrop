import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  ///
  /// When [DropDataType.file] is allowed, it will also allow [DropDataType.image], [DropDataType.audio], [DropDataType.video], and [DropDataType.pdf]. Their type will be set as [DropDataType.file] unless their type is also included here.
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

  static const viewType = 'DropPlatformView';

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
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // TODO: Switch handleAndroidVirtual() for better performance below Android 10, if it works with drag and drop
        return handleAndroidHybrid();
      case TargetPlatform.iOS:
        return handleIOS();
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
      default:
        return Container(child: widget.child);
    }
  }

  /// Hybrid composition appends the native `android.view.View` to the view hierarchy.
  /// Therefore, keyboard handling, and accessibility work out of the box. Prior to
  /// Android 10, this mode might significantly reduce the frame throughput (FPS)
  /// of the Flutter UI. See [performance](https://docs.flutter.dev/development/platform-integration/platform-views?tab=android-platform-views-java-tab#performance)
  /// for more info.
  /// 
  /// Requires minSdkVersion 19
  Stack handleAndroidHybrid() {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: PlatformViewLink(
            viewType: NativeDropView.viewType,
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <
                    Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: NativeDropView.viewType,
                layoutDirection: TextDirection.ltr,
                creationParams: _creationParams,
                creationParamsCodec: NativeDropView._decoder,
                onFocus: () {
                  params.onFocusChanged(true);
                },
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            },
          ),
        ),
      ],
    );
  }

  /// Virtual displays renders the `android.view.View` instance to a texture,
  /// so it's not embedded within the Android Activity’s view hierachy. Certain
  /// platform interactions such as keyboard handling, and accessibility
  /// features might not work.
  /// 
  /// Requires minSdkVersion 20
  Stack handleAndroidVirtual() {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: AndroidView(
            viewType: NativeDropView.viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: _creationParams,
            creationParamsCodec: NativeDropView._decoder,
          ),
        ),
      ],
    );
  }

  Stack handleIOS() {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: UiKitView(
            viewType: NativeDropView.viewType,
            onPlatformViewCreated: _onPlatformViewCreated,
            creationParams: _creationParams,
            creationParamsCodec: NativeDropView._decoder,
          ),
        ),
      ],
    );
  }

  Map<String, Object?> get _creationParams {
    return {
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
    };
  }

  void _onPlatformViewCreated(int id) {
    _dropController =
        DropViewController(id, widget.loading, widget.dataReceived);
    if (widget.created != null) {
      widget.created!(_dropController);
    }
  }
}
