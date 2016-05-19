//
//  Line.h
//  MiddleFingerDrawings
//
//  Created by Robert Carter on 8/21/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCLine : NSObject

@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
@property (nonatomic) CGFloat width;
@property (nonatomic, strong) UIColor *color;

+ (HCLine *)lineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end color:(UIColor*)color width:(CGFloat)width;

- (void)drawLineWithContext:(CGContextRef)context;

@end
