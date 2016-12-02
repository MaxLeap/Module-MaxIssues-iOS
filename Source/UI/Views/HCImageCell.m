//
//  UIImageCell.m
//  MaxLeap
//

#import "HCImageCell.h"
#import "MLDevice.h"

@implementation HCImageCell

@synthesize message = _message;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *bubleView = [[UIImageView alloc] initWithImage:HCStretchableImage(@"ml_icon_textfield_dialog_blue", 27, 8)];
        [self.contentView addSubview:bubleView];
        self.bubbleView = bubleView;
        
        UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 25)];
        timeLable.textColor = [UIColor colorWithRed:151/255.f green:151/255.f blue:151/255.f alpha:1.f];
        timeLable.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:timeLable];
        self.timeLable = timeLable;
        
        BOOL ios7OrLater = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
        if (ios7OrLater) {
            timeLable.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:9];
        } else {
            timeLable.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 10, 180, 25)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.layer.cornerRadius = 3.f;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        self.loadingImage = HCImageNamed(@"image_loading.gif");
        imageView.image = self.loadingImage;
        [self.contentView addSubview:imageView];
        self.imgView = imageView;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
        [imageView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)handleImageTap:(UITapGestureRecognizer *)tapGesture {
    if (self.imageLoaded && [self.delegate respondsToSelector:@selector(didTapImageView:)]) {
        [self.delegate didTapImageView:self.imgView];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imgView.image = self.loadingImage;
    self.imageLoaded = NO;
}

- (void)configWithMessage:(HCMessage *)message reloadBlock:(dispatch_block_t)block {
    
    self.message = message;
    
    self.timeLable.text = [message formattedCreatedAt];
    
    if (message.dataStatus != HCMessageStatusDownloadFailed) {
        
        [message getImageWithCompletion:^(UIImage *image, NSError *error) {
            
            if ( NO ==[self.message isEqual:message])
                return ;
            
            BOOL shouldReload = NO;
            if (error) {
                self.imgView.image = HCImageNamed(@"errorBmp.gif");
                shouldReload = YES;
            } else {
                if (false == CGSizeEqualToSize(self.imgView.image.size, image.size)) {
                    shouldReload = YES;
                }
                self.imgView.image = image;
                self.imageLoaded = YES;
            }
            [self setNeedsLayout];
            if (shouldReload && block) {
                block();
            }
        }];
    }
}

+ (CGFloat)heightOfMessage:(HCMessage *)message {
    
    UIImage *image = [message imageCachedInMemory];
    if (!image) {
        image = HCImageNamed(@"image_loading.gif");
    }
    
    CGSize msgSize = image.size;
    msgSize.width = MIN(100, msgSize.width);
    msgSize.height = round(msgSize.height * msgSize.width/image.size.width);
    
    return msgSize.height + 10*2 + 10*2;
}

@end
