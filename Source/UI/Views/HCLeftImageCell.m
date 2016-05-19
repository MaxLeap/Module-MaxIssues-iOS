//
//  HCLeftImageCell.m
//  MaxLeap
//

#import "HCLeftImageCell.h"
#import "MLIssuesImageHelper.h"

@implementation HCLeftImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.bubbleView.image = HCStretchableImage(@"ml_icon_textfield_dialog_gray", 27, 8);
    }
    return self;
}

- (void)configWithMessage:(HCMessage *)message reloadBlock:(dispatch_block_t)block {
    
    [super configWithMessage:message reloadBlock:block];
    
    if (message.dataStatus == HCMessageStatusDownloadFailed) {
        self.imgView.image = HCImageNamed(@"errorBmp.gif");
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.message setDownloadProgressBlock:nil];
    [self.message setUploadProgressBlock:nil];
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
    bubleFrame.origin.x = 10;
    self.bubbleView.frame = bubleFrame;
    
    imgFrame.origin.x = bubleFrame.origin.x + 15;
    imgFrame.origin.y = bubleFrame.origin.y + 10;
    self.imgView.frame = imgFrame;
    
    CGRect timeLableFrame = self.timeLable.frame;
    timeLableFrame.origin.x = bubleFrame.origin.x + bubleFrame.size.width + 10;
    timeLableFrame.origin.y = self.imgView.frame.origin.y;
    timeLableFrame.size.width = self.contentView.frame.size.width - timeLableFrame.origin.x -10;
    timeLableFrame.size.height = 25;
    self.timeLable.frame = timeLableFrame;
}

@end
