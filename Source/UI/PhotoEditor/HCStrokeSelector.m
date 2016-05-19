//
//  HCStrokeSelector.m
//  MaxLeap
//

#import "HCStrokeSelector.h"
#import "MLIssuesImageHelper.h"

@interface HCStrokeSelector ()
@property (nonatomic, strong) void(^valueChangedBlock)(NSInteger value);
@end

@implementation HCStrokeSelector

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.width = 144;
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:HCImageNamed(@"icon_strokeselectionbar")];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.frame = self.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        
        CGFloat btnWidth = round(frame.size.width/5);
        
        for (int i = 0; i < 5; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            btn.tag = i +100;
            btn.frame = CGRectMake(i*btnWidth, 0, btnWidth, frame.size.height);
            [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
        UIImageView *thumb = [[UIImageView alloc] initWithImage:HCImageNamed(@"icon_slider")];
        thumb.contentMode = UIViewContentModeScaleAspectFit;
        thumb.frame = CGRectMake(0, 0, 15, 15);
        thumb.tag = 200;
        [self addSubview:thumb];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIImageView *thumb = (UIImageView *)[self viewWithTag:200];
    CGRect frame = thumb.frame;
    frame.size.width = (self.selectedIndex +3)*2;
    frame.size.height = frame.size.width;
    thumb.frame = frame;
    if (self.selectedIndex == 0) {
        thumb.center = CGPointMake(3, self.frame.size.height/2);
    } else if (self.selectedIndex == 1) {
        thumb.center = CGPointMake(32, self.frame.size.height/2);
    } else if (self.selectedIndex == 2) {
        thumb.center = CGPointMake(65, self.frame.size.height/2);
    } else if (self.selectedIndex == 3) {
        thumb.center = CGPointMake(100, self.frame.size.height/2);
    } else if (self.selectedIndex == 4) {
        thumb.center = CGPointMake(137, self.frame.size.height/2);
    }
    
}

- (void)buttonAction:(id)sender {
    self.selectedIndex = [sender tag] -100;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        
        [self setNeedsLayout];
        
        if (self.valueChangedBlock) {
            self.valueChangedBlock(self.selectedIndex);
        }
    }
}

@end
