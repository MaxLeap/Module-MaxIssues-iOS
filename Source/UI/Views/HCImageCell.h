//
//  UIImageCell.h
//  MaxLeap
//

#import <UIKit/UIKit.h>
#import "HCMsgCell.h"
#import "MLIssuesImageHelper.h"

@protocol HCImageCellDelegate <NSObject>

@optional

- (void)didTapImageView:(UIImageView *)imageView;

@end

@interface HCImageCell : UITableViewCell <HCMsgCell>

@property (nonatomic, strong) UIImage *loadingImage;

@property (nonatomic, strong) UIImageView *bubbleView;
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic) BOOL imageLoaded;

@property (nonatomic, weak) id<HCImageCellDelegate> delegate;

- (void)configWithMessage:(HCMessage *)message reloadBlock:(dispatch_block_t)block;

@end
