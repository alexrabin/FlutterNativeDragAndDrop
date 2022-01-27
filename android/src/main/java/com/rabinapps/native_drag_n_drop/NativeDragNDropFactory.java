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

public class NativeDragNDropFactory extends PlatformViewFactory {

    private NativeDragNDrop nativeDragNDrop;
    private final BinaryMessenger messenger;

    NativeDragNDropFactory(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        super(StandardMessageCodec.INSTANCE);
        messenger = flutterPluginBinding.getBinaryMessenger();
    }

    @Override
    public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
        @SuppressWarnings("unchecked") final Map<String, Object> creationParams = (Map<String, Object>) args;
        final String channelName = "DropView${viewId}";
        MethodChannel channel = new MethodChannel(messenger, channelName);

        return new NativeDragNDrop(context, viewId, creationParams, channel);
    }
}
