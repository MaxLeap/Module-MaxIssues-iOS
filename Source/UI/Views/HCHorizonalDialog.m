//
//  HCIssueReopenView.m
//  MaxLeap
//

#import "HCHorizonalDialog.h"

#define LINE_COLOR [UIColor colorWithRed:0.898f green:0.898f blue:0.898f alpha:1.00f]


@interface HCHorizonalDialog ()
@property (nonatomic, strong) dispatch_block_t leftBlock;
@property (nonatomic, strong) dispatch_block_t rightBlock;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation HCHorizonalDialog

- (instancetype)initWithLeftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle prompt:(NSString *)prompt {
    
    if (self = [self initWithFrame:CGRectMake(0, 0, 320, 35)]) {
        [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
        [self.leftButton setTitle:leftTitle forState:UIControlStateNormal];
        self.promptLabel.text = prompt;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    frame.size.height = 30;
    
    if (self = [super initWithFrame:frame]) {
        
        UIColor *blueColor = [UIColor colorWithRed:100/255.f green:167/255.f blue:235/255.f alpha:1.00f];
        UIColor *grayColor = [UIColor lightGrayColor];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [rightButton setTitleColor:grayColor forState:UIControlStateNormal];
        rightButton.layer.borderColor = grayColor.CGColor;
        rightButton.layer.borderWidth = 0.5;
        [rightButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightButton];
        self.rightButton = rightButton;
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [leftButton setTitleColor:blueColor forState:UIControlStateNormal];
        [leftButton setTitleColor:grayColor forState:UIControlStateHighlighted];
        leftButton.layer.borderColor = blueColor.CGColor;
        leftButton.layer.borderWidth = 0.5;
        [leftButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftButton];
        self.leftButton = leftButton;
        
        UILabel *promptLable = [[UILabel alloc] initWithFrame:CGRectZero];
        promptLable.textColor = [UIColor colorWithRed:151/255.f green:151/255.f blue:151/255.f alpha:1.00f];
        promptLable.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        [self addSubview:promptLable];
        self.promptLabel = promptLable;
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        topLine.backgroundColor = LINE_COLOR;
        topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:topLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIButton *rightButton = self.rightButton;
    [rightButton sizeToFit];
    CGRect rightBtnFrame = rightButton.frame;
    rightBtnFrame.size.width += 20;
    rightBtnFrame.size.height = 20;
    rightBtnFrame.origin.x = self.frame.size.width - rightBtnFrame.size.width - 11;
    rightBtnFrame.origin.y = 7;
    rightButton.frame = rightBtnFrame;
    
    UIButton *leftButton = self.leftButton;
    [leftButton sizeToFit];
    CGRect leftBtnFrame = leftButton.frame;
    leftBtnFrame.size.width += 20;
    leftBtnFrame.size.height = 20;
    leftBtnFrame.origin.x = rightBtnFrame.origin.x - leftBtnFrame.size.width - 14;
    leftBtnFrame.origin.y = rightBtnFrame.origin.y;
    leftButton.frame = leftBtnFrame;
    
    self.promptLabel.frame = CGRectMake(16, 5, leftBtnFrame.origin.x -21, self.frame.size.height - 10);
}

- (void)setLeftAction:(dispatch_block_t)block {
    self.leftBlock = [block copy];
}

- (void)setRightAction:(dispatch_block_t)block {
    self.rightBlock = [block copy];
}

- (void)leftAction:(id)sender {
    if (self.leftBlock) {
        self.leftBlock();
    }
}

- (void)rightAction:(id)sender {
    if (self.rightBlock) {
        self.rightBlock();
    }
}

- (NSString *)prompt {
    return self.promptLabel.text;
}

- (void)setPrompt:(NSString *)prompt {
    self.promptLabel.text = prompt;
}

@end
