//
//  HCStrokeSelector.h
//  MaxLeap
//

#import <UIKit/UIKit.h>

@interface HCStrokeSelector : UIView

@property (nonatomic) NSInteger selectedIndex;

- (void)setValueChangedBlock:(void(^)(NSInteger value))block;

@end
