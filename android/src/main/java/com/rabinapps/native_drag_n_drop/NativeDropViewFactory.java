package com.rabinapps.native_drag_n_drop;

import android.content.Context;
import java.util.Map;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
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
        @SuppressWarnings("unchecked") final Map<String, Object> creationParams = (Map<String, Object>) args;
        final String channelName = "DropView${viewId}";
        /// The MethodChannel that will the communication between Flutter and native Android
        MethodChannel channel = new MethodChannel(messenger, channelName);

        return new NativeDropView(context, viewId, creationParams, channel);
    }
}
