//
//  MLOthersMessageCell.m
//  MaxLeap
//

#import "HCLeftTextCell.h"
#import "MLIssuesImageHelper.h"
#import "HCIssuesTheme.h"

@implementation HCLeftTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bubbleView.image = HCStretchableImage(@"ml_icon_textfield_dialog_gray", 27, 8);
        self.timeLable.textAlignment = NSTextAlignmentLeft;
        self.msgTextView.textColor = [HCIssuesTheme currentTheme].conversationViewAttr.messageTextColorLeft;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize msgSize = [self.msgTextView sizeThatFits:CGSizeMake(190, 1000)];
    CGRect msgTextViewFrame = self.msgTextView.frame;
    msgTextViewFrame.size.height = MAX(25, msgSize.height);
    msgTextViewFrame.size.width = msgSize.width;
    
    CGRect bubleFrame = CGRectMake(0, 10, 0, 0);
    bubleFrame.size.width = msgTextViewFrame.size.width + 5 + 20;
    bubleFrame.size.height = msgTextViewFrame.size.height + 10;
    bubleFrame.origin.x = 10;
    self.bubbleView.frame = bubleFrame;
    
    msgTextViewFrame.origin.x = bubleFrame.origin.x + 15;
    msgTextViewFrame.origin.y = bubleFrame.origin.y + 5;
    self.msgTextView.frame = msgTextViewFrame;
    
    CGRect timeLableFrame = self.timeLable.frame;
    timeLableFrame.origin.x = bubleFrame.origin.x + bubleFrame.size.width + 9;
    timeLableFrame.origin.y = self.msgTextView.frame.origin.y;
    timeLableFrame.size.width = self.contentView.frame.size.width - timeLableFrame.origin.x -10;
    timeLableFrame.size.height = 25;
    self.timeLable.frame = timeLableFrame;
}

@end

