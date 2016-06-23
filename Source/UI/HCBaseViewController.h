//
//  MLBaseViewController.h
//  MaxLeap
//

#import <UIKit/UIKit.h>

@interface HCBaseViewController : UIViewController

- (void)startActivity;
- (void)stopActivity;

- (void)showError:(NSString *)errorMessage;
- (void)showMessage:(NSString *)messge onlyText:(BOOL)onlyText;
- (void)showMessage:(NSString *)messge onlyText:(BOOL)onlyText withDuration:(NSTimeInterval)duration; // 如果 duration 值小于 0，则不会自动移除

@end
