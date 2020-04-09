#import "WidgetSharePlugin.h"
#if __has_include(<widget_share/widget_share-Swift.h>)
#import <widget_share/widget_share-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "widget_share-Swift.h"
#endif

@implementation WidgetSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWidgetSharePlugin registerWithRegistrar:registrar];
}
@end
