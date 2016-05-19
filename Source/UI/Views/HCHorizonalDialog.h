//
//  HCIssueReopenView.h
//  MaxLeap
//

#import <UIKit/UIKit.h>
#import "ViewDelegates.h"

@interface HCHorizonalDialog : UIView

@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSString *prompt;

- (instancetype)initWithLeftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle prompt:(NSString *)prompt;

- (void)setLeftAction:(dispatch_block_t)block;
- (void)setRightAction:(dispatch_block_t)block;

@end
