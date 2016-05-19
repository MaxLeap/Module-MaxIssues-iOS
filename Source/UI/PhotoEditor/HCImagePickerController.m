//
//  HCImagePickerController.m
//  MaxLeap
//

#import "HCImagePickerController.h"
#import "MLIssuesImageHelper.h"
#import "HCImageEditorViewController.h"
#import "UIImage+Color.h"
#import "HCIssuesTheme.h"
#import "MLLogging.h"

@interface HCImagePickerController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (nonatomic, strong) void (^doneAction)(UIImage *image);

@end


@implementation HCImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    HCNavigationBarAttributes *navAttr = [HCIssuesTheme currentTheme].navigationBarAttributes;
    
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[self class], nil];
    UIImage *backIndicator = HCStretchableImage(@"ml_btn_navigationbar_back", 20, 0);
    [barButtonItem setBackButtonBackgroundImage:backIndicator forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [barButtonItem setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    NSShadow *shadow = [[NSShadow alloc] init];
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
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = navAttr.titleShadowOffset;
        shadow.shadowColor = navAttr.titleShadowColor;
        dict[NSShadowAttributeName] = shadow;
    }
    self.navigationBar.titleTextAttributes = dict;
    
    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    MLLogDebugF(@"imagePickerController didFinishPickingMediaWithInfo: %@", info);
    
    HCImageEditorViewController *editor = [[HCImageEditorViewController alloc] init];
    editor.sourceImage = info[UIImagePickerControllerOriginalImage];
    editor.doneButtonTitle = self.doneButtonTitle;
    [editor setDoneAction:self.doneAction];
    [picker pushViewController:editor animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
