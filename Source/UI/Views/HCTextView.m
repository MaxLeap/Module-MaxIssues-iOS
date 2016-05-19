//
//  HCTextView.m
//  MaxLeap
//

#import "HCTextView.h"

@interface HCTextView ()
@property(nonatomic,weak)UILabel *placehoderLabel;
@end

@implementation HCTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        
        // 1.添加一个显示提醒文字的label（显示占位文字的label）
        UILabel *placehoderLabel=[[UILabel alloc]init];
        //2.设置相关的属性
        //设置支持多行格式
        placehoderLabel.numberOfLines=0;
        //设置清除背景颜色
        placehoderLabel.backgroundColor=[UIColor clearColor];
        //3.把控件添加到view上
        [self  addSubview:placehoderLabel];
        
        //4.使用全局变量来记录
        self.placehoderLabel=placehoderLabel;
        
        //设置默认的占位文字的颜色为亮灰色
        self.placehoderColor=[UIColor lightGrayColor];
        //设置默认的字体为14号字体
        self.font=[UIFont systemFontOfSize:14];
        
        //注册一个通知中心，监听文字的改变
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
        
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark-监听文字的改变

-(void)textDidChange
{
    self.placehoderLabel.hidden=(self.text.length!=0);
}

#pragma mark 设置占位文字
-(void)setPlacehoder:(NSString *)placehoder
{
    _placehoder=[placehoder copy];
    //设置文字
    self.placehoderLabel.text=placehoder;
    //重新计算文字的frame
    [self setNeedsLayout];
}

#pragma mark 设置占位文字的颜色
-(void)setPlacehoderColor:(UIColor *)placehoderColor
{
    _placehoderColor=placehoderColor;
    self.placehoderLabel.textColor=placehoderColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect phframe = self.placehoderLabel.frame;
    
    phframe.origin.y = 8;
    phframe.origin.x = 5;
    phframe.size.width = self.frame.size.width - 2 * phframe.origin.x;
    
    // 根据文字计算label的高度
    CGSize maxSize = CGSizeMake(phframe.size.width, MAXFLOAT);
    CGSize size = [self.placehoderLabel sizeThatFits:maxSize];
    phframe.size.height = size.height;
    
    self.placehoderLabel.frame = phframe;
}

-(void)setFont:(UIFont *)font
{
    //该属性是继承来的，因此需要调用父类的方法
    [super setFont:font];
    self.placehoderLabel.font=font;
    //重新计算子控件的frame
    [self setNeedsLayout];
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    [self textDidChange];
}

@end
