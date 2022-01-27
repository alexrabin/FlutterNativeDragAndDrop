package com.rabinapps.native_drag_n_drop;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class NativeDragNDrop implements PlatformView, MethodChannel.MethodCallHandler {
    View _view;
    Context context;
    int viewId;
    Map<String, Object> creationParams;
    MethodChannel channel;

    public NativeDragNDrop(@NonNull Context context, int viewId, @Nullable Map<String, Object> creationParams, @NonNull MethodChannel channel) {
        // init data from flutter here
        this.context = context;
        this.viewId = viewId;
        this.creationParams = creationParams;
        this.channel = channel;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

    }

    @Override
    public View getView() {
        return _view;
    }

    @Override
    public void dispose() {}
}
