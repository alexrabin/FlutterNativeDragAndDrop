package com.rabinapps.native_drag_n_drop;

import androidx.annotation.Nullable;

import java.util.Map;
import java.util.Set;

import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;
import android.webkit.MimeTypeMap;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.UUID;

public class Utils {
    /// Checks if a given object is of type Map<String, Object?>
    static boolean isMap(@Nullable Object object) {
        if (object instanceof Map) {
            final Set<?> keys = ((Map<?, ?>) object).keySet();

            for (final Object key : keys) {
                if (!(key instanceof String)) {
                    return false;
                }
            }

            return true;
        }

        return false;
    }

    //https://github.com/flutter/plugins/blob/main/packages/image_picker/image_picker/android/src/main/java/io/flutter/plugins/imagepicker/FileUtils.java
    static String getPathFromUri(final Context context, final Uri uri) {
        File file = null;
        InputStream inputStream = null;
        OutputStream outputStream = null;
        boolean success = false;
        try {
            String extension = getFileExtension(context, uri);
            inputStream = context.getContentResolver().openInputStream(uri);
            file = File.createTempFile("native_drag_n_drop", extension, context.getCacheDir());
            file.deleteOnExit();
            outputStream = new FileOutputStream(file);
            if (inputStream != null) {
                copy(inputStream, outputStream);
                success = true;
            }
        } catch (IOException ignored) {
        } finally {
            try {
                if (inputStream != null) inputStream.close();
            } catch (IOException ignored) {
            }
            try {
                if (outputStream != null) outputStream.close();
            } catch (IOException ignored) {
                // If closing the output stream fails, we cannot be sure that the
                // target file was written in full. Flushing the stream merely moves
                // the bytes into the OS, not necessarily to the file.
                success = false;
            }
        }
        return success ? file.getPath() : null;
    }

    /** @return extension of image with dot, or default .jpg if it none. */
    private static String getFileExtension(Context context, Uri uriFile) {
        String extension = null;

        try {
            if (uriFile.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
                final MimeTypeMap mime = MimeTypeMap.getSingleton();
                extension = mime.getExtensionFromMimeType(context.getContentResolver().getType(uriFile));
            } else {
                extension =
                        MimeTypeMap.getFileExtensionFromUrl(
                                Uri.fromFile(new File(uriFile.getPath())).toString());
            }
        } catch (Exception e) {
            extension = null;
        }

        if (extension == null || extension.isEmpty()) {
            //default extension for matches the previous behavior of the plugin
            extension = "jpg";
        }

        return "." + extension;
    }

    private static void copy(InputStream in, OutputStream out) throws IOException {
        final byte[] buffer = new byte[4 * 1024];
        int bytesRead;
        while ((bytesRead = in.read(buffer)) != -1) {
            out.write(buffer, 0, bytesRead);
        }
        out.flush();
    }
}
