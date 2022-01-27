package com.rabinapps.native_drag_n_drop;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** NativeDragNDropPlugin */
public class NativeDragNDropPlugin implements FlutterPlugin {
  private NativeDragNDropFactory factory;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    factory = new NativeDragNDropFactory(flutterPluginBinding);
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("flutter_native_text_input", factory);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
