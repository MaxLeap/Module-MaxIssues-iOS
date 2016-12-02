//
//  MLBaseViewController.m
//  MaxLeap
//

#import "HCBaseViewController.h"
#import "HCConversationViewController.h"
#import "HCDejalStatusView.h"
#import "UIImage+HCIssueColor.h"
#import "HCIssueManager.h"
#import "HCIssuesTheme.h"
#import "HCLocalizable.h"
#import "MLIssuesImageHelper.h"

@interface HCBaseViewController ()

@property (nonatomic) UIOffset offset;

@property (nonatomic) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, strong) UIImage *previousBackButtonBackgroundImage;
@property (nonatomic, strong) NSDictionary *previousItemTitleAttr;

@property (nonatomic, strong) UIColor *previousBarTintColor;
@property (nonatomic) BOOL previousTranslucent;
@property (nonatomic) UIBarStyle previousBarStyle;
@property (nonatomic, strong) NSDictionary *previousTitleTextAttributes;

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    [self setupNavigationBar];
    [self setupNavigationItems];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:self.previousBackButtonBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitleTextAttributes:self.previousItemTitleAttr forState:UIControlStateNormal];
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
    
    UINavigationBar *navbar = self.navigationController.navigationBar;
    navbar.barTintColor = self.previousBarTintColor;
    navbar.translucent = self.previousTranslucent;
    navbar.barStyle = self.previousBarStyle;
    navbar.titleTextAttributes = self.previousTitleTextAttributes;
}

- (void)setupNavigationBar {
    HCNavigationBarAttributes *navAttr = [HCIssuesTheme currentTheme].navigationBarAttributes;
    
    // custom NavigationBar
    // custom default backBarButtonItem
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    
    self.previousBackButtonBackgroundImage = [barButtonItem backButtonBackgroundImageForState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.previousItemTitleAttr = [barButtonItem titleTextAttributesForState:UIControlStateNormal];
    
    UIImage *backIndicator = HCStretchableImage(@"ml_btn_navigationbar_back", 20, 0);
    [barButtonItem setBackButtonBackgroundImage:backIndicator forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:navAttr.buttonTextFont,
                                            NSForegroundColorAttributeName:navAttr.buttonTextColor
                                            }
                                 forState:UIControlStateNormal];
    
    UINavigationBar *navbar = self.navigationController.navigationBar;
    
    self.previousBarTintColor = navbar.barTintColor;
    self.previousTranslucent = navbar.translucent;
    self.previousBarStyle = navbar.barStyle;
    self.previousTitleTextAttributes = navbar.titleTextAttributes;
    
    navbar.barTintColor = navAttr.backgroundColor;
    navbar.translucent = NO;
    navbar.barStyle = navAttr.barStyle;
    navbar.titleTextAttributes = @{NSForegroundColorAttributeName:navAttr.titleColor,
                                   NSFontAttributeName:navAttr.titleFont
                                   };
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
