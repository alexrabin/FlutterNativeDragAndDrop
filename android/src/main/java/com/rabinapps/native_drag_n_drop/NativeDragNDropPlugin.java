package com.rabinapps.native_drag_n_drop;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/** NativeDragNDropPlugin */
public class NativeDragNDropPlugin implements FlutterPlugin {
  private NativeDropViewFactory factory;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    factory = new NativeDropViewFactory(flutterPluginBinding);
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("flutter_native_text_input", factory);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
