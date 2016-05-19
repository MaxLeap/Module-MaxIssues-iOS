//
//  HCImagePickerController.h
//  MaxLeap
//

#import <UIKit/UIKit.h>

@interface HCImagePickerController : UIImagePickerController

@property (nonatomic, strong) NSString *doneButtonTitle;

- (void)setDoneAction:(void (^)(UIImage *))doneAction;

@end
