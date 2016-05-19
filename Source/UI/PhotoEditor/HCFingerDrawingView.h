//
//  FingerDrawingView.h
//  MiddleFingerDrawings
//
//  Created by Robert Carter on 8/21/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2);

typedef NS_ENUM(NSInteger, HCDrawingMode) {
    HCDrawingModeDraw = 0,
    HCDrawingModeErase = 1
};

@interface HCFingerDrawingView : UIView

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic) HCDrawingMode mode;

@end
