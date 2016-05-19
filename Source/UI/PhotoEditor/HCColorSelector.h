//
//  HCColorSelector.h
//  MaxLeap
//

#import <UIKit/UIKit.h>

@interface HCColorSelector : UIView

@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) void(^colorDidChangeBlock)(UIColor *color);

+ (UIColor *)color;

@end
