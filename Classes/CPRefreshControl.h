//
//  CPRefreshControl.h
//  CPRefreshControl
//
//  Created by Can Poyrazoğlu on 24.08.2017.
//  Copyright © 2017 Can Poyrazoğlu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CPRefreshControlAction)(void);

IB_DESIGNABLE
@interface CPRefreshControl : UIView

/// Color of each tick. Default is gray.
@property(nonatomic) IBInspectable UIColor *color;

/// Number of ticks visible in the refresh control. Default is 12.
@property(nonatomic) IBInspectable int tickCount;

/// Speed of the animation. Default is 6.
@property IBInspectable float animationSpeed;

/// Value of the control. 0 means not pulled at all (hidden), and 1 means fully visible to start animating. Set this to 1 calls `beginAnimating`, and any value changes will be ignored until `endAnimating` is called.
@property(nonatomic) IBInspectable float value;

/// Width of a single tick. Default is 2.
@property(nonatomic) IBInspectable float tickWidth;

/// Length multiplier of the ticks. 0 means no length (hidden), 1 means full circle (from circle to edge). Default is 0.5.
@property(nonatomic) IBInspectable float tickLength;

/// Begins animating the control. Call `endAnimating` to stop animation. Any value changes while animating will be ignored.
-(void)beginAnimating;
-(void)endAnimating;

/// Whether the control is currently animating or not.
@property(nonatomic, readonly) BOOL isAnimating;

/// Determines whether the animation should end immediately or with a smooth scale down animation
@property IBInspectable BOOL shouldSkipEndingAnimation;

/// Determines whether the control should perform the rotation animation smoothly (continuous rotation) instead of the default "stop motion" rotation behavior.
@property IBInspectable BOOL shouldAnimateSmoothly;

/// The alpha multiplier applied to each tick's color (based on previous tick's color) when animating. Default is 0.85, meaning each consequent tick's alpha is multiplied by 0.85 of previous tick when animating. Set to 1 to disable color fade effect on consequent ticks.
@property IBInspectable float animatingTickAlphaBias;

@end
