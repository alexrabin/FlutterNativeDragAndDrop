package com.rabinapps.native_drag_n_drop;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class NativeDropView implements PlatformView, MethodChannel.MethodCallHandler {
    @NonNull private final View view;

    @NonNull private Context context;

    public NativeDropView(@NonNull Context context, int viewId, @Nullable Map<String, Object> creationParams, @NonNull MethodChannel channel) {
        // init data from flutter here
        this.context = context;
        this.view = new View(context);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

    }

    @Override
    public View getView() {
        return view;
    }

    @Override
    public void dispose() {}
}
