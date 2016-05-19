//
//  HCImageDisplayViewController.h
//  MaxLeap
//

#import <UIKit/UIKit.h>

@interface HCImageInfo : NSObject

@property (strong, nonatomic) UIImage *image; // If nil, be sure to set either imageURL or canonicalImageURL.

@property (strong, nonatomic) UIImage *placeholderImage; // Use this if all you have is a thumbnail and an imageURL.
@property (copy, nonatomic) NSURL *imageURL;
@property (copy, nonatomic) NSURL *canonicalImageURL; // since `imageURL` might be a filesystem URL from the local cache.

@property (assign, nonatomic) CGRect referenceRect;
@property (strong, nonatomic) UIView *referenceView;
@property (assign, nonatomic) UIViewContentMode referenceContentMode;
@property (assign, nonatomic) CGFloat referenceCornerRadius;

@property (copy, nonatomic) NSMutableDictionary *userInfo;

- (CGPoint)referenceRectCenter;

@end



@interface HCImageViewController : UIViewController

+ (void)displayWithImageInfo:(HCImageInfo *)imageInfo fromViewController:(UIViewController *)viewController;

@end


