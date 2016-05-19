//
//  HCNewIssueView.h
//  MaxLeap
//

#import <UIKit/UIKit.h>
#import "HCIssue.h"
#import "ViewDelegates.h"

@interface HCNewIssueView : UIView

@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

- (BOOL)tryToTriggerSendAction;
- (void)setDoneAction:(void(^)(NSString *title, NSString *name, NSString *email, UIImage *image))block;

- (BOOL)isEditing;
- (void)beginEditing;

@property (nonatomic, weak) id<HCViewDelegate> delegate;
- (void)didPickImage:(UIImage *)image;

@end
