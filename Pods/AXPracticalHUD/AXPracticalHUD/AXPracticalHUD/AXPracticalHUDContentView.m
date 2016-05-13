//
//  AXPracticalHUDContentView.m
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPracticalHUDContentView.h"

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.1
#endif

@interface AXPracticalHUDContentView()
@property(strong, nonatomic) UIView *effectView;
@end

@implementation AXPracticalHUDContentView
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    self.backgroundColor = [UIColor clearColor];
    _translucent = NO;
    _translucentStyle = AXPracticalHUDTranslucentStyleDark;
    _opacity = 0.8f;
}

#pragma mark - Override
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (_translucent) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    } else if (_endColor) {
        // Gradient color
        size_t locationCount = 2;
        CGFloat gradLocations[2] = {0.0, 1.0};
        CGFloat r1 = 0.0;
        CGFloat r2 = 0.0;
        CGFloat g1 = 0.0;
        CGFloat g2 = 0.0;
        CGFloat b1 = 0.0;
        CGFloat b2 = 0.0;
        CGFloat a1 = 0.75;
        CGFloat a2 = 0.0;
        [_color getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
        [_endColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
        CGFloat gradColors[8] = {r1, g1, b1, a1, r2, g2, b2, a2};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, locationCount);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(self.bounds.size.width / 2, self.bounds.size.height), CGPointMake(self.bounds.size.width / 2, 0), kCGGradientDrawsAfterEndLocation);
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    } else {
        if (!_color) {
            CGContextSetGrayFillColor(context, 0.0, _opacity);
        } else {
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        }
        
        CGContextBeginPath(context);
        CGRect rect = self.bounds;
        CGContextMoveToPoint(context, CGRectGetMinX(rect) + 0.0, CGRectGetMinY(rect));
        CGContextAddArc(context, CGRectGetMaxX(rect) - 0.0, CGRectGetMinY(rect) + 0.0, 0.0, 3 * M_PI / 2, 0, 0);
        CGContextAddArc(context, CGRectGetMaxX(rect) - 0.0, CGRectGetMaxY(rect) - 0.0, 0.0, 0, M_PI / 2, 0);
        CGContextAddArc(context, CGRectGetMinX(rect) + 0.0, CGRectGetMaxY(rect) - 0.0, 0.0, M_PI / 2, M_PI, 0);
        CGContextAddArc(context, CGRectGetMinX(rect) + 0.0, CGRectGetMinY(rect) + 0.0, 0.0, M_PI, 3 * M_PI / 2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
    
    UIGraphicsPopContext();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _effectView.frame = self.bounds;
}
#pragma mark - Getters & Setters
- (UIView *)effectView {
    if (_effectView) return _effectView;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _effectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        _effectView = [[UIToolbar alloc] initWithFrame:CGRectZero];
        for (UIView *view in [_effectView subviews]) {
            if ([view isKindOfClass:[UIImageView class]] && [[view subviews] count] == 0) {
                [view setHidden:YES];
            }
        }
        ((UIToolbar *)_effectView).barStyle = UIBarStyleBlack;
        _effectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _effectView;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)setEndColor:(UIColor *)endColor {
    _endColor = endColor;
    [self setNeedsDisplay];
}

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    if (_translucent) {
        [self insertSubview:self.effectView atIndex:0];
    } else {
        [_effectView removeFromSuperview];
    }
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)setTranslucentStyle:(AXPracticalHUDTranslucentStyle)translucentStyle {
    _translucentStyle = translucentStyle;
    if (!_translucent) return;
    
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        if ([_effectView isKindOfClass:[UIVisualEffectView class]]) {
            [_effectView removeFromSuperview];
            switch (translucentStyle) {
                case AXPracticalHUDTranslucentStyleLight:
                    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
                    _effectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    break;
                case AXPracticalHUDTranslucentStyleDark:
                    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                    _effectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    break;
                default:
                    break;
            }
            if (_translucent) {
                [self insertSubview:_effectView atIndex:0];
            }
        }
    } else {
        if ([_effectView isKindOfClass:[UIToolbar class]]) {
            UIToolbar *effect = (UIToolbar *)_effectView;
            switch (translucentStyle) {
                case AXPracticalHUDTranslucentStyleLight:
                    effect.barStyle = UIBarStyleDefault;
                    break;
                case AXPracticalHUDTranslucentStyleDark:
                    effect.barStyle = UIBarStyleBlack;
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)setOpacity:(CGFloat)opacity {
    _opacity = opacity;
    [self setNeedsDisplay];
}
@end