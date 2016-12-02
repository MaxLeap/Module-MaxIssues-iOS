//
//  UIImage+BlurImage.h
//  MusicDownloader
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>

void maxleap_load_UIImage_HCIssueColor();

@interface UIImage (HCIssueColor)

+ (UIImage *)hc_imageWithColor:(UIColor *)color;
+ (UIImage *)hc_imageWithColor:(UIColor *)color withSize:(CGSize)size;
+ (UIImage *)hc_imageWithColor:(UIColor *)color withSize:(CGSize)size cornerRadius:(CGFloat)radius;

@end