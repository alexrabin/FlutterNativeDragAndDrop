package com.rabinapps.native_drag_n_drop;

import static com.rabinapps.native_drag_n_drop.Utils.isMap;
import static com.rabinapps.native_drag_n_drop.Utils.getPathFromUri;

import android.app.Activity;
import android.content.ClipData;
import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.view.DragEvent;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.view.DragAndDropPermissionsCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class NativeDropView implements PlatformView {
    @NonNull private final View dragView;
    @NonNull private final Activity activity;
    @NonNull private final MethodChannel channel;
    @NonNull private final Context context;

    public NativeDropView(@NonNull Context context,
                          int viewId,
                          @NonNull Map<String, Object> creationParams,
                          @NonNull MethodChannel channel,
                          @NonNull Activity activity) {
        // init data from flutter here
        this.context = context;
        this.dragView = new View(context);
        dragView.setOnDragListener(viewDragListener());
        this.channel = channel;
        this.activity = activity;
        channel.setMethodCallHandler(channelMethodCallHandler());
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
            Log.w("[DART/NATIVE]","NativeDropView.newMimeType: " + mimeType);
            // Handles each of the expected events.
            switch (action) {
                case DragEvent.ACTION_DRAG_STARTED:
                    if (mimeType == null || "".equals(mimeType)) {
                        return false;
                    }

                    if (isImage(mimeType) || isText(mimeType) || isPdf(mimeType) ||isVideo(mimeType) || isAudio(mimeType) || isUri(mimeType)) {
                        // Show in UI it can be accepted
                        return true;
                    }

                    return false;

                case DragEvent.ACTION_DRAG_ENTERED:
                    return true;

                case DragEvent.ACTION_DROP:
                    sendLoadingNotification();
                    handleDroppedData(event);
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
                    Log.w("[DART/NATIVE]","NativeDropView.viewDragListener: Unknown action type received by View.OnDragListener.");
                    break;
            }
            return false;
        };
    }

    private void showToast(String message) {
        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
    }

    private boolean isImage(String mime) {
        return mime.startsWith("image/");
    }

    private boolean isText(String mime) {
        return mime.startsWith("text/");
    }

    private boolean isPdf(String mime) {
        return mime.startsWith("application/pdf");
    }

    private boolean isVideo(String mime) {
        return mime.startsWith("video/");
    }

    private boolean isAudio(String mime) {
        return mime.startsWith("audio/");
    }
    private boolean isUri(String mime){return mime.startsWith("text/uri");}

    private void handleDroppedData(DragEvent event){
        final ArrayList<Map<String, Object>> data = new ArrayList<>();

        View vw = (View) event.getLocalState();
        if (vw != null){
            sendDropData(data);
            return;
        }
        ClipData clipData = event.getClipData();
        int clipCount = event.getClipData().getItemCount();
        for (int i = 0; i <clipCount; i++){
            ClipData.Item item = clipData.getItemAt(i);
            String mimeType = event.getClipDescription().getMimeType(i);
            if (isImage(mimeType)){
                Uri uri = item.getUri();
                Map<String, Object> urlMap = handleFileDrop(event, uri, "image");
                if (urlMap != null)
                    data.add(urlMap);
            }
            else if (isVideo(mimeType)){
                Uri uri = item.getUri();
                Map<String, Object> urlMap = handleFileDrop(event, uri, "video");
                if (urlMap != null)
                    data.add(urlMap);
            }
            else if (isAudio(mimeType)){
                Uri uri = item.getUri();
                Map<String, Object> urlMap = handleFileDrop(event, uri, "audio");
                if (urlMap != null)
                    data.add(urlMap);
            }
            else if (isPdf(mimeType)){
                Uri uri = item.getUri();
                Map<String, Object> urlMap = handleFileDrop(event, uri, "pdf");
                if (urlMap != null)
                    data.add(urlMap);
            }
            else if (isUri(mimeType)){
                String dragData = item.getUri().toString();
                final Map<String, Object> textMap = new HashMap<>();
                textMap.put("url", dragData);
                data.add(textMap);
            }
            else if (isText(mimeType)){
                String dragData = item.getText().toString();
                final Map<String, Object> textMap = new HashMap<>();
                textMap.put("text", dragData);
                data.add(textMap);
            }

        }
        sendDropData(data);

    }

    private Map<String, Object> handleFileDrop(DragEvent event, Uri uri, String dataType){
        if (ContentResolver.SCHEME_CONTENT.equals(uri.getScheme())) {
            // Accessing a "content" scheme Uri requires a permission grant.
            DragAndDropPermissionsCompat dropPermissions;
            dropPermissions = ActivityCompat
                    .requestDragAndDropPermissions(activity, event);

            if (dropPermissions == null) {
                // Permission could not be obtained.
                Log.w("[DART/NATIVE]", "NativeDropView.handleFileDrop: Permission could not be obtained to drop file");
                showToast("Permission could not be obtained to drop file");
                // Send empty list to end loading state
//                final Map<String, Object> urlMap = new HashMap<>();
//                urlMap.put(dataType, "Permission could not be obtained to drop file");
                return null;
            }

            final Map<String, Object> urlMap = new HashMap<>();
            String path = getPathFromUri(activity, uri);
            urlMap.put(dataType, path);
            return urlMap;
        } else {
            // Other schemes (such as "android.resource") do not require a permission grant.
            final Map<String, Object> urlMap = new HashMap<>();
            urlMap.put(dataType, uri.getPath());
            return urlMap;
        }
    }

    public void sendDropData(@Nullable Object data){
        Log.w("[DART/NATIVE]", "NativeDropView.sendDropData: Sending data");

        channel.invokeMethod("receivedDropData", data);
    }

    public void sendLoadingNotification(){
        channel.invokeMethod("loadingData", "Loading your data");
    }

    @NonNull
    private MethodChannel.MethodCallHandler channelMethodCallHandler() {
        return (call, result) -> {
            if ("updateParams".equals(call.method)) {

                if (isMap(call.arguments)) {
                    @SuppressWarnings("unchecked") final Map<String, Object> flutterArgs = (Map<String, Object>) call.arguments;

                } else {
                    Log.w("[DART/NATIVE]", "NativeDropView.channelMethodCallHandler's updateParams: Could not load arguments. Arguments was not of type Map<String, Object>");
                }
            }
        };
    }

    @NonNull
    @Override
    public View getView() {
        return dragView;
    }

    @Override
    public void dispose() {}
}
