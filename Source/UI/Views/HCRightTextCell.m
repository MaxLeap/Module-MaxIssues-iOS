//
//  MLMineMessageCell.m
//  MaxLeap
//

#import "HCRightTextCell.h"
#import "MLIssuesImageHelper.h"
#import "HCIssuesTheme.h"


@implementation HCRightTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bubbleView.image = HCStretchableImage(@"ml_icon_textfield_dialog_blue", 27, 8);
        self.timeLable.textAlignment = NSTextAlignmentRight;
        self.msgTextView.textColor = [HCIssuesTheme currentTheme].conversationViewAttr.messageTextColorRight;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self errorIndicator].highlighted = highlighted;
}

- (UIImageView *)errorIndicator {
    return (UIImageView *)[self.contentView viewWithTag:777];
}

- (void)configWithMessage:(HCMessage *)message {
    [super configWithMessage:message];
    
    UIImageView *errorIndicator = [self errorIndicator];
    if (self.message.dataStatus == HCMessageStatusUploadFailed && !errorIndicator)
    {
        errorIndicator = [[UIImageView alloc] initWithImage:HCImageNamed(@"btn_picunsend_nomal") highlightedImage:HCImageNamed(@"btn_picunsend_selected")];
        [errorIndicator sizeToFit];
        errorIndicator.tag = 777;
        errorIndicator.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:errorIndicator];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.message = nil;
    [[self errorIndicator] removeFromSuperview];
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
    bubleFrame.origin.x = self.contentView.frame.size.width - bubleFrame.size.width -9;
    self.bubbleView.frame = bubleFrame;
    
    msgTextViewFrame.origin.x = bubleFrame.origin.x + 10;
    msgTextViewFrame.origin.y = bubleFrame.origin.y + 5;
    self.msgTextView.frame = msgTextViewFrame;
    
    self.timeLable.frame = CGRectMake(10, self.msgTextView.frame.origin.y, bubleFrame.origin.x - 20, 25);
    
    UIImageView *errorIndicator = [self errorIndicator];
    errorIndicator.frame = CGRectMake( CGRectGetMaxX(self.bubbleView.frame) -20, self.bubbleView.frame.origin.y -5, errorIndicator.frame.size.width, errorIndicator.frame.size.height);
}

@end
