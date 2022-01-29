package com.rabinapps.native_drag_n_drop;

import androidx.annotation.Nullable;

import java.util.Map;
import java.util.Set;

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
}
