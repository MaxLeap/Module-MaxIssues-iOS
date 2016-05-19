//
//  HCColorSelector.m
//  MaxLeap
//

#import "HCColorSelector.h"

#define kStrokeColorKey @"com.las.helpcenter.photoeditor.strokecolorindex"

@interface HCColorSelector ()
@property (nonatomic, strong) NSArray *colorList;
@end

@implementation HCColorSelector

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.colorList = [[self class] colorList];
        
        CGFloat d = round((frame.size.width - 88 - 22 * self.colorList.count)/(self.colorList.count-1));
        CGRect btnframe = CGRectMake(44, 13, 22, 22);
        
        for (int index = 0; index < self.colorList.count; index ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = self.colorList[index];
            btn.frame = btnframe;
            btn.tag = index + 100;
            btn.layer.cornerRadius = 1.f;
            [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            btnframe.origin.x += d + btnframe.size.width;
        }
        
        NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:kStrokeColorKey];
        self.selectedColor = self.colorList[index];
    }
    return self;
}

- (void)buttonAction:(id)sender {
    [self selectColorAtIndex:[sender tag]-100];
}

- (void)selectColorAtIndex:(NSInteger)index {
    self.selectedColor = self.colorList[index];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:kStrokeColorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.colorDidChangeBlock) {
        self.colorDidChangeBlock(self.selectedColor);
    }
}

+ (UIColor *)color {
    NSArray *colorList = [self colorList];
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:kStrokeColorKey];
    if (index > colorList.count || index < 0) {
        index = 0;
    }
    return [self colorList][index];
}

+ (NSArray *)colorList {
    return @[[UIColor colorWithRed:226/255.f green:64/255.f blue:80/255.f alpha:1.f],
             [UIColor colorWithRed:247/255.f green:90/255.f blue:41/255.f alpha:1.f],
             [UIColor colorWithRed:234/255.f green:210/255.f blue:67/255.f alpha:1.f],
             [UIColor colorWithRed:148/255.f green:191/255.f blue:20/255.f alpha:1.f],
             [UIColor colorWithRed:160/255.f green:212/255.f blue:255/255.f alpha:1.f],
             [UIColor colorWithRed:143/255.f green:124/255.f blue:180/255.f alpha:1.f],
             [UIColor colorWithRed:34/255.f green:55/255.f blue:64/255.f alpha:1.f]
             ];
}

@end
