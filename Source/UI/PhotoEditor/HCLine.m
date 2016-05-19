//
//  Line.m
//  MiddleFingerDrawings
//
//  Created by Robert Carter on 8/21/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import "HCLine.h"

@implementation HCLine

+ (HCLine *)lineWithStartPoint:(CGPoint)start endPoint:(CGPoint)end color:(UIColor *)color width:(CGFloat)width
{
    HCLine *line = [HCLine new];
    line.start = start;
    line.end = end;
    line.color = color;
    line.width = width;
    return line;
}

-(void)drawLineWithContext:(CGContextRef)context
{
    
    [self.color set];
    // Draw the lines in here
    CGContextMoveToPoint(context, self.start.x, self.start.y);
    
    CGContextSetLineWidth(context, self.width);
    
    
    // Define strobe end point
    CGContextAddLineToPoint(context, self.end.x, self.end.y);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);

}
@end
