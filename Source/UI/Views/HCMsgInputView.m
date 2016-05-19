//
//  HCMsgInputView.m
//  MaxLeap
//

#import "HCMsgInputView.h"
#import "MLIssuesImageHelper.h"
#import "HCIssueManager.h"
#import "HCLocalizable.h"

#define TAG_MSG 100

#define LINE_COLOR [UIColor colorWithRed:0.898f green:0.898f blue:0.898f alpha:1.00f]
#define INPUT_VIEW_MIN_HEIGHT 28.f
#define INPUT_VIEW_MAX_HEIGHT 100.f


@interface HCMsgInputView () <UITextViewDelegate, UITextFieldDelegate>
@end

@implementation HCMsgInputView

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = 50;
    frame.size.width = MAX(320, frame.size.width);
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        // cameral button
        UIButton *cameralButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cameralButton setImage:HCImageNamed(@"btn_inputbox_insertpic_nomal") forState:UIControlStateNormal];
        [cameralButton setImage:HCImageNamed(@"btn_inputbox_insertpic_selected") forState:UIControlStateHighlighted];
        cameralButton.tag = ACTION_SEND_PHOTO;
        [cameralButton sizeToFit];
        cameralButton.frame = CGRectMake(10,
                                         round((frame.size.height-cameralButton.bounds.size.height)/2),
                                         cameralButton.bounds.size.width,
                                         cameralButton.bounds.size.height
                                         );
        cameralButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [cameralButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cameralButton];
        
        // send button
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.tag = ACTION_SEND_MSG;
        [sendButton setTitle:HCLocalizedString(@"Send", nil) forState:UIControlStateNormal];
        sendButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        [sendButton setTitleColor:[UIColor colorWithRed:100/255.f green:167/255.f blue:235/255.f alpha:1.f] forState:UIControlStateNormal];
        [sendButton setTitleColor:[UIColor colorWithRed:100/255.f green:167/255.f blue:235/255.f alpha:0.7] forState:UIControlStateHighlighted];
        [sendButton sizeToFit];
        sendButton.enabled = NO;
        sendButton.frame = CGRectMake(frame.size.width -sendButton.bounds.size.width - 10,
                                         round((frame.size.height-sendButton.bounds.size.height)/2),
                                         sendButton.bounds.size.width,
                                         sendButton.bounds.size.height
                                         );
        sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [sendButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        
        // input view
        CGRect inputViewFrame = CGRectZero;
        inputViewFrame.origin.x = cameralButton.frame.origin.x + cameralButton.frame.size.width + 14;
        inputViewFrame.origin.y = 11;
        inputViewFrame.size.width = sendButton.frame.origin.x - inputViewFrame.origin.x -14;
        inputViewFrame.size.height = INPUT_VIEW_MIN_HEIGHT;
        UITextView *inputTextView = [[UITextView alloc] initWithFrame:inputViewFrame];
        inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        inputTextView.tag = TAG_MSG;
        inputTextView.backgroundColor = [UIColor whiteColor];
        inputTextView.layer.borderColor = [UIColor colorWithRed:0.894f green:0.894f blue:0.894f alpha:1.00f].CGColor;
        inputTextView.layer.borderWidth = 0.5;
        inputTextView.layer.cornerRadius = 3.f;
        inputTextView.delegate = self;
        [self addSubview:inputTextView];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        topLine.backgroundColor = LINE_COLOR;
        [self addSubview:topLine];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)buttonAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(performAction:)]) {
        [self.delegate performAction:(int)[sender tag]];
    }
    
    UITextView *inputView = (UITextView *)[self viewWithTag:TAG_MSG];
    if ([sender tag] == ACTION_SEND_MSG) {
        inputView.text = nil;
        [self textViewDidChange:inputView];
    }
}

- (HCMessage *)getMessage {
    UITextView *msgInputView = (UITextView *)[self viewWithTag:TAG_MSG];
    if (msgInputView.text.length) {
        NSString *issueId = [HCIssueManager sharedManager].currentIssue.objectId;
        return [HCMessage messageWithContent:msgInputView.text issueId:issueId];
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    CGFloat height = INPUT_VIEW_MIN_HEIGHT;
    if (textView.text.length > 0) {
        CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, INPUT_VIEW_MAX_HEIGHT)];
        height = MIN(INPUT_VIEW_MAX_HEIGHT, size.height);
        height = MAX(height, INPUT_VIEW_MIN_HEIGHT);
    }
    CGRect bounds = textView.bounds;
    if (bounds.size.height != height) {
        CGFloat delta = height - bounds.size.height;
        CGRect frame = self.frame;
        frame.size.height += delta;
        frame.origin.y -= delta;
        
        if ([self.delegate respondsToSelector:@selector(msgInputViewWillChangeHeight:duration:)]) {
            [self.delegate msgInputViewWillChangeHeight:frame.size.height duration:0.2];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = frame;
        }];
    }
    
    UIButton *sendButton = (UIButton *)[self viewWithTag:ACTION_SEND_MSG];
    sendButton.enabled = (textView.text.length > 0);
}

@end
