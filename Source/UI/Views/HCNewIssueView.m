//
//  HCNewIssueView.m
//  MaxLeap
//

#import "HCNewIssueView.h"
#import "HCTextView.h"
#import "MLIssuesImageHelper.h"
#import "HCLocalizable.h"

#define TAG_NEW_ISSUE_TITLE 200
#define TAG_NEW_ISSUE_USER_NAME 201
#define TAG_NEW_ISSUE_USER_EMAIL 202

#define TAG_Cameral_Button 300
#define TAG_ImageView 301
#define TAG_Image_Remove_Button 302

#define LINE_COLOR [UIColor colorWithRed:0.898f green:0.898f blue:0.898f alpha:1.00f]

#define IMAGE_HEIGHT 60
#define TextField_Height 41

#define kTitleKey @"com.las.helpcenter.issue.lastinputtitle"
#define kIssueUserNameKey @"com.las.helpcenter.issue.username"
#define kIssueUserEmailKey @"com.las.helpcenter.issue.email"

@interface HCNewIssueView ()
<UITextFieldDelegate,
UITextViewDelegate>

@property (nonatomic, strong) void(^actionBlock)(NSString *title, NSString *name, NSString *email, UIImage *image);

@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *emailField;

@end

@implementation HCNewIssueView

- (instancetype)initWithFrame:(CGRect)frame {
    
    frame.size.height = MAX(88, frame.size.height);
    
    if (self = [super initWithFrame:frame]) {
        
        self.interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        CGRect titleViewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height - TextField_Height -10);
        HCTextView *titleTextView = [[HCTextView alloc] initWithFrame:titleViewFrame];
        titleTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        titleTextView.tag = TAG_NEW_ISSUE_TITLE;
        titleTextView.backgroundColor = [UIColor whiteColor];
        titleTextView.font = [UIFont systemFontOfSize:16];
        titleTextView.placehoder = HCLocalizedString(@"What's on your mind?", nil);
        titleTextView.delegate = self;
        [self addSubview:titleTextView];
        self.titleTextView = titleTextView;
        
        CGRect nameFieldFrame = CGRectMake(15, frame.size.height - TextField_Height, frame.size.width/2 - 15 -5, TextField_Height);
        UITextField *nameField = [[UITextField alloc] initWithFrame:nameFieldFrame];
        nameField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        nameField.borderStyle = UITextBorderStyleNone;
        nameField.backgroundColor = [UIColor whiteColor];
        nameField.tag = TAG_NEW_ISSUE_USER_NAME;
        nameField.placeholder = HCLocalizedString(@"Name", nil);
        nameField.returnKeyType = UIReturnKeyNext;
        nameField.rightViewMode = UITextFieldViewModeAlways;
        nameField.contentVerticalAlignment = UIViewContentModeCenter;
        nameField.delegate = self;
        [self addSubview:nameField];
        self.nameField = nameField;
        
        CGRect emailFrame = nameFieldFrame;
        emailFrame.origin.x += frame.size.width/2;
        UITextField *emailField = [[UITextField alloc] initWithFrame:emailFrame];
        emailField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        emailField.borderStyle = UITextBorderStyleNone;
        emailField.backgroundColor = [UIColor whiteColor];
        emailField.tag = TAG_NEW_ISSUE_USER_EMAIL;
        emailField.placeholder = HCLocalizedString(@"Email (Optional)", nil);
        emailField.returnKeyType = UIReturnKeySend;
        emailField.keyboardType = UIKeyboardTypeEmailAddress;
        emailField.rightViewMode = UITextFieldViewModeAlways;
        emailField.contentVerticalAlignment = UIViewContentModeCenter;
        emailField.delegate = self;
        [self addSubview:emailField];
        self.emailField = emailField;
        
        UIButton *cameralBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cameralBtn setImage:HCImageNamed(@"btn_screenshot_nomal") forState:UIControlStateNormal];
        [cameralBtn setImage:HCImageNamed(@"btn_screenshot_selected") forState:UIControlStateHighlighted];
        [cameralBtn sizeToFit];
        cameralBtn.tag = TAG_Cameral_Button;
        cameralBtn.frame = CGRectMake(frame.size.width - cameralBtn.bounds.size.width - 20, emailFrame.origin.y - cameralBtn.bounds.size.height - 10, cameralBtn.bounds.size.width, cameralBtn.bounds.size.height);
        cameralBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [cameralBtn addTarget:self action:@selector(pickPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cameralBtn];
        
        CGRect topLineFrame = CGRectMake(0, nameFieldFrame.origin.y, frame.size.width, 1);
        UIView *topLine = [[UIView alloc] initWithFrame:topLineFrame];
        topLine.backgroundColor = LINE_COLOR;
        topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:topLine];
        
        CGRect middleLineFrame = CGRectMake(frame.size.width/2, nameFieldFrame.origin.y, 1, TextField_Height);
        UIView *middleVerticalLine = [[UIView alloc] initWithFrame:middleLineFrame];
        middleVerticalLine.backgroundColor = LINE_COLOR;
        middleVerticalLine.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:middleVerticalLine];
        
        NSString *title = [[NSUserDefaults standardUserDefaults] stringForKey:kTitleKey];
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kIssueUserNameKey];
        NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:kIssueUserEmailKey];
        titleTextView.text = title;
        nameField.text = username;
        emailField.text = email;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nameField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:emailField];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isEditing {
    return self.titleTextView.isFirstResponder || self.nameField.isEditing || self.emailField.isEditing;
}

- (void)beginEditing {
    UITextView *titleTextView = (UITextView *)[self viewWithTag:TAG_NEW_ISSUE_TITLE];
    [titleTextView becomeFirstResponder];
}

#pragma mark -

- (void)pickPhoto:(id)sender {
    if ([self.delegate respondsToSelector:@selector(performAction:)]) {
        [self endEditing:NO];
        [self.delegate performAction:ACTION_ATTACH_PHOTO];
    }
}

- (void)didPickImage:(UIImage *)image {
    UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_ImageView];
    if (!imageView && image) {
        UIView *emailField = [self viewWithTag:TAG_NEW_ISSUE_USER_EMAIL];
        CGRect imageFrame = CGRectMake(self.frame.size.width - 118, emailField.frame.origin.y - IMAGE_HEIGHT - 10, 100, IMAGE_HEIGHT);
        imageFrame.size.width = MIN(self.frame.size.width - 36, round(image.size.width * IMAGE_HEIGHT/image.size.height));
        imageFrame.origin.x = self.frame.size.width - imageFrame.size.width -18;
        
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = TAG_ImageView;
        imageView.frame = imageFrame;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        imageView.clipsToBounds = YES;
        imageView.layer.borderColor = [[UIColor colorWithRed:0.294f green:0.569f blue:0.875f alpha:1.00f] CGColor];
        imageView.layer.borderWidth = 2.f;
        imageView.backgroundColor = [UIColor colorWithRed:0.961f green:0.961f blue:0.961f alpha:1.00f];
        [self addSubview:imageView];
        
        UIButton *removeImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [removeImageButton setImage:HCImageNamed(@"btn_deletepic_nomal") forState:UIControlStateNormal];
        [removeImageButton setImage:HCImageNamed(@"btn_deletepic_selected") forState:UIControlStateHighlighted];
        removeImageButton.frame = CGRectMake(0, 0, 44, 44);
        removeImageButton.tag = TAG_Image_Remove_Button;
        removeImageButton.center = CGPointMake(CGRectGetMaxX(imageFrame), CGRectGetMinY(imageFrame));
        removeImageButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [removeImageButton addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:removeImageButton];
        
        UIButton *cameralBtn = (UIButton *)[self viewWithTag:TAG_Cameral_Button];
        cameralBtn.hidden = YES;
    }
    [self beginEditing];
}

- (void)removeImage:(id)sender {
    UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_ImageView];
    [imageView removeFromSuperview];
    [sender removeFromSuperview];
    
    UIButton *cameralBtn = (UIButton *)[self viewWithTag:TAG_Cameral_Button];
    cameralBtn.hidden = NO;
}

- (CGSize)actualSizeAfterScaleInImageView:(UIImageView *)imageView {
    CGFloat sx = imageView.frame.size.width / imageView.image.size.width;
    CGFloat sy = imageView.frame.size.height / imageView.image.size.height;
    CGFloat s = 1.0;
    s = fminf(sx, sy);
    return CGSizeMake(s * imageView.image.size.width, s * imageView.image.size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIView *titleView = [self viewWithTag:TAG_NEW_ISSUE_TITLE];
    CGRect titleViewFrame = titleView.frame;
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_ImageView];
    if (imageView) {
        CGRect imageFrame = imageView.frame;
        UIView *removeImageButton = [self viewWithTag:TAG_Image_Remove_Button];
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            imageFrame.size.width = MIN(imageFrame.size.width, self.frame.size.width/2);
            imageFrame.size.height = MIN(imageFrame.size.height, titleViewFrame.size.height - removeImageButton.frame.size.height/2);
            imageView.frame = imageFrame;
            
            // 重新计算 ImageView 的大小
            CGSize actualImgSize = [self actualSizeAfterScaleInImageView:imageView];
            imageFrame.size = actualImgSize;
            imageView.frame = imageFrame;
            imageFrame.origin.x = self.frame.size.width - imageFrame.size.width -18;
            imageFrame.origin.y = titleViewFrame.origin.y + titleViewFrame.size.height - imageFrame.size.height;
            removeImageButton.center = CGPointMake(CGRectGetMaxX(imageFrame), CGRectGetMinY(imageFrame));
            imageView.frame = imageFrame;
            
            titleViewFrame.size.width = imageFrame.origin.x - 15;
        } else {
            imageFrame.size.width = MIN(imageFrame.size.width, self.frame.size.width -36);
            imageView.frame = imageFrame;

            // 重新计算 ImageView 的大小
            CGSize actualImgSize = [self actualSizeAfterScaleInImageView:imageView];
            imageFrame.size = actualImgSize;
            imageFrame.origin.x = self.frame.size.width - imageFrame.size.width -18;
            imageFrame.origin.y = self.frame.size.height - imageFrame.size.height - TextField_Height - 10;
            imageView.frame = imageFrame;
            removeImageButton.center = CGPointMake(CGRectGetMaxX(imageFrame), CGRectGetMinY(imageFrame));
            imageView.frame = imageFrame;
            
            titleViewFrame.size.height = imageFrame.origin.y - titleViewFrame.origin.y -15;
        }
    } else {
        UIView *cameralBtn = [self viewWithTag:TAG_Cameral_Button];
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            titleViewFrame.size.width = cameralBtn.frame.origin.x - 15;
        } else {
            titleViewFrame.size.height = cameralBtn.frame.origin.y - titleViewFrame.origin.y -15;
        }
        titleView.frame = titleViewFrame;
    }
    titleView.frame = titleViewFrame;
}

#pragma mark -

- (void)setDoneAction:(void (^)(NSString *, NSString *, NSString *, UIImage *))block {
    self.actionBlock = [block copy];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emailRegex options:kNilOptions error:&error];
    if (error) {
        MLLogError(@"failed to create regular expression, error: %@", error);
    }
    NSRange f = [regex rangeOfFirstMatchInString:checkString options:kNilOptions range:NSMakeRange(0, checkString.length)];
    return f.location != NSNotFound;
    
// NSPredicate Leaks: http://www.openradar.me/23025446
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)tryToTriggerSendAction {
    
    UITextView *titleTextView = (UITextView *)[self viewWithTag:TAG_NEW_ISSUE_TITLE];
    if (titleTextView.text.length == 0) {
        [titleTextView becomeFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:HCLocalizedString(@"Invalid Entry", nil) message:HCLocalizedString(@"Please enter a brief description of the issue you are facing.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:HCLocalizedString(@"OK", nil), nil];
        [alertView show];
        return NO;
    }
    UITextField *nameField = (UITextField *)[self viewWithTag:TAG_NEW_ISSUE_USER_NAME];
    if (nameField.text.length == 0) {
        nameField.rightView = [[UIImageView alloc] initWithImage:HCImageNamed(@"icon_error")];
        [nameField becomeFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:HCLocalizedString(@"Name Invalid", nil) message:HCLocalizedString(@"Please provide a name.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:HCLocalizedString(@"OK", nil), nil];
        [alertView show];
        return NO;
    }
    
    UITextField *emailField = (UITextField *)[self viewWithTag:TAG_NEW_ISSUE_USER_EMAIL];
    if (emailField.text.length && NO == [self NSStringIsValidEmail:emailField.text]) {
        [emailField becomeFirstResponder];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:HCLocalizedString(@"Email invalid", nil) message:HCLocalizedString(@"Please provide a valid email address.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:HCLocalizedString(@"OK", nil), nil];
        [alertView show];
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTitleKey];
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_ImageView];
    UIImage *image = imageView.image;
    
    // create issue
    if (self.actionBlock) {
        self.actionBlock(titleTextView.text, nameField.text, emailField.text, image);
    }
    
    return YES;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == TAG_NEW_ISSUE_USER_NAME) {
        UITextField *emailField = (UITextField *)[self viewWithTag:TAG_NEW_ISSUE_USER_EMAIL];
        [emailField becomeFirstResponder];
    } else if (textField.tag == TAG_NEW_ISSUE_USER_EMAIL) {
        if ([self tryToTriggerSendAction]) {
            [textField resignFirstResponder];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == TAG_NEW_ISSUE_USER_NAME) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kIssueUserNameKey];
    } else if (textField.tag == TAG_NEW_ISSUE_USER_EMAIL) {
        [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:kIssueUserEmailKey];
    }
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
    UITextField *tf = (UITextField *)notification.object;
    tf.rightView = nil;
}

#pragma mark -
#pragma mark 

- (void)textViewDidEndEditing:(UITextView *)textView {
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:kTitleKey];
}

@end
