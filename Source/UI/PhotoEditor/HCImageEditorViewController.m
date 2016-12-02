//
//  HCImageEditorViewController.m
//  MaxLeap
//

#import "HCImageEditorViewController.h"
#import "HCFingerDrawingView.h"
#import "MLIssuesImageHelper.h"
#import "HCStrokeSelector.h"
#import "HCColorSelector.h"
#import "UIImage+HCIssueColor.h"
#import "MLDevice.h"

#define kStrokeIndexKey @"com.las.helpcenter.photoeditor.strokeselectedIndex"

#define StrockSelectorTag 1997
#define ShowColorSelBtnTag 1998
#define ColorSelectorTag 1999

@interface HCImageEditorViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) void (^doneAction)(UIImage *image);
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) HCFingerDrawingView *drawingView;
@property (nonatomic, strong) UIView *toolView;
@end

@implementation HCImageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:self.doneButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.851f green:0.851f blue:0.851f alpha:1.00f];
    self.view.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.sourceImage];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(16.5, 15, self.view.frame.size.width -33, self.view.frame.size.height - 30);
    imageView.layer.borderColor = [UIColor colorWithRed:0.659f green:0.659f blue:0.659f alpha:1.00f].CGColor;
    imageView.layer.borderWidth = 1.f;
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    self.drawingView = [[HCFingerDrawingView alloc] initWithFrame:[self imageRectInImageView:imageView]];
    self.drawingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.drawingView.backgroundColor = [UIColor clearColor];
    self.drawingView.lineWidth = [[NSUserDefaults standardUserDefaults] integerForKey:kStrokeIndexKey] +3;
    self.drawingView.userInteractionEnabled = YES;
    [imageView addSubview:self.drawingView];
    
    [self.drawingView becomeFirstResponder];
    
    [self setupToolView];
}

#pragma mark - layouts

- (CGRect)imageRectInImageView:(UIImageView *)imageView {
    CGSize imageSize = imageView.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(imageView.bounds)/imageSize.width, CGRectGetHeight(imageView.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(imageView.bounds)-scaledImageSize.width)), roundf(0.5f*(CGRectGetHeight(imageView.bounds)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    return imageFrame;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = CGRectMake(20, 15, self.view.frame.size.width -40, self.toolView.frame.origin.y - 40);
    
    BOOL ios7OrLater = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
    if (ios7OrLater) {
        if ([self respondsToSelector:@selector(topLayoutGuide)]) {
            frame.origin.y += [[self topLayoutGuide] length];
            frame.size.height -= [[self topLayoutGuide] length];
        }
    } else {
        CGFloat navBarH = self.navigationController.navigationBar.frame.size.height;
        frame.origin.y += navBarH;
        frame.size.height -= navBarH;
    }
    
    self.imageView.frame = frame;
    self.drawingView.frame = [self imageRectInImageView:self.imageView];
}

#pragma mark -
#pragma mark setup tool view

- (void)setupToolView {
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -48, self.view.frame.size.width, 48)];
    toolView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolView.backgroundColor = [UIColor colorWithRed:0.957f green:0.957f blue:0.957f alpha:1.00f];
    [self.view addSubview:toolView];
    self.toolView = toolView;
    
    // drawing mode selector
    UIImageView *imageView = [[UIImageView alloc] initWithImage:HCImageNamed(@"btn_toolselection_pen") highlightedImage:HCImageNamed(@"btn_toolselection_eraser")];
    [imageView sizeToFit];
    imageView.frame = CGRectMake(19, 10, imageView.frame.size.width, imageView.frame.size.height);
    imageView.userInteractionEnabled = YES;
    imageView.tag = 999;
    [toolView addSubview:imageView];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton addTarget:self action:@selector(changeDrawingMode:) forControlEvents:UIControlEventTouchUpInside];
    editButton.frame = CGRectMake(0, 0, imageView.frame.size.width/2, imageView.frame.size.height);
    editButton.tag = 0;
    [imageView addSubview:editButton];
    
    UIButton *eraseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [eraseButton addTarget:self action:@selector(changeDrawingMode:) forControlEvents:UIControlEventTouchUpInside];
    eraseButton.frame = CGRectMake(editButton.frame.size.width, 0, editButton.frame.size.width, editButton.frame.size.height);
    eraseButton.tag = 1;
    [imageView addSubview:eraseButton];
    
    // color selector
    CGRect colorBtnFrame = CGRectMake(toolView.frame.size.width - 22 - 19, 13, 22, 22);
    UIButton *colorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    colorBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    colorBtn.layer.cornerRadius = 1.f;
    colorBtn.frame = colorBtnFrame;
    colorBtn.tag = ShowColorSelBtnTag;
    [colorBtn addTarget:self action:@selector(showColorList:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:colorBtn];
    
    UIColor *color = [HCColorSelector color];
    colorBtn.backgroundColor = color;
    self.drawingView.lineColor = color;
    
    // stroke selector
    CGRect strokeFrame = CGRectMake(0, imageView.frame.origin.y, 144, imageView.frame.size.height);
    strokeFrame.origin.x = imageView.frame.origin.x + imageView.frame.size.width + round((colorBtnFrame.origin.x - (imageView.frame.origin.x + imageView.frame.size.width) -144)/2);
    HCStrokeSelector *strokeSeclector = [[HCStrokeSelector alloc] initWithFrame:strokeFrame];
    strokeSeclector.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    strokeSeclector.tag = StrockSelectorTag;
    strokeSeclector.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kStrokeIndexKey];
    __weak typeof(self) wself = self;
    [strokeSeclector setValueChangedBlock:^(NSInteger value) {
        wself.drawingView.lineWidth = value +3;
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kStrokeIndexKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [toolView addSubview:strokeSeclector];
}

- (void)changeDrawingMode:(id)sender {
    self.drawingView.mode = [sender tag];
    UIImageView *imageview = (UIImageView *)[self.toolView viewWithTag:999];
    imageview.highlighted = [sender tag];
    
    HCStrokeSelector *ss = (HCStrokeSelector *)[self.toolView viewWithTag:StrockSelectorTag];
    UIButton *colorBtn = (UIButton *)[self.toolView viewWithTag:ShowColorSelBtnTag];
    if (self.drawingView.mode == HCDrawingModeDraw) {
        ss.userInteractionEnabled = YES;
        ss.alpha = 1.f;
        colorBtn.enabled = YES;
        colorBtn.alpha = 1.f;
    } else {
        ss.userInteractionEnabled = NO;
        ss.alpha = 0.5;
        colorBtn.enabled = NO;
        colorBtn.alpha = 0.5;
        [self dismissColorList];
    }
}

- (void)showColorList:(id)sender {
    
    HCColorSelector *colorSelector = (HCColorSelector *)[self.view viewWithTag:ColorSelectorTag];
    if (!colorSelector) {
        CGRect frame = self.toolView.frame;
        colorSelector = [[HCColorSelector alloc] initWithFrame:frame];
        colorSelector.backgroundColor = self.toolView.backgroundColor;
        colorSelector.tag = ColorSelectorTag;
        __weak typeof(self)weakSelf = self;
        [colorSelector setColorDidChangeBlock:^(UIColor *color) {
            [sender setBackgroundColor:color];
            weakSelf.drawingView.lineColor = color;
        }];
        [self.view insertSubview:colorSelector belowSubview:self.toolView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(44, frame.size.height -1, frame.size.width - 88, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.847f green:0.847f blue:0.847f alpha:1.00f];
        [colorSelector addSubview:lineView];
        
        frame.origin.y -= frame.size.height;
        [UIView animateWithDuration:0.2 animations:^{
            colorSelector.frame = frame;
        }];
    }
}

- (void)dismissColorList {
    static BOOL dismissing = NO;
    UIView *colorView = [self.view viewWithTag:ColorSelectorTag];
    if (colorView && !dismissing) {
        dismissing = YES;
        [UIView animateWithDuration:0.2 animations:^{
            colorView.frame = self.toolView.frame;
        } completion:^(BOOL finished) {
            [colorView removeFromSuperview];
            dismissing = NO;
        }];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGRect rect = CGRectMake(0, self.toolView.frame.origin.y - self.toolView.frame.size.height, self.toolView.frame.size.width, self.toolView.frame.size.height *2);
    if ( ! CGRectContainsPoint(rect, location)) {
        [self dismissColorList];
    }
}

#pragma mark -

- (UIImage *)generateImage {
    
    CGSize imageSize = self.imageView.image.size;
    CGFloat scale = fmaxf(imageSize.width/CGRectGetWidth(self.imageView.bounds), imageSize.height/CGRectGetHeight(self.imageView.bounds));
    
    // generate high-resolution line image
    UIGraphicsBeginImageContextWithOptions(self.drawingView.frame.size, NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.drawingView.layer drawInContext:ctx];
    UIImage *lineImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // generate final image
    UIGraphicsBeginImageContext(imageSize);
    [self.imageView.image drawAtPoint:CGPointZero];
    [lineImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)doneAction:(id)sender {
    UIImage *image = [self generateImage];
    if (self.doneAction) {
        self.doneAction(image);
    }
}

@end
