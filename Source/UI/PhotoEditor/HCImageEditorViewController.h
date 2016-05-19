//
//  HCImageEditorViewController.h
//  MaxLeap
//

#import <UIKit/UIKit.h>

@interface HCImageEditorViewController : UIViewController

@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) NSString *doneButtonTitle;

- (void)setDoneAction:(void (^)(UIImage *))doneAction;

@end
