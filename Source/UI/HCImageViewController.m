//
//  HCImageDisplayViewController.m
//  MaxLeap
//

#import "HCImageViewController.h"

typedef struct {
    BOOL statusBarHiddenPriorToPresentation;
    UIStatusBarStyle statusBarStylePriorToPresentation;
    CGRect startingReferenceFrameForThumbnail;
    CGRect startingReferenceFrameForThumbnailInPresentingViewControllersOriginalOrientation;
    CGPoint startingReferenceCenterForThumbnail;
    UIInterfaceOrientation startingInterfaceOrientation;
    BOOL presentingViewControllerPresentedFromItsUnsupportedOrientation;
} HCImageViewControllerStartingInfo;




@implementation HCImageInfo

- (NSMutableDictionary *)userInfo {
    if (_userInfo == nil) {
        _userInfo = [[NSMutableDictionary alloc] init];
    }
    return _userInfo;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\
            %@ %p \n\
            imageURL: %@ \n\
            referenceRect: (%g, %g) (%g, %g)",
            
            NSStringFromClass(self.class), self,
            self.imageURL,
            self.referenceRect.origin.x, self.referenceRect.origin.y, self.referenceRect.size.width, self.referenceRect.size.height
            ];
}

- (CGPoint)referenceRectCenter {
    return CGPointMake(self.referenceRect.origin.x + self.referenceRect.size.width/2.0f,
                       self.referenceRect.origin.y + self.referenceRect.size.height/2.0f);
}

@end




@interface HCImageViewController ()
<UIScrollViewDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic) HCImageViewControllerStartingInfo startingInfo;
@property (nonatomic, strong) HCImageInfo *imageInfo;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HCImageViewController

+ (void)displayWithImageInfo:(HCImageInfo *)imageInfo fromViewController:(UIViewController *)viewController {
    HCImageViewController *vc = [[HCImageViewController alloc] initWithImageInfo:imageInfo];
    if (viewController) {
        [vc presentFromViewController:viewController];
    } else {
        [vc presentFromRootViewController];
    }
}

- (instancetype)initWithImageInfo:(HCImageInfo *)imageInfo {
    if (self = [super init]) {
        self.imageInfo = imageInfo;
        self.image = imageInfo.image;
    }
    return self;
}

- (void)presentFromRootViewController
{
    UIViewController *presentingViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (presentingViewController.presentedViewController) {
        presentingViewController = presentingViewController.presentedViewController;
    }
    [self presentFromViewController:presentingViewController];
}

- (void)presentFromViewController:(UIViewController *)controller
{
    _startingInfo.statusBarHiddenPriorToPresentation = [UIApplication sharedApplication].statusBarHidden;
    _startingInfo.statusBarStylePriorToPresentation = [UIApplication sharedApplication].statusBarStyle;
    
    [self doAnimationCompletion:^(dispatch_block_t clearBlock) {
        [controller presentViewController:self animated:NO completion:clearBlock];
    }];
}

- (void)doAnimationCompletion:(void (^)(dispatch_block_t clearBlock))completion {
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *blackBackdrop = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, screenSize}];
    blackBackdrop.backgroundColor = [UIColor clearColor];
    [window addSubview:blackBackdrop];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.contentMode = self.imageInfo.referenceContentMode;
    imageView.layer.cornerRadius = self.imageInfo.referenceCornerRadius;
    imageView.frame = [window convertRect:self.imageInfo.referenceRect fromView:self.imageInfo.referenceView];
    imageView.alpha = 0;
    [window addSubview:imageView];
    
    CGRect toFrame = blackBackdrop.frame;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        blackBackdrop.backgroundColor = [UIColor blackColor];
        imageView.alpha = 1;
        imageView.frame = toFrame;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    } completion:^(BOOL finished) {
        completion(^{
            [blackBackdrop removeFromSuperview];
            [imageView removeFromSuperview];
        });
    }];
}

- (void)dismiss {
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *blackBackdrop = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, screenSize}];
    blackBackdrop.backgroundColor = [UIColor blackColor];
    [window addSubview:blackBackdrop];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = self.imageInfo.referenceCornerRadius;
    imageView.frame = [window convertRect:self.imageView.frame fromView:self.scrollView];
    [window addSubview:imageView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.startingInfo.statusBarHiddenPriorToPresentation withAnimation:UIStatusBarAnimationFade];
    [UIApplication sharedApplication].statusBarStyle = self.startingInfo.statusBarStylePriorToPresentation;
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        CGRect toFrame = [window convertRect:self.imageInfo.referenceRect fromView:self.imageInfo.referenceView];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            blackBackdrop.backgroundColor = [UIColor clearColor];
            imageView.alpha = 0;
            imageView.frame = toFrame;
            imageView.contentMode = self.imageInfo.referenceContentMode;
        } completion:^(BOOL finished) {
            [blackBackdrop removeFromSuperview];
            [imageView removeFromSuperview];
        }];
    }];
}

#pragma mark -
#pragma mark view life-cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else {
//        self.wantsFullScreenLayout = YES;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.f;
    self.scrollView.maximumZoomScale = 2.5f;
    [self.view addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    CGSize bestSize = [self sizeForImageViewWithScale:self.scrollView.zoomScale];
    self.imageView.frame = (CGRect){CGPointZero, bestSize};
    self.scrollView.contentSize = bestSize;
    self.scrollView.contentInset = [self contentInsetForScrollView:self.scrollView.zoomScale];
    
    [self setupGestureRecognizers];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark -
#pragma mark Gestures

- (void)setupGestureRecognizers {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapImgViewTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapImgViewTwice.numberOfTapsRequired = 2;
    tapImgViewTwice.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapImgViewTwice];
    [tapGesture requireGestureRecognizerToFail:tapImgViewTwice];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGesture {
    [self dismiss];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGesture {
    [self zoomInZoomOut:[tapGesture locationInView:self.imageView]];
}

- (void) zoomInZoomOut:(CGPoint)point {
    // Check if current Zoom Scale is greater than half of max scale then reduce zoom and vice versa
    CGFloat newZoomScale = _scrollView.zoomScale > (_scrollView.maximumZoomScale/2)?_scrollView.minimumZoomScale:_scrollView.maximumZoomScale;
    
    CGSize scrollViewSize = _scrollView.bounds.size;
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = point.x - (w / 2.0f);
    CGFloat y = point.y - (h / 2.0f);
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [_scrollView zoomToRect:rectToZoomTo animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    scrollView.scrollEnabled = (scale > 1);
    scrollView.contentInset = [self contentInsetForScrollView:scale];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    scrollView.contentInset = [self contentInsetForScrollView:scrollView.zoomScale];
    
    if (scrollView.scrollEnabled == NO) {
        scrollView.scrollEnabled = YES;
    }
}

#pragma mark -

- (CGSize)sizeForImageViewWithScale:(CGFloat)scale {
    CGSize imageSize = self.image.size;
    CGSize viewSize = self.scrollView.frame.size;
    
    CGFloat width = 0, height = 0;
    
    if (imageSize.width / imageSize.height >= viewSize.width / viewSize.height) {
        // 这个图片比较宽
        width = viewSize.width;
        height = round(imageSize.height * width / imageSize.width);
    } else {
        // 这个图片比较窄
        height = viewSize.height;
        width = round(imageSize.width * height / imageSize.height);
    }
    return CGSizeMake(width * scale, height * scale);
}

- (UIEdgeInsets)contentInsetForScrollView:(CGFloat)targetZoomScale {
    UIEdgeInsets inset = UIEdgeInsetsZero;
    CGFloat boundsHeight = self.scrollView.bounds.size.height;
    CGFloat boundsWidth = self.scrollView.bounds.size.width;
    CGFloat contentHeight = (self.imageView.image.size.height > 0) ? self.imageView.image.size.height : boundsHeight;
    CGFloat contentWidth = (self.imageView.image.size.width > 0) ? self.imageView.image.size.width : boundsWidth;
    CGFloat minContentHeight;
    CGFloat minContentWidth;
    if (contentHeight > contentWidth) {
        if (boundsHeight/boundsWidth < contentHeight/contentWidth) {
            minContentHeight = boundsHeight;
            minContentWidth = contentWidth * (minContentHeight / contentHeight);
        } else {
            minContentWidth = boundsWidth;
            minContentHeight = contentHeight * (minContentWidth / contentWidth);
        }
    } else {
        if (boundsWidth/boundsHeight < contentWidth/contentHeight) {
            minContentWidth = boundsWidth;
            minContentHeight = contentHeight * (minContentWidth / contentWidth);
        } else {
            minContentHeight = boundsHeight;
            minContentWidth = contentWidth * (minContentHeight / contentHeight);
        }
    }
    CGFloat myHeight = self.view.bounds.size.height;
    CGFloat myWidth = self.view.bounds.size.width;
    minContentWidth *= targetZoomScale;
    minContentHeight *= targetZoomScale;
    if (minContentHeight > myHeight && minContentWidth > myWidth) {
        inset = UIEdgeInsetsZero;
    } else {
        CGFloat verticalDiff = boundsHeight - minContentHeight;
        CGFloat horizontalDiff = boundsWidth - minContentWidth;
        verticalDiff = (verticalDiff > 0) ? verticalDiff : 0;
        horizontalDiff = (horizontalDiff > 0) ? horizontalDiff : 0;
        inset.top = verticalDiff/2.0f;
        inset.bottom = verticalDiff/2.0f;
        inset.left = horizontalDiff/2.0f;
        inset.right = horizontalDiff/2.0f;
    }
    return inset;
}

@end
