//
//  CPRefreshControl.m
//  CPRefreshControl
//
//  Created by Can Poyrazoğlu on 24.08.2017.
//  Copyright © 2017 Can Poyrazoğlu. All rights reserved.
//

#import "CPRefreshControl.h"

@interface CPRefreshControl()

@property(nonatomic) float alphaBiasMultiplicationFactor;
@property(readonly, nonatomic) float tickAlphaMultiplierForCurrentState;

@end

@implementation CPRefreshControl{
    BOOL animating;
    BOOL endingAnimation;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    UIImpactFeedbackGenerator *feedbackGenerator;
#pragma clang diagnostic pop
}

-(void)setup{
    if(!self.color){
        self.color = [UIColor grayColor];
    }
    if(!self.tickCount){
        self.tickCount = 12;
    }
    if(!self.animationSpeed){
        self.animationSpeed = 5.2;
    }
    if(!self.tickWidth){
        self.tickWidth = 1.85;
    }
    if(!self.tickLength){
        self.tickLength = 0.45;
    }
    if(!self.animatingTickAlphaBias){
        self.animatingTickAlphaBias = 0.88;
    }
    if(!self.discreteAnimationBeginningScaleAmount){
        self.discreteAnimationBeginningScaleAmount = 1.25;
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
    [self drawInRect:rect withTickCount:self.tickCount withTickColor:self.color withTickWidth:self.tickWidth withTickLength:self.tickLength withValue:self.value withTickAlphaMultiplier:self.tickAlphaMultiplierForCurrentState];
    
}

-(float)tickAlphaMultiplierForCurrentState{
    if(animating){
        return (self.animatingTickAlphaBias * self.alphaBiasMultiplicationFactor) + (1 - self.alphaBiasMultiplicationFactor);
    }else{
        return 1;
    }
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


-(void)drawInRect:(CGRect)rect withTickCount:(int)tickCount withTickColor:(UIColor*)tickColor withTickWidth:(float)width withTickLength:(float)length withValue:(float)value withTickAlphaMultiplier:(float)iterativeAlphaMultiplier{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    UIColor *color = tickColor;
    CGFloat alpha;
    [tickColor getWhite:nil alpha:&alpha];
    CGContextSetLineWidth(ctx, width);
    CGContextStrokePath(ctx);
    for (int i = 0; i < tickCount * value; i++) {
        CGContextSetStrokeColorWithColor(ctx, [color colorWithAlphaComponent:alpha].CGColor);
        alpha *= iterativeAlphaMultiplier;
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

-(void)beginContinuousAnimation{
    //continuous animation
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

-(void)animateToScaleAndBack:(float)scale duration:(float)duration{
    [CATransaction begin];
    CABasicAnimation* scaleAnimation = [CABasicAnimation
                                        animationWithKeyPath:@"transform.scale"];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scaleAnimation.fromValue = @(1);
    scaleAnimation.toValue = @(scale);
    scaleAnimation.duration = duration * 0.3;
    [self.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [CATransaction setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            CABasicAnimation* scaleBackAnimation = [CABasicAnimation
                                                    animationWithKeyPath:@"transform.scale"];
            scaleBackAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            scaleBackAnimation.fromValue = @(scale);
            scaleBackAnimation.toValue = @(1);
            scaleBackAnimation.duration = duration * 0.7;
            [self.layer addAnimation:scaleBackAnimation forKey:@"scaleBackAnimation"];
            [CATransaction setCompletionBlock:^{
                
            }];
            [CATransaction commit];
        });
    }];
    [CATransaction commit];
}

-(void)stepMultiplicationFactor{
    self.alphaBiasMultiplicationFactor += 0.085;
    if(self.alphaBiasMultiplicationFactor > 1){
        self.alphaBiasMultiplicationFactor = 1;
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stepMultiplicationFactor];
        });
        
    }
}

-(void)beginDiscreteAnimation{
    const float rotationAmount = M_PI;
    const float scaleAnimationDuration = 0.3;
    const float rotationAnimationDuration = 0.7;
    self.alphaBiasMultiplicationFactor = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.32 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stepMultiplicationFactor];
    });
    [self animateToScaleAndBack:self.discreteAnimationBeginningScaleAmount duration:scaleAnimationDuration];
    [UIView animateWithDuration:rotationAnimationDuration / 2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformRotate(self.transform, rotationAmount / 2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:rotationAnimationDuration / 2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformRotate(self.transform, rotationAmount / 2);
        } completion:^(BOOL finished) {
            [self stepDiscreteAnimation];
        }];
    }];
    
}

-(void)setAlphaBiasMultiplicationFactor:(float)alphaBiasMultiplicationFactor{
    _alphaBiasMultiplicationFactor = alphaBiasMultiplicationFactor;
    [self setNeedsDisplay];
}

-(void)stepDiscreteAnimation{
    if(!animating){
        return;
    }
    CGAffineTransform xform = CGAffineTransformRotate(self.transform, 2 * M_PI / self.tickCount);
    self.transform = xform;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 / self.animationSpeed * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stepDiscreteAnimation];
    });
}

-(void)beginAnimating{
    if(animating){
        return;
    }
    animating = YES;
    self.alphaBiasMultiplicationFactor = 1;
    _value = 1;
    if(self.shouldAnimateSmoothly){
        //smooth animation
        [self beginContinuousAnimation];
    }else{
        //iOS default "stop motion" effect
        [self beginDiscreteAnimation];
    }
}

-(void)endAnimating{
    if(endingAnimation){
        return;
    }
    endingAnimation = YES;
    [self.layer removeAllAnimations];
    if(!self.shouldSkipEndingAnimation){
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.transform = CGAffineTransformRotate(self.transform, M_PI);
            self.alpha = 0;
        } completion:^(BOOL finished) {
            animating = NO;
            self.value = 0;
            self.alpha = 1;
            self.transform = CGAffineTransformIdentity;
            dispatch_async(dispatch_get_main_queue(), ^{
                endingAnimation = NO;
            });
        }];
    }else{
        animating = NO;
        self.value = 0;
    }
}

-(void)setImpactStyle:(CPRefreshControlImpactStyle)impactStyle{
    feedbackGenerator = nil;
    _impactStyle = impactStyle;
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
        if (@available(iOS 10,*)) {
            if(self.impactStyle != CPRefreshControlImpactStyleNone){
                if(!feedbackGenerator){
                    UIImpactFeedbackStyle feedbackStyle;
                    if(self.impactStyle == CPRefreshControlImpactStyleLight){
                        feedbackStyle = UIImpactFeedbackStyleLight;
                    }else if(self.impactStyle == CPRefreshControlImpactStyleMedium){
                        feedbackStyle = UIImpactFeedbackStyleMedium;
                    }else{
                        feedbackStyle = UIImpactFeedbackStyleHeavy;
                    }
                    feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:feedbackStyle];
                    [feedbackGenerator prepare];
                }
                [feedbackGenerator impactOccurred];
            }
        }
        [self beginAnimating];
    }
}

-(CGSize)intrinsicContentSize{
    return CGSizeMake(30, 30);
}


@end
