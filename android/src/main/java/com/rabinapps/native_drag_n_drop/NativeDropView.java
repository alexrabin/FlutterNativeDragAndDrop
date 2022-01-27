package com.rabinapps.native_drag_n_drop;

import static com.rabinapps.native_drag_n_drop.Utils.isMap;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Collection;
import java.util.Map;
import java.util.Set;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class NativeDropView implements PlatformView, MethodChannel.MethodCallHandler {
    @NonNull private final View view;
    private MethodChannel channel;

    @NonNull private Context context;

    public NativeDropView(@NonNull Context context, int viewId, @NonNull Map<String, Object> creationParams, @NonNull MethodChannel channel) {
        // init data from flutter here
        this.context = context;
        this.view = new View(context);
        this.channel = channel;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if ("updateParams".equals(call.method)) {

            if (isMap(call.arguments)) {
                @SuppressWarnings("unchecked") final Map<String, Object> flutterArgs = (Map<String, Object>) call.arguments;

            } else {
                Log.w("NativeDropView: updateParams method", "Could not load arguments. Arguments was not of type Map<String, Object>");
            }
        }
    }

    public void sendDropData(@Nullable Object data){
        channel.invokeMethod("receivedDropData", data);
    }

    public void sendLoadingNotification(){
        channel.invokeMethod("loadingData", "Loading your data");
    }

    @Override
    public View getView() {
        return view;
    }

    @Override
    public void dispose() {}
}
