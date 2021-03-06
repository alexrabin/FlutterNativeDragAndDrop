package com.rabinapps.native_drag_n_drop;

import static com.rabinapps.native_drag_n_drop.Utils.isMap;
import static com.rabinapps.native_drag_n_drop.Utils.getPathFromUri;
import static com.rabinapps.native_drag_n_drop.Utils.getFileExtension;

import android.app.Activity;
import android.content.ClipData;
import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;
import android.util.Patterns;
import android.view.DragEvent;
import android.view.View;
import android.webkit.MimeTypeMap;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.view.DragAndDropPermissionsCompat;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class NativeDropView implements PlatformView {
    @NonNull private final View dragView;
    @NonNull private final Activity activity;
    @NonNull private final MethodChannel channel;
    @NonNull private final Context context;
    private ArrayList<String> allowedDropDataTypes;
    private ArrayList<String> allowedDropFileExtensions;
    private ArrayList<String> allowedTypeIdentifiers;
    private Boolean receiveNonAllowedItems = true;

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
        updateAllowedData(creationParams);

        channel.setMethodCallHandler(channelMethodCallHandler());
    }

    // Some of the below code was taken from [Microsoft's Drag and Drop example](https://github.com/microsoft/surface-duo-sdk-samples/blob/main/DragAndDrop/src/main/java/com/microsoft/device/display/samples/draganddrop/fragment/DropTargetFragment.java)
    @NonNull
    private View.OnDragListener viewDragListener() {
        return (view, event) -> {
            int action = event.getAction();
            // Handles each of the expected events.
            switch (action) {
                case DragEvent.ACTION_DRAG_STARTED:

                    return hasItemsConformingToAllowedTypeIdentifiers(event) || shouldAllowAllFiles() ;

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

    private boolean shouldAllowAudio(){
        return this.allowedDropDataTypes.contains("audio");
    }
    private boolean shouldAllowImages(){
        return this.allowedDropDataTypes.contains("image");
    }
    private boolean shouldAllowVideos(){
        return this.allowedDropDataTypes.contains("video");
    }
    private boolean shouldAllowPdfs(){
        return this.allowedDropDataTypes.contains("pdf");
    }
    private boolean shouldAllowFiles(){
        return this.allowedDropDataTypes.contains("file");
    }
    private boolean shouldAllowText(){
        return this.allowedDropDataTypes.contains("text");
    }
    private boolean shouldAllowUrl(){
        return this.allowedDropDataTypes.contains("url");
    }
    private boolean isFileAllowed(Uri uri){
        String extension = getFileExtension(activity, uri).substring(1);
        return this.allowedDropFileExtensions.contains(extension);
    }

    private void handleDroppedData(DragEvent event){
        final ArrayList<Map<String, Object>> data = new ArrayList<>();

        View vw = (View) event.getLocalState();
        if (vw != null){
            sendDropData(data);
            return;
        }
        ClipData clipData = event.getClipData();
        int clipCount = clipData.getItemCount();

        new Thread(() -> {
            for (int i = 0; i <clipCount; i++){

                ClipData.Item item = clipData.getItemAt(i);
                String mimeType = "text/plain";
                DragAndDropPermissionsCompat dropPermissions = null;
                if (item.getUri() != null && ContentResolver.SCHEME_CONTENT.equals(item.getUri().getScheme())) {
                    // Accessing a "content" scheme Uri requires a permission grant.

                    dropPermissions = ActivityCompat
                            .requestDragAndDropPermissions(activity, event);
                }
                if (item.getUri() != null){

                    String extension = getFileExtension(activity, item.getUri()).substring(1);
                    mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.toLowerCase());
                    if (mimeType == null){
                        mimeType = "text/plain";
                    }
                }
                if(!receiveNonAllowedItems && !isAllowed(mimeType)){
                    continue;
                }
                 if (isImage(mimeType) && shouldAllowImages()){
                    Uri uri = item.getUri();
                    Map<String, Object> urlMap = handleFileDrop(event, uri, "image");
                    if (urlMap != null) {
                        data.add(urlMap);
                    }
                }
                else if (isVideo(mimeType) && shouldAllowVideos()){
                    Uri uri = item.getUri();
                    Map<String, Object> urlMap = handleFileDrop(event, uri, "video");
                    if (urlMap != null)
                        data.add(urlMap);
                }
                else if (isAudio(mimeType) && shouldAllowAudio()){

                    Uri uri = item.getUri();
                    Map<String, Object> urlMap = handleFileDrop(event, uri, "audio");
                    if (urlMap != null) {
                        data.add(urlMap);
                    }
                }
                else if (isPdf(mimeType) && shouldAllowPdfs()){
                    Uri uri = item.getUri();
                    Map<String, Object> urlMap = handleFileDrop(event, uri, "pdf");
                    if (urlMap != null)
                        data.add(urlMap);
                }
               else if (shouldAllowFiles() || ( item.getUri() != null && isFileAllowed(item.getUri()))) {
                     Uri uri = item.getUri();
                     if (uri != null) {
                         @Nullable Map<String, Object> urlMap = handleFileDrop(event, uri, "file");

                         if (urlMap != null)
                             data.add(urlMap);
                     }
                     else if (item.getText() != null){
                         String dragData = item.getText().toString();
                         final Map<String, Object> textMap = new HashMap<>();

                         if (Patterns.WEB_URL.matcher(item.getText()).matches()){
                             textMap.put("url", dragData);
                         }
                         else {
                             textMap.put("text", dragData);
                         }
                         data.add(textMap);

                     }
                 }
                else if (shouldAllowUrl() && item.getText() != null && Patterns.WEB_URL.matcher(item.getText()).matches()){
                    String dragData = item.getText().toString();
                    final Map<String, Object> textMap = new HashMap<>();
                    textMap.put("url", dragData);
                    data.add(textMap);
                }
                else if (shouldAllowText() && item.getText() != null){
                    String dragData = item.getText().toString();
                    final Map<String, Object> textMap = new HashMap<>();
                    textMap.put("text", dragData);
                    data.add(textMap);
                }
                if (dropPermissions != null){
                    dropPermissions.release();
                }
            }
            activity.runOnUiThread(() -> sendDropData(data));

        }).start();


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
            String path = getPathFromUri(activity, uri);
            urlMap.put(dataType, path);
            return urlMap;
        }
    }

    public void sendDropData(@Nullable Object data){

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
                    @SuppressWarnings("unchecked")
                    Map<String, Object> flutterArgs = (Map<String, Object>) call.arguments;

                    updateAllowedData(flutterArgs);
                    result.success(true);
                } else {
                    Log.w("[DART/NATIVE]", "NativeDropView.channelMethodCallHandler's updateParams: Could not load arguments. Arguments was not of type Map<String, Object>");
                    result.error("INVALID_TYPE", "Argument was an incorrect type. It should be a List of Map of String, Object.", null);
                }
            } else {
                result.notImplemented();
            }


        };
    }

    private void updateAllowedData(Map<String, Object> flutterArgs){
        this.allowedTypeIdentifiers = new ArrayList<>();
        Object dropDataTypes = flutterArgs.get("allowedDropDataTypes");
        if (dropDataTypes instanceof List){
            this.allowedDropDataTypes = (ArrayList<String>) dropDataTypes;
            for (String dataType: this.allowedDropDataTypes){
                switch (dataType) {
                    case "text":
                        this.allowedTypeIdentifiers.add("text/plain");
                        break;
                    case "url":
                        this.allowedTypeIdentifiers.add("text/uri");
                        break;
                    case "image":
                        this.allowedTypeIdentifiers.addAll(Arrays.asList("image/jpeg", "image/gif", "image/png"));
                        break;
                    case "video":
                        this.allowedTypeIdentifiers.addAll(Arrays.asList("video/mpeg", "video/mp4"));
                        break;
                    case "audio":
                        this.allowedTypeIdentifiers.addAll(Arrays.asList("audio/mpeg", "audio/mp4", "audio/x-wav", "audio/aac"));
                        break;
                    case "pdf":
                        this.allowedTypeIdentifiers.add("application/pdf");
                        break;
                }
            }
        }
        Object dropFileExts = flutterArgs.get("allowedDropFileExtensions");
        if (dropFileExts instanceof List){
            this.allowedDropFileExtensions = (ArrayList<String>) dropFileExts;
            for(String extension: this.allowedDropFileExtensions){
                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.toLowerCase());
                if (mimeType != null) {
                    this.allowedTypeIdentifiers.add(mimeType);
                }
            }
        }
        Object receiveNonAllowedItems = flutterArgs.get("receiveNonAllowedItems");
        if (receiveNonAllowedItems instanceof Boolean){
            this.receiveNonAllowedItems = (Boolean) receiveNonAllowedItems;
        }
    }
    private Boolean shouldAllowAllFiles(){
        return this.allowedDropDataTypes.contains("file");
    }
    private Boolean hasItemsConformingToAllowedTypeIdentifiers(DragEvent event){
        for (int i = 0; i< event.getClipDescription().getMimeTypeCount(); i++){
            String mimeType =  event.getClipDescription().getMimeType(i);
            if (this.allowedTypeIdentifiers.contains(mimeType)) {
                return true;
            }
        }
        return false;
    }
    private  Boolean isAllowed(String mimeType){
        return this.allowedTypeIdentifiers.contains(mimeType) || shouldAllowAllFiles();
    }
    @NonNull
    @Override
    public View getView() {
        return dragView;
    }

    @Override
    public void dispose() {}
}
