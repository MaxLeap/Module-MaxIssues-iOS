//
//  HCMsgInputView.h
//  MaxLeap
//

#import <UIKit/UIKit.h>
#import "HCMessage.h"
#import "ViewDelegates.h"

@interface HCMsgInputView : UIView

@property (nonatomic, weak) id<HCMsgInputViewDelegate> delegate;

- (HCMessage *)getMessage;

@end




