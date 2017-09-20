//
//  CPRefreshControl.m
//  CPRefreshControl
//
//  Created by Can Poyrazoğlu on 24.08.2017.
//  Copyright © 2017 Can Poyrazoğlu. All rights reserved.
//

#import "CPRefreshControl.h"

@implementation CPRefreshControl{
    BOOL animating;
}

-(void)setup{
    if(!self.color){
        self.color = [UIColor grayColor];
    }
    if(!self.tickCount){
        self.tickCount = 12;
    }
    if(!self.animationSpeed){
        self.animationSpeed = 6;
    }
    if(!self.tickWidth){
        self.tickWidth = 2;
    }
    if(!self.tickLength){
        self.tickLength = 0.5;
    }
}

-(BOOL)isAnimating{
    return animating;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    rect = CGRectInset(rect, 2, 2);
    [self drawInRect:rect withTickCount:self.tickCount withTickColor:self.color withTickWidth:self.tickWidth withTickLength:self.tickLength withValue:self.value];

}

-(CGPoint)centerInRect:(CGRect)rect{
    float halfWidth = rect.size.width / 2;
    float halfHeight = rect.size.height / 2;
    CGPoint center = CGPointMake(rect.origin.x + halfWidth, rect.origin.y + halfHeight);
    return center;
}

-(CGPoint)pointForTick:(int)tick ofTotalTicks:(int)total inRect:(CGRect)rect withDeltaMultiplier:(float)multiplier{
    float percentage = (float)tick / total;
    float radians = (percentage * 2 * M_PI) - M_PI_2;
    float halfWidth = rect.size.width / 2;
    float halfHeight = rect.size.height / 2;
    CGPoint center = [self centerInRect:rect];
    float xDelta = cosf(radians) * halfWidth;
    float yDelta = sinf(radians) * halfHeight;
    CGPoint target = CGPointMake(center.x + xDelta * multiplier, center.y + yDelta * multiplier);
    return target;
}


-(void)drawInRect:(CGRect)rect withTickCount:(int)tickCount withTickColor:(UIColor*)tickColor withTickWidth:(float)width withTickLength:(float)length withValue:(float)value{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetFillColorWithColor(ctx, tickColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, tickColor.CGColor);
    CGContextSetLineWidth(ctx, width);
    CGContextStrokePath(ctx);
    for (int i = 0; i < tickCount * value; i++) {
        CGPoint startPoint = [self pointForTick:i ofTotalTicks:tickCount inRect:rect withDeltaMultiplier:1 - length];
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
        CGPoint targetPoint = [self pointForTick:i ofTotalTicks:tickCount inRect:rect withDeltaMultiplier:1];
        CGContextAddLineToPoint(ctx, targetPoint.x, targetPoint.y);
        CGContextStrokePath(ctx);
    }
}

-(void)setColor:(UIColor *)color{
    _color = color;
    [self setNeedsDisplay];
}

-(void)setTickWidth:(float)tickWidth{
    _tickWidth = tickWidth;
    [self setNeedsDisplay];
}

-(void)setTickCount:(int)tickCount{
    _tickCount = tickCount;
    [self setNeedsDisplay];
}

-(void)setTickLength:(float)tickLength{
    _tickLength = tickLength;
    [self setNeedsDisplay];
}

-(void)beginAnimating{
    if(animating){
        return;
    }
    animating = YES;
    _value = 1;
    [CATransaction begin];
    //we use CoreAnimation or we can't do full rotation animation multiple times
    CABasicAnimation* rotationAnimation = [CABasicAnimation
                                           animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0 :0.01 :0.99 :1];
    rotationAnimation.toValue = [NSNumber numberWithFloat:3 * self.animationSpeed * (2* M_PI)];
    rotationAnimation.duration = 60;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [CATransaction commit];
}

-(void)endAnimating{
    [self.layer removeAllAnimations];
    if(!self.shouldSkipEndingAnimation){
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.alpha = 0;
        } completion:^(BOOL finished) {
            animating = NO;
            self.value = 0;
            self.alpha = 1;
            self.transform = CGAffineTransformIdentity;
        }];
    }else{
        animating = NO;
        self.value = 0;
    }
}

-(void)setValue:(float)value{
    if(animating){
        return;
    }
    [self.layer removeAllAnimations];
    BOOL shouldAnimate = _value < 1 && value >= 1;
    _value = value;
    [self setNeedsDisplay];
    if(shouldAnimate){
        [self beginAnimating];
    }
}


@end
