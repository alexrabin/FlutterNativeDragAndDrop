package com.rabinapps.native_drag_n_drop;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/** NativeDragNDropPlugin */
public class NativeDragNDropPlugin implements FlutterPlugin, ActivityAware {
  @Nullable
  private FlutterPluginBinding flutterPluginBinding;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d("[DART/NATIVE]", "NativeDragNDropPlugin.onAttachedToEngine");
    this.flutterPluginBinding = flutterPluginBinding;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.d("[DART/NATIVE]", "NativeDragNDropPlugin.onDetachedFromEngine");
    this.flutterPluginBinding = binding;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    Log.d("[DART/NATIVE]", "NativeDragNDropPlugin.onAttachedToActivity");
    if (flutterPluginBinding == null) {
      Log.d("[DART/NATIVE]", "NativeDragNDropPlugin.onAttachedToActivity: flutterPluginBinding was null so unable to create factory");
      return;
    }

    NativeDropViewFactory factory = new NativeDropViewFactory(flutterPluginBinding, activityPluginBinding);
    flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("DropPlatformView", factory);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.d("[DART/NATIVE]", "NativeDragNDropPlugin.onDetachedFromActivityForConfigChanges");
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    Log.d("[DART/NATIVE]", "NativeDragNDropPlugin.onReattachedToActivityForConfigChanges");
  }

  @Override
  public void onDetachedFromActivity() {
    Log.d("[DART/NATIVE]", "NativeDragNDropPlugin.onDetachedFromActivity");
  }
}
