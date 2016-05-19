//
//  MLBaseViewController.m
//  MaxLeap
//

#import "HCBaseViewController.h"
#import "HCConversationViewController.h"
#import "HCDejalStatusView.h"
#import "UIImage+Color.h"
#import "HCIssueManager.h"
#import "HCIssuesTheme.h"
#import "HCLocalizable.h"


@interface HCBaseViewController ()

@property (nonatomic) UIOffset offset;

@end

@implementation HCBaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self= [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.showContactUs = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationItems];
}

- (void)setupNavigationItems {
    
    if ([self isEqual:self.navigationController.viewControllers.firstObject]) {
        UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithImage:HCImageRenderingOriginal(@"ml_btn_navigationbar_close") style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
        [closeItem setImageInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
        self.navigationItem.leftBarButtonItem = closeItem;
    }
}

- (void)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openConversation:(id)sender {
    HCConversationViewController *conversationvc = [HCConversationViewController new];
    [self.navigationController pushViewController:conversationvc animated:YES];
}

#pragma mark -

- (void)startActivity {
    [self showMessage:nil onlyText:NO withDuration:-1];
}

- (void)showError:(NSString *)errorMessage {
    [self showMessage:errorMessage onlyText:YES];
}

- (void)showMessage:(NSString *)messge onlyText:(BOOL)onlyText {
    NSTimeInterval duration = [self displayDurationForString:messge];
    [self showMessage:messge onlyText:onlyText withDuration:duration];
}

- (void)showMessage:(NSString *)messge onlyText:(BOOL)onlyText withDuration:(NSTimeInterval)duration {
    [HCDejalBezelActivityView showInView:self.view withText:messge onlyText:onlyText];
    if (duration >= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [HCDejalBezelActivityView removeViewAnimated:YES];
        });
    }
}

- (void)stopActivity {
    [HCDejalBezelActivityView removeViewAnimated:YES];
}

- (NSTimeInterval)displayDurationForString:(NSString*)string {
    return MIN((float)string.length*0.06 + 0.5, 5.0);
}

@end
