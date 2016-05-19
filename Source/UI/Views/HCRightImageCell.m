//
//  HCRightImageCell.m
//  MaxLeap
//

#import "HCRightImageCell.h"
#import "MLIssuesImageHelper.h"

#define Progress_Tag 888
#define Error_Indicator_Tag 777

@implementation HCRightImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.timeLable.textAlignment = NSTextAlignmentRight;
        self.bubbleView.image = HCStretchableImage(@"ml_icon_textfield_dialog_blue", 27, 8);
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self errorIndicator].highlighted = highlighted;
}

- (void)configWithMessage:(HCMessage *)message reloadBlock:(dispatch_block_t)block {
    
    [super configWithMessage:message reloadBlock:block];
    
    if (message.dataStatus == HCMessageStatusUploadFailed)
    {
        [self addErrorIndicator];
    }
    else if (message.dataStatus == HCMessageStatusShouldUpload || message.dataStatus == HCMessageStatusIsUploading)
    {
        [self addActivityIndicator];
    }
}

- (void)addActivityIndicator {
    UIView *view = [self.contentView viewWithTag:Progress_Tag];
    if (!view ) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        view.tag = Progress_Tag;
        view.layer.cornerRadius = 5.f;
        [self.contentView addSubview:view];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.backgroundColor = [UIColor clearColor];
        indicator.hidesWhenStopped = YES;
        indicator.center = CGPointMake(CGRectGetMidX(view.frame), CGRectGetMidY(view.frame));
        [view addSubview:indicator];
        
        [indicator startAnimating];
    }
}

- (void)removeActivityIndicator {
    [[self.contentView viewWithTag:Progress_Tag] removeFromSuperview];
}

- (UIImageView *)errorIndicator {
    return (UIImageView *)[self.contentView viewWithTag:Error_Indicator_Tag];
}

- (void)addErrorIndicator {
    
    UIImageView *errorIndicator = [self errorIndicator];
    
    if (!errorIndicator) {
        errorIndicator = [[UIImageView alloc] initWithImage:HCImageNamed(@"btn_picunsend_nomal") highlightedImage:HCImageNamed(@"btn_picunsend_selected")];
        [errorIndicator sizeToFit];
        errorIndicator.tag = Error_Indicator_Tag;
        errorIndicator.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:errorIndicator];
    }
}

- (void)removeErrorIndicator {
    [[self errorIndicator] removeFromSuperview];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.message setDownloadProgressBlock:nil];
    [self.message setUploadProgressBlock:nil];
    [self removeActivityIndicator];
    [self removeErrorIndicator];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize msgSize = self.imgView.image.size;
    msgSize.width = MIN(msgSize.width, 100);
    msgSize.height = msgSize.height * msgSize.width/self.imgView.image.size.width;
    
    CGRect imgFrame = self.imgView.frame;
    imgFrame.size.height = MAX(25, msgSize.height);
    imgFrame.size.width = msgSize.width;
    
    CGRect bubleFrame = CGRectMake(0, 10, 0, 0);
    bubleFrame.size.width = imgFrame.size.width + 10 + 18;
    bubleFrame.size.height = imgFrame.size.height + 20;
    bubleFrame.origin.x = self.contentView.frame.size.width - bubleFrame.size.width -10;
    self.bubbleView.frame = bubleFrame;
    
    imgFrame.origin.x = bubleFrame.origin.x + 10;
    imgFrame.origin.y = bubleFrame.origin.y + 10;
    self.imgView.frame = imgFrame;
    
    UIView *indicatorBg = [self.contentView viewWithTag:Progress_Tag];
    if (indicatorBg && self.message.dataStatus != HCMessageStatusIsUploading) {
        [indicatorBg removeFromSuperview];
    }
    if (indicatorBg) {
        indicatorBg.center = self.imgView.center;
    }
    
    self.timeLable.frame = CGRectMake(10, self.imgView.frame.origin.y, bubleFrame.origin.x - 20, 25);
    
    UIImageView *errorIndicator = [self errorIndicator];
    if (errorIndicator) {
        errorIndicator.frame = CGRectMake(CGRectGetMaxX(self.bubbleView.frame) -20, self.bubbleView.frame.origin.y -5, errorIndicator.frame.size.width, errorIndicator.frame.size.height);
    }
}

@end
