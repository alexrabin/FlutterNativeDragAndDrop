package com.rabinapps.native_drag_n_drop;

import static com.rabinapps.native_drag_n_drop.Utils.isMap;

import android.annotation.SuppressLint;
import android.content.Context;

import java.util.HashMap;
import java.util.Map;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class NativeDropViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    NativeDropViewFactory(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        super(StandardMessageCodec.INSTANCE);
        messenger = flutterPluginBinding.getBinaryMessenger();
    }

    @Override
    public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
        final Map<String, Object> creationParams;
        if (isMap(args)) {
            @SuppressWarnings("unchecked") final Map<String, Object> temp = (Map<String, Object>) args;
            creationParams = temp;
        } else {
            creationParams = new HashMap<>();
            Log.w("NativeDropViewFactory", "Could not load arguments. Arguments was not of type Map<String, Object>");
        }

        @SuppressLint("DefaultLocale") final String channelName = String.format("DropView/%d", viewId);
        Log.i("NativeDropViewFactory", String.format("%s created", channelName));
        /// The MethodChannel that will the communication between Flutter and native Android
        MethodChannel channel = new MethodChannel(messenger, channelName);

        return new NativeDropView(context, viewId, creationParams, channel);
    }
}
