#import "ZaloSharePlugin.h"
#if __has_include(<zalo_share/zalo_share-Swift.h>)
#import <zalo_share/zalo_share-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "zalo_share-Swift.h"
#endif

@implementation ZaloSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftZaloSharePlugin registerWithRegistrar:registrar];
}
@end
