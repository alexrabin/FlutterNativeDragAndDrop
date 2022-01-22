#import "NativeDragNDropPlugin.h"
#if __has_include(<native_drag_n_drop/native_drag_n_drop-Swift.h>)
#import <native_drag_n_drop/native_drag_n_drop-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_drag_n_drop-Swift.h"
#endif

@implementation NativeDragNDropPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeDragNDropPlugin registerWithRegistrar:registrar];
}
@end
