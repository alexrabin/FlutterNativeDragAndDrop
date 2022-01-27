package com.rabinapps.native_drag_n_drop;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/** NativeDragNDropPlugin */
public class NativeDragNDropPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    NativeDropViewFactory factory = new NativeDropViewFactory(flutterPluginBinding);
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("native_drag_n_drop", factory);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
