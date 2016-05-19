//
//  MLHCNavigationController.m
//  MaxLeap
//

#import "HCNavigationController.h"
#import "MLIssuesImageHelper.h"
#import "UIImage+Color.h"
#import "HCIssuesTheme.h"


@interface HCNavigationController ()

@property (nonatomic) UIStatusBarStyle previousStatusBarStyle;

@property (nonatomic, strong) UIImage *previousBackButtonBackgroundImage;
@property (nonatomic, strong) UIImage *previousItemBackgroundImage;
@property (nonatomic, strong) NSDictionary *previousItemTitleAttr;

@end

@implementation HCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    HCNavigationBarAttributes *navAttr = [HCIssuesTheme currentTheme].navigationBarAttributes;
    
    // custom NavigationBar
    // custom default backBarButtonItem
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[self class], nil];
    
    UIImage *backIndicator = HCStretchableImage(@"ml_btn_navigationbar_back", 20, 0);
    [barButtonItem setBackButtonBackgroundImage:backIndicator forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeZero;
    [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:navAttr.buttonTextFont,
                                            NSForegroundColorAttributeName:navAttr.buttonTextColor,
                                            NSShadowAttributeName:shadow
                                            }
                                 forState:UIControlStateNormal];
    
    BOOL ios7OrLater = [[UIDevice currentDevice].systemVersion compare:@"7.0"] != NSOrderedAscending;
    if (ios7OrLater) {
        self.navigationBar.barTintColor = navAttr.backgroundColor;
        self.navigationBar.translucent = NO;
    } else {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            UIImage *bgImg = navAttr.backgroundImage?:[UIImage hc_imageWithColor:navAttr.backgroundColor];
            [self.navigationBar setBackgroundImage:bgImg forBarMetrics:UIBarMetricsDefault];
        } else {
            UIImage *bgImg = (navAttr.backgroundImageLangscape?:navAttr.backgroundImage)?:[UIImage hc_imageWithColor:navAttr.backgroundColor];
            [self.navigationBar setBackgroundImage:bgImg forBarMetrics:UIBarMetricsDefault];
        }
        [self.navigationBar setShadowImage:navAttr.shadowImage];
    }
    
    NSMutableDictionary *dict = [@{NSForegroundColorAttributeName:navAttr.titleColor,
                                   NSFontAttributeName:navAttr.titleFont
                                   } mutableCopy];
    if ( ! ios7OrLater) {
        NSShadow *shadow = [NSShadow new];
        shadow.shadowOffset = navAttr.titleShadowOffset;
        shadow.shadowColor = navAttr.titleShadowColor;
        dict[NSShadowAttributeName] = shadow;
    }
    self.navigationBar.titleTextAttributes = dict;
    
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:self.previousStatusBarStyle animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.supportedOrientations > 0) {
        return self.supportedOrientations;
    }
    return [super supportedInterfaceOrientations];
}

@end
