package com.rabinapps.native_drag_n_drop;

import static com.rabinapps.native_drag_n_drop.Utils.isMap;

import android.app.Activity;
import android.content.ClipData;
import android.content.ContentResolver;
import android.content.Context;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.view.DragEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.view.DragAndDropPermissionsCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class NativeDropView implements PlatformView, MethodChannel.MethodCallHandler, ActivityAware {
    @NonNull private final ImageView dragView;
    @Nullable private Activity activity;
    private final MethodChannel channel;

    @NonNull private final Context context;

    public NativeDropView(@NonNull Context context, int viewId, @NonNull Map<String, Object> creationParams, @NonNull MethodChannel channel) {
        // init data from flutter here
        this.context = context;
        this.dragView = new ImageView(context);
        dragView.setMaxWidth(500);
        dragView.setMaxHeight(500);

        this.channel = channel;

        dragView.setOnDragListener(viewDragListener());
    }

    // Some of the below code was taken from [Microsoft's Drag and Drop example](https://github.com/microsoft/surface-duo-sdk-samples/blob/main/DragAndDrop/src/main/java/com/microsoft/device/display/samples/draganddrop/fragment/DropTargetFragment.java)
    @NonNull
    private View.OnDragListener viewDragListener() {
        return (view, event) -> {
            int action = event.getAction();
            String mimeType = "";

            if (event.getClipDescription() != null) {
                mimeType = event.getClipDescription().getMimeType(0);
            }

            // Handles each of the expected events.
            switch (action) {
                case DragEvent.ACTION_DRAG_STARTED:
                    if (mimeType == null || "".equals(mimeType)) {
                        return false;
                    }

                    if (isImage(mimeType) || isText(mimeType)) {
                        // Show in UI it can be accepted
                        return true;
                    }

                    return false;

                case DragEvent.ACTION_DRAG_ENTERED:
                    return true;

                case DragEvent.ACTION_DROP:
                    sendLoadingNotification();
                    if (isText(mimeType)) {
                        handleTextDrop(event);
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            view.setElevation(1);
                        }
                    } else if (isImage(mimeType)) {
                        handleImageDrop(event);
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            view.setElevation(1);
                        }
                    }
                    // Show in UI drop is done
                    return true;

                case DragEvent.ACTION_DRAG_ENDED:
//                    if (event.getResult()) {
//                        // Show in drop was either handled
//                    } else {
//                        // Show in drop didn't work
//                    }
                    return true;

                case DragEvent.ACTION_DRAG_LOCATION:
                case DragEvent.ACTION_DRAG_EXITED:
                    // Ignore events
                    return true;
                // An unknown action type was received.
                default:
                    Log.e("NativeDropView","Unknown action type received by View.OnDragListener.");
                    break;
            }
            return false;
        };
    }

    private void showToast(String message) {
        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
    }

//    private void setBackgroundColor(String mimeType) {
//        ColorFilter colorFilter = new PorterDuffColorFilter(Color.GRAY,
//                PorterDuff.Mode.SRC_IN);
//        if (isImage(mimeType)) {
//            imageHintContainer.getBackground().setColorFilter(colorFilter);
//            imageHintContainer.setElevation(4);
//            imageHintContainer.invalidate();
//        } else if (isText(mimeType)) {
//            textHintContainer.getBackground().setColorFilter(colorFilter);
//            textHintContainer.setElevation(4);
//            textHintContainer.invalidate();
//        }
//    }
//
//    private void clearBackgroundColor(String mimeType) {
//        if (isImage(mimeType)) {
//            imageHintContainer.getBackground().clearColorFilter();
//            imageHintContainer.setElevation(0);
//            imageHintContainer.invalidate();
//        } else if (isText(mimeType)) {
//            textHintContainer.getBackground().clearColorFilter();
//            textHintContainer.setElevation(0);
//            textHintContainer.invalidate();
//        }
//    }
//
//    private void clearBackgroundColor() {
//        imageHintContainer.getBackground().clearColorFilter();
//        imageHintContainer.setElevation(0);
//        imageHintContainer.invalidate();
//        textHintContainer.getBackground().clearColorFilter();
//        textHintContainer.setElevation(0);
//        textHintContainer.invalidate();
//    }

    private boolean isImage(String mime) {
        return mime.startsWith("image/");
    }

    private boolean isText(String mime) {
        return mime.startsWith("text/");
    }

    private void handleTextDrop(DragEvent event) {
        ClipData.Item item = event.getClipData().getItemAt(0);
        String dragData = item.getText().toString();
        View vw = (View) event.getLocalState();

        // Handle if drop from outside app, vw is null if drop from another app
        if (vw == null) {
            final ArrayList<Map<String, Object>> data = new ArrayList<Map<String, Object>>();
            final Map<String, Object> textMap = new HashMap<String, Object>();
            textMap.put("text", dragData);
            data.add(textMap);
            sendDropData(data);
        }
    }

    private void handleImageDrop(DragEvent event) {
        ClipData.Item item = event.getClipData().getItemAt(0);
        View vw = (View) event.getLocalState();
        // Handle if drop from outside app, vw is null if drop from another app
        if (vw == null) {
            Uri uri = item.getUri();
            if (ContentResolver.SCHEME_CONTENT.equals(uri.getScheme())) {
                // Accessing a "content" scheme Uri requires a permission grant.
                DragAndDropPermissionsCompat dropPermissions = ActivityCompat
                        .requestDragAndDropPermissions(activity, event);

                if (dropPermissions == null) {
                    // Permission could not be obtained.
                    return;
                }

                final ArrayList<Map<String, Object>> data = new ArrayList<Map<String, Object>>();
                final Map<String, Object> urlMap = new HashMap<String, Object>();
                urlMap.put("image", uri.getPath());
                data.add(urlMap);
                sendDropData(data);
            } else {
                // Other schemes (such as "android.resource") do not require a permission grant.
                final ArrayList<Map<String, Object>> data = new ArrayList<Map<String, Object>>();
                final Map<String, Object> urlMap = new HashMap<String, Object>();
                urlMap.put("image", uri.getPath());
                data.add(urlMap);
                sendDropData(data);
            }
        }
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

    @NonNull
    @Override
    public View getView() {
        return dragView;
    }

    @Override
    public void dispose() {}

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        dragView.setOnDragListener(null);
        activity = null;
    }
}
