//
//  FingerDrawingView.m
//  MiddleFingerDrawings
//
//  Created by Robert Carter on 8/21/12.
//  Copyright (c) 2012 Robert Carter. All rights reserved.
//

#import "HCFingerDrawingView.h"
#import "HCLine.h"


CGFloat distanceBetweenPoints(CGPoint p1, CGPoint p2) {
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

@interface HCFingerDrawingView()
@property (strong, nonatomic) NSMutableArray *allLines;
@property (nonatomic) BOOL currentlyDrawing;
@end

@implementation HCFingerDrawingView 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.allLines = [NSMutableArray new];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
//    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // iterate through all ze lines and draw line.  Draw line good for glory of Russia line.
    for (HCLine *line in self.allLines) {
        [line drawLineWithContext:context];
    }
}

- (void)removeLineAroundPoint:(CGPoint)point {
    NSMutableArray *toRemove = [NSMutableArray array];
    for (HCLine *line in self.allLines) {
        if (distanceBetweenPoints(line.start, point) <= 30
            || distanceBetweenPoints(line.end, point) <= 30)
        {
            [toRemove addObject:line];
        }
    }
    [self.allLines removeObjectsInArray:toRemove];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        // Grab the current point
        UITouch *touch = [touches anyObject];
        CGPoint previousLocation = [touch previousLocationInView:self];
        CGPoint location = [touch locationInView:self];
        
        if (self.mode == HCDrawingModeDraw) {
            self.currentlyDrawing = YES;
            HCLine *l = [HCLine lineWithStartPoint:previousLocation endPoint:location color:self.lineColor width:self.lineWidth];
            [self.allLines addObject:l];
        } else {
            [self removeLineAroundPoint:location];
        }
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        self.currentlyDrawing = NO;
    }
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        self.allLines = [NSMutableArray new];
        [self setNeedsDisplay];
    }
}


@end
