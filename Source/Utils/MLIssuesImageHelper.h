//
//  MLHCImageHelper.h
//  MaxLeap
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HCImageNamed(name) [MLIssuesImageHelper imageNamed:name]

#define HCImageRenderingOriginal(name) \
        [[UIImage new] respondsToSelector:@selector(imageWithRenderingMode:)] ? [[MLIssuesImageHelper imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : [MLIssuesImageHelper imageNamed:name]

#define HCImageRenderingTemplate(name) \
        [[UIImage new] respondsToSelector:@selector(imageWithRenderingMode:)] ? [[MLIssuesImageHelper imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : [MLIssuesImageHelper imageNamed:name]

#define HCStretchableImage(name, width, height) [HCImageNamed(name) stretchableImageWithLeftCapWidth:width topCapHeight:height]

@interface MLIssuesImageHelper : NSObject

+ (void)registerBundleWithPath:(NSString *)path; // 可以是绝对路径，也可以是相对于 mainBundle 的路径

+ (UIImage *)imageNamed:(NSString *)name;

@end
