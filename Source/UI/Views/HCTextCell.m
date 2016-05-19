//
//  HCTextCell.m
//  MaxLeap
//

#import "HCTextCell.h"
#import "HCIssuesTheme.h"
#import "HCLocalizable.h"


@implementation HCTextCell

@synthesize message = _message;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        HCConversationViewAttributes *chatAttr = [HCIssuesTheme currentTheme].conversationViewAttr;
        
        self.bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bubbleView];
        
        UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 25)];
        timeLable.backgroundColor = [UIColor clearColor];
        timeLable.textColor = chatAttr.dateTextColor;
        timeLable.font = chatAttr.dateTextFont;
        [self.contentView addSubview:timeLable];
        self.timeLable = timeLable;
        
        UITextView *msgTextView = [[UITextView alloc] initWithFrame:CGRectMake(120, 10, 180, 25)];
        msgTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        msgTextView.scrollEnabled = NO;
        msgTextView.editable = NO;
        msgTextView.font = chatAttr.messageTextFont;
        msgTextView.backgroundColor = [UIColor clearColor];
        msgTextView.delegate = self;
        [self.contentView addSubview:msgTextView];
        self.msgTextView = msgTextView;
        
        if ([msgTextView respondsToSelector:@selector(setLinkTextAttributes:)]) {
            UIColor *linkColor = [UIColor colorWithRed:0.396f green:0.722f blue:1.000f alpha:1.00f];
            msgTextView.linkTextAttributes = @{NSForegroundColorAttributeName:linkColor,
                                               NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
        }
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.msgTextView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.message = nil;
    self.msgTextView.text = nil;
    self.timeLable.text = nil;
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    if (self.message.faqReferrence && [self.delegate respondsToSelector:@selector(didTapFAQ:)]) {
        
        NSString *link = [NSString stringWithFormat:@"lasfaq://%@/%@", [self.message.faqReferrence faqId], [self.message.faqReferrence langcode]];
        NSURL *URL = [NSURL URLWithString:link];
        [self.delegate didTapFAQ:URL];
    }
}

- (void)configWithMessage:(HCMessage *)message {
    
    self.message = message;
    
    self.timeLable.text = message.formattedCreatedAt;
    if (message.faqReferrence) {
        NSString *text = HCLocalizedString(@"Please refer to FAQ: ", nil);
        NSString *title = message.faqReferrence.title;
        NSString *content = [text stringByAppendingString:title];
        NSMutableAttributedString *content_attr = [[NSMutableAttributedString alloc] initWithString:content];
        [content_attr addAttribute:NSFontAttributeName value:self.msgTextView.font range:NSMakeRange(0, content.length)];
        [content_attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:74/255.f green:74/255.f blue:74/255.f alpha:1] range:[content rangeOfString:text]];
        
        if ([self.msgTextView respondsToSelector:@selector(setLinkTextAttributes:)]) {
            NSString *link = [NSString stringWithFormat:@"lasfaq://%@/%@", message.faqReferrence.faqId, message.faqReferrence.langcode];
            [content_attr addAttribute:NSLinkAttributeName value:link range:[content rangeOfString:title]];
        } else {
            [content_attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.396f green:0.722f blue:1.000f alpha:1.00f] range:[content rangeOfString:title]];
            [content_attr addAttribute:NSUnderlineStyleAttributeName value:@(-1) range:[content rangeOfString:title]];
        }
        
        self.msgTextView.attributedText = content_attr;
    } else {
        self.msgTextView.text = message.content;
    }
}

+ (CGFloat)heightOfMessage:(HCMessage *)message {
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.dataDetectorTypes = UIDataDetectorTypeAll;
    textView.textAlignment = NSTextAlignmentJustified;
    textView.scrollEnabled = NO;
    textView.editable = NO;
    textView.font = [HCIssuesTheme currentTheme].conversationViewAttr.messageTextFont;
    textView.text = message.displayContent;
    CGSize msgSize = [textView sizeThatFits:CGSizeMake(190, CGFLOAT_MAX)];
    return msgSize.height + 10*2 + 10*2;
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.scheme isEqualToString:[HCFaqReferrence schema]] && [self.delegate respondsToSelector:@selector(didTapFAQ:)]) {
        [self.delegate didTapFAQ:URL];
        return NO;
    }
    return YES;
}

@end
