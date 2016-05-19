//
//  HCTextCell.h
//  MaxLeap
//

#import <UIKit/UIKit.h>
#import "HCMsgCell.h"
#import "MLIssuesImageHelper.h"

@protocol HCTextCellDelegate <NSObject>

@optional

- (void)didTapFAQ:(NSURL *)faq;
- (void)didTapURL:(NSURL *)URL;

@end

@interface HCTextCell : UITableViewCell <HCMsgCell, UITextViewDelegate>

@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UITextView *msgTextView;

@property (nonatomic, weak) id<HCTextCellDelegate> delegate;

- (void)configWithMessage:(HCMessage *)message;

@end
