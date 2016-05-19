//
//  HCLocalizable.h
//  MaxLeap
//

#ifndef MaxLeap_HCLocalizable_h
#define MaxLeap_HCLocalizable_h

#import <Foundation/Foundation.h>
#import "MLLogging.h"

static inline NSBundle * issues_localizable_bundle() {
    static NSBundle *_bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MLIssuesLocalizable" ofType:@"bundle"];
        _bundle = [NSBundle bundleWithPath:bundlePath];
        if (!_bundle) {
            MLLogInfoF(@"MLIssuesLocalizable.bundle not found, please include it in your project.");
        }
    });
    return _bundle;
}
#define HCLocalizedString(key, comment) \
        NSLocalizedStringFromTableInBundle(key, @"localizable", issues_localizable_bundle(), comment)

#endif
