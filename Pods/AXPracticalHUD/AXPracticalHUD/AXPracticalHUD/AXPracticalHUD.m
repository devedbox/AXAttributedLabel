//
//  AXPracticalHUD.m
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPracticalHUD.h"

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.1
#endif
#ifndef EXECUTE_ON_MAIN_THREAD
#define EXECUTE_ON_MAIN_THREAD(block) \
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@interface AXPracticalHUD()
{
    BOOL _animated;
    BOOL _isFinished;
    SEL _executedMethod;
    id _executedTarget;
    id _executedObject;
    CGAffineTransform _rotationTransform;
}
@property(strong, nonatomic) NSTimer *graceTimer;
@property(strong, nonatomic) NSTimer *minShowTimer;
@property(strong, nonatomic) NSDate *showStarted;
@property(readonly, nonatomic) CGRect contentFrame;
@property(strong, nonatomic) UILabel *label;
@property(strong, nonatomic) UILabel *detailLabel;
@property(strong, nonatomic) UIView *indicator;
@property(strong, nonatomic) UIInterpolatingMotionEffect *xMotionEffect;
@property(strong, nonatomic) UIInterpolatingMotionEffect *yMotionEffect;
@property(strong, nonatomic) AXPracticalHUDContentView *contentView;
@end

@implementation AXPracticalHUD
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
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

- (instancetype)initWithView:(UIView *)view {
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithWindow:(UIWindow *)window {
    return [self initWithView:window];
}

- (void)initializer {
    _restoreEnabled = NO;
    _lockBackground = NO;
    _size = CGSizeZero;
    _square = NO;
    _margin = kAXPracticalHUDDefaultMargin;
    _offsetX = 0.0f;
    _offsetY = 0.0f;
    _minSize = CGSizeZero;
    _graceTime = 0.0f;
    _animation = AXPracticalHUDAnimationFade;
    _minShowTime = 0.5f;
    _dimBackground = NO;
    _contentInsets = UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f);
    _progressing = NO;
    _opacity = 0.8f;
    _translucent = NO;
    _translucentStyle = AXPracticalHUDTranslucentStyleDark;
    _mode = AXPracticalHUDModeIndeterminate;
    _position = AXPracticalHUDPositionCenter;
    _progress = 0.0f;
    _cornerRadius = 8.0f;
    _removeFromSuperViewOnHide = NO;
    
    _animated = NO;
    _isFinished = NO;
    _rotationTransform = CGAffineTransformIdentity;
    
    self.alpha = 0.0f;
    self.opaque = NO;
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.contentView];
    [_contentView addSubview:self.label];
    [_contentView addSubview:self.detailLabel];
    [self setupIndicators];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
#pragma mark - Override
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        if (_position == AXPracticalHUDPositionCenter) {
            _contentView.motionEffects = @[self.xMotionEffect, self.yMotionEffect];
        } else {
            [_contentView removeMotionEffect:_xMotionEffect];
            [_contentView removeMotionEffect:_yMotionEffect];
        }
        [self updateForCurrentOrientationAnimated:NO];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (_lockBackground) {
        return hitView;
    } else {
        if (CGRectContainsPoint(self.contentFrame, point)) {
            return hitView;
        } else {
            return nil;
        }
    }
    return nil;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (_dimBackground) {
        //Gradient colours
        size_t gradLocNum = 2;
        CGFloat gradLocs[2] = {0.0, 1.0};
        CGFloat gradColors[8] = {0.0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, 0.3};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocs, gradLocNum);
        //Gradient center
        CGPoint gradCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        //Gradient radius
        CGFloat gradRadius = MIN(self.bounds.size.width, self.bounds.size.height);
        //Gradient draw
        CGContextDrawRadialGradient (context, gradient, gradCenter, 0, gradCenter, gradRadius, kCGGradientDrawsAfterEndLocation);
    }
    
    UIGraphicsPopContext();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.superview) {
        self.frame = self.superview.bounds;
    }
    // Get bounds
    CGRect bounds = self.bounds;
    
    CGFloat maxWidth = CGRectGetWidth(bounds) - _contentInsets.left - _contentInsets.right - 2 * _margin;
    
    CGRect rect_indicator = CGRectZero;
    if (_indicator) {
        rect_indicator = _indicator.frame;
    }
    
    CGSize size = [_label.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName : _label.font}
                                            context:nil].size;
    CGRect rect_label = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    
    size = [_detailLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName : _detailLabel.font}
                                           context:nil].size;
    CGRect rect_detail = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    
    CGFloat height_content = rect_indicator.size.height + rect_label.size.height + rect_detail.size.height;
    height_content += _contentInsets.top + _contentInsets.bottom;
    if (rect_label.size.height > 0) {
        height_content += kAXPracticalHUDPadding;
    }
    if (rect_detail.size.height > 0) {
        height_content += kAXPracticalHUDPadding;
    }
    
    CGFloat width_content = 0.0;
    if (_position == AXPracticalHUDPositionTop || _position == AXPracticalHUDPositionBottom) {
        width_content = maxWidth + _contentInsets.left + _contentInsets.right;
    } else {
        width_content = MIN(maxWidth, MAX(rect_indicator.size.width, MAX(rect_label.size.width, rect_detail.size.width))) + _contentInsets.left + _contentInsets.right;
    }
    
    CGSize size_content = CGSizeMake(width_content, height_content);
    
    if (_square) {
        CGFloat maxValue = MAX(width_content, height_content);
        if (maxValue <= (bounds.size.width - 2 * _margin)) {
            size_content.width = maxValue;
        }
        if (maxValue <= (bounds.size.height - 2 * _margin)) {
            size_content.height = maxValue;
        }
    }
    
    if (size_content.width < _minSize.width) {
        size_content.width = _minSize.width;
    }
    if (size_content.height < _minSize.height) {
        size_content.height = _minSize.height;
    }
    
    _size = size_content;
    
    rect_indicator.origin.y = _contentInsets.top;
    rect_indicator.origin.x = round(_size.width - rect_indicator.size.width) / 2;
    _indicator.frame = rect_indicator;
    
    rect_label.origin.y = rect_label.size.height > 0.0 ? CGRectGetMaxY(rect_indicator) + kAXPracticalHUDPadding : CGRectGetMaxY(rect_indicator);
    rect_label.origin.x = round((_size.width - rect_label.size.width) / 2) + _contentInsets.left - _contentInsets.right;
    _label.frame = rect_label;
    
    rect_detail.origin.y = rect_detail.size.height > 0.0 ? CGRectGetMaxY(rect_label) + kAXPracticalHUDPadding : CGRectGetMaxY(rect_label);
    rect_detail.origin.x = round((_size.width - rect_detail.size.width) / 2) + _contentInsets.left - _contentInsets.right;
    _detailLabel.frame = rect_detail;
    
    _contentView.frame = self.contentFrame;
}

#pragma mark - Public
- (void)showAnimated:(BOOL)animated {
    [self showAnimated:animated
        executingBlock:nil
               onQueue:nil
            completion:nil];
}

- (void)hideAnimated:(BOOL)animated {
    [self hideAnimated:animated
            afterDelay:0.0
            completion:nil];
}

- (void)showAnimated:(BOOL)animated executingBlockOnGQ:(dispatch_block_t)executing completion:(AXPracticalHUDCompletionBlock)completion
{
    [self showAnimated:animated
        executingBlock:executing
               onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            completion:completion];
}

- (void)showAnimated:(BOOL)animated executingBlock:(dispatch_block_t)executing onQueue:(dispatch_queue_t)queue completion:(AXPracticalHUDCompletionBlock)completion
{
    void(^showBlock)(BOOL) = ^(BOOL animated) {
        _animated = animated;
        // If the grace time is set postpone the HUD display
        if (_graceTime > 0.0) {
            NSTimer *newGraceTimer = [NSTimer timerWithTimeInterval:_graceTime
                                                             target:self
                                                           selector:@selector(handleGraceTimer:)
                                                           userInfo:nil
                                                            repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:newGraceTimer forMode:NSRunLoopCommonModes];
            _graceTimer = newGraceTimer;
        } else {
            // ... otherwise show the HUD imediately
            [self showingAnimated:animated];
        }
    };
    
    _completion = [completion copy];
    
    if (executing) {
        _progressing = YES;
        dispatch_async(queue, ^{
            executing();
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clear];
            });
        });
    }
    
    EXECUTE_ON_MAIN_THREAD(^{
        showBlock(animated);
    });
}

- (void)showAnimated:(BOOL)animated executingMethod:(SEL)method toTarget:(id)target withObject:(id)object
{
    _executedMethod = method;
    _executedTarget = target;
    _executedObject = object;
    // Launch execution in new thread
    _progressing = YES;
    [NSThread detachNewThreadSelector:@selector(executing) toTarget:self withObject:nil];
    // Show HUD view
    EXECUTE_ON_MAIN_THREAD(^{
        [self showAnimated:YES];
    });
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay completion:(void (^)())completion
{
    void(^hideBlock)(BOOL) = ^(BOOL animated) {
        _animated = animated;
        // If the minShow time is set, calculate how long the hud was shown,
        // and pospone the hiding operation if necessary
        if (_minShowTime > 0.0 && _showStarted) {
            NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:_showStarted];
            if (interv < _minShowTime) {
                _minShowTimer = [NSTimer scheduledTimerWithTimeInterval:_minShowTime - interv
                                                                target:self
                                                              selector:@selector(handleMinShowTimer:)
                                                              userInfo:nil
                                                               repeats:NO];
                return;
            }
        }
        // ... otherwise hide the HUD immediately
        EXECUTE_ON_MAIN_THREAD(^{
            [self hidingAnimated:YES];
        });
    };
    _completion = [completion copy];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hideBlock(animated);
    });
}

#pragma mark - Setters
- (void)setOpacity:(CGFloat)opacity {
    _opacity = opacity;
    EXECUTE_ON_MAIN_THREAD(^{
        _contentView.opacity = opacity;
    });
}

- (void)setColor:(UIColor *)color {
    _color = color;
    EXECUTE_ON_MAIN_THREAD(^{
        _contentView.color = color;
    });
}

- (void)setEndColor:(UIColor *)endColor {
    _endColor = endColor;
    EXECUTE_ON_MAIN_THREAD(^{
        _contentView.endColor = endColor;
    });
}

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    EXECUTE_ON_MAIN_THREAD(^{
        _contentView.translucent = translucent;
    });
}

- (void)setTranslucentStyle:(AXPracticalHUDTranslucentStyle)translucentStyle {
    _translucentStyle = translucentStyle;
    EXECUTE_ON_MAIN_THREAD(^{
        _contentView.translucentStyle = translucentStyle;
    });
}

- (void)setText:(NSString *)text {
    EXECUTE_ON_MAIN_THREAD(^{
        _label.text = text;
    });
}

- (void)setFont:(UIFont *)font {
    EXECUTE_ON_MAIN_THREAD(^{
        _label.font = font;
    });
}

- (void)setMode:(AXPracticalHUDMode)mode {
    _mode = mode;
    EXECUTE_ON_MAIN_THREAD(^{
        [self setupIndicators];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    });
}

- (void)setPosition:(AXPracticalHUDPosition)position {
    _position = position;
    EXECUTE_ON_MAIN_THREAD((^{
        if (_position == AXPracticalHUDPositionCenter) {
            _contentView.motionEffects = @[self.xMotionEffect, self.yMotionEffect];
        } else {
            [_contentView removeMotionEffect:_xMotionEffect];
            [_contentView removeMotionEffect:_yMotionEffect];
        }
        [self setNeedsDisplay];
        [self setNeedsLayout];
    }));
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    EXECUTE_ON_MAIN_THREAD(^{
        if ([_indicator isKindOfClass:[AXBarProgressView class]] || [_indicator isKindOfClass:[AXCircleProgressView class]] || [_indicator isKindOfClass:[AXGradientProgressView class]]) {
            [_indicator setValue:@(_progress) forKey:@"progress"];
        }
    });
}

- (void)setDetailText:(NSString *)detailText {
    _detailLabel.text = detailText;
}

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    EXECUTE_ON_MAIN_THREAD(^{
        [self setupIndicators];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    });
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    EXECUTE_ON_MAIN_THREAD(^{
        _contentView.layer.cornerRadius = _cornerRadius;
        _contentView.layer.masksToBounds = YES;
    });
}

- (void)setDetailTextColor:(UIColor *)detailTextColor {
    EXECUTE_ON_MAIN_THREAD(^{
        _detailLabel.textColor = detailTextColor;
    });
}

- (void)setTextColor:(UIColor *)textColor {
    EXECUTE_ON_MAIN_THREAD(^{
        _label.textColor = textColor;
    });
}

- (void)setDetailFont:(UIFont *)detailFont {
    EXECUTE_ON_MAIN_THREAD(^{
        _detailLabel.font = detailFont;
    });
}

- (void)setActivityIndicatorColor:(UIColor *)activityIndicatorColor {
    _activityIndicatorColor = activityIndicatorColor;
    EXECUTE_ON_MAIN_THREAD(^{
        [self setupIndicators];
        [self setNeedsDisplay];
        [self setNeedsLayout];
    });
}
#pragma mark - Getters
- (NSString *)text {
    return _label.text;
}

- (UIFont *)font {
    return _label.font;
}

- (NSString *)detailText {
    return _detailLabel.text;
}

- (UIColor *)detailTextColor {
    return _detailLabel.textColor;
}

- (UIColor *)textColor {
    return _label.textColor;
}

- (UIFont *)detailFont {
    return _detailLabel.font;
}

- (CGRect)contentFrame {
    switch (_position) {
        case AXPracticalHUDPositionTop:
            return CGRectMake(round((self.bounds.size.width - _size.width) / 2) + _offsetX, 0 + _offsetY, _size.width, _size.height);
            break;
        case AXPracticalHUDPositionCenter:
            return CGRectMake(round((self.bounds.size.width - _size.width) / 2) + _offsetX, round((self.bounds.size.height - _size.height) / 2) + _offsetY, _size.width, _size.height);
            break;
        case AXPracticalHUDPositionBottom:
            if (self.superview) {
                return CGRectMake(round((self.bounds.size.width - _size.width) / 2) + _offsetX, self.superview.bounds.size.height - _size.height + _offsetY, _size.width, _size.height);
            } else {
                return CGRectMake(round((self.bounds.size.width - _size.width) / 2) + _offsetX, round((self.bounds.size.height - _size.height) / 2) + _offsetY, _size.width, _size.height);
            }
            break;
        default:
            return CGRectZero;
            break;
    }
}

- (UILabel *)label {
    if (_label) return _label;
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.adjustsFontSizeToFitWidth = NO;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont boldSystemFontOfSize:kAXPracticalHUDFontSize];
    return _label;
}

- (UILabel *)detailLabel {
    if (_detailLabel) return _detailLabel;
    _detailLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _detailLabel.adjustsFontSizeToFitWidth = NO;
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.opaque = NO;
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.numberOfLines = 0;
    _detailLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    _detailLabel.font = [UIFont boldSystemFontOfSize:kAXPracticalHUDDetailFontSize];
    return _detailLabel;
}

- (UIInterpolatingMotionEffect *)xMotionEffect {
    if (_xMotionEffect) return _xMotionEffect;
    _xMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    _xMotionEffect.minimumRelativeValue = @(-kAXPracticalHUDMaxMovement);
    _xMotionEffect.maximumRelativeValue = @(kAXPracticalHUDMaxMovement);
    return _xMotionEffect;
}

- (UIInterpolatingMotionEffect *)yMotionEffect {
    if (_yMotionEffect) return _yMotionEffect;
    _yMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    _yMotionEffect.minimumRelativeValue = @(-kAXPracticalHUDMaxMovement);
    _yMotionEffect.maximumRelativeValue = @(kAXPracticalHUDMaxMovement);
    return _yMotionEffect;
}

- (AXPracticalHUDContentView *)contentView {
    if (_contentView) return _contentView;
    _contentView = [[AXPracticalHUDContentView alloc] initWithFrame:CGRectZero];
    _contentView.layer.cornerRadius = _cornerRadius;
    _contentView.layer.masksToBounds = true;
    _contentView.opacity = _opacity;
    _contentView.color = _color;
    _contentView.endColor = _endColor;
    _contentView.translucent = _translucent;
    _contentView.translucentStyle = _translucentStyle;
    return _contentView;
}

#pragma mark - Private helper
- (void)showingAnimated:(BOOL)animated {
    // Cancel any scheduled hideDelayed: calls
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setNeedsDisplay];
    [self setNeedsLayout];
    self.showStarted = [NSDate date];
    // Animating
    if (animated) {
        if (_animation == AXPracticalHUDAnimationFlipIn) {
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1.0;
            }];
            CGRect rect = self.contentFrame;
            CGFloat translation = (_position == AXPracticalHUDPositionBottom || _position == AXPracticalHUDPositionCenter) ? self.bounds.size.height : -rect.size.height;
            rect.origin.y = translation;
            _contentView.frame = rect;
            [UIView animateWithDuration:0.5
                                  delay:0.15
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:0.9
                                options:7
                             animations:^{
                                 _contentView.frame = self.contentFrame;
                             } completion:nil];
        } else {
            [UIView animateWithDuration:0.25
                                  delay:0.15
                                options:7
                             animations:^{
                                 self.alpha = 1.0;
                             } completion:nil];
        }
    } else {
        self.alpha = 1.0;
    }
}

- (void)hidingAnimated:(BOOL)animated {
    // Animating
    if (animated && _showStarted) {
        if (_animation == AXPracticalHUDAnimationFlipIn) {
            CGRect rect = self.contentFrame;
            CGFloat translation = (_position == AXPracticalHUDPositionBottom || _position == AXPracticalHUDPositionCenter) ? self.bounds.size.height : -rect.size.height;
            rect.origin.y = translation;
            [UIView animateWithDuration:0.5
                                  delay:0.0
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:0.9
                                options:7
                             animations:^{
                                 _contentView.frame = rect;
                             } completion:^(BOOL finished) {
                                 if (finished) {
                                     _contentView.frame = self.contentFrame;
                                     [self completed];
                                 }
                             }];
        } else {
            self.alpha = .0f;
            [self completed];
        }
        _showStarted = nil;
    }
}

- (void)setupIndicators {
    switch (_mode) {
        case AXPracticalHUDModeIndeterminate:
            if (![_indicator isKindOfClass:[UIActivityIndicatorView class]]) {
                [_indicator removeFromSuperview];
                _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                [_indicator performSelector:@selector(startAnimating) withObject:nil];
                [_contentView addSubview:_indicator];
            }
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000
            if (_activityIndicatorColor) {
                [_indicator setValue:_activityIndicatorColor forKey:@"color"];
            } else {
                [_indicator setValue:[UIColor whiteColor] forKey:@"color"];
            }
#endif
            break;
        case AXPracticalHUDModeDeterminateHorizontalBar:
            [_indicator removeFromSuperview];
            _indicator = [[AXBarProgressView alloc] init];
            [_contentView addSubview:_indicator];
            break;
        case AXPracticalHUDModeDeterminate:
        case AXPracticalHUDModeDeterminateAnnularEnabled:
            if (![_indicator isKindOfClass:[AXCircleProgressView class]]) {
                [_indicator removeFromSuperview];
                _indicator = [[AXCircleProgressView alloc] init];
                [_contentView addSubview:_indicator];
            }
            if (_mode == AXPracticalHUDModeDeterminateAnnularEnabled) {
                [_indicator setValue:@(YES) forKey:@"annularEnabled"];
            }
            break;
        case AXPracticalHUDModeCustomView:
            [_indicator removeFromSuperview];
            _indicator = _customView;
            [_contentView addSubview:_indicator];
            break;
        case AXPracticalHUDModeDeterminateColorfulHorizontalBar:
            [_indicator removeFromSuperview];
            _indicator = [[AXGradientProgressView alloc] init];
            [_indicator setValue:@(2.0) forKey:@"progressHeight"];
            [_contentView addSubview:_indicator];
            break;
        default:
            [_indicator removeFromSuperview];
            _indicator = nil;
            break;
    }
}

- (void)completed {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _isFinished = YES;
    self.alpha = .0;
    if (_removeFromSuperViewOnHide) {
        [self removeFromSuperViewOnHide];
    }
    if (_restoreEnabled) {
        [self restore];
    }
    self.transform = CGAffineTransformIdentity;
    _contentView.transform = CGAffineTransformIdentity;
    if (_completion) {
        EXECUTE_ON_MAIN_THREAD(^{
            _completion();
        });
    }
    if (_delegate && [_delegate respondsToSelector:@selector(HUDDidHidden:)]) {
        [_delegate HUDDidHidden:self];
    }
}

- (void)statusBarOrientationDidChange:(NSNotification *)aNotification {
    
}

- (void)handleGraceTimer:(NSTimer *)sender {
    if (_progressing) {
        [self showingAnimated:_animated];
    }
}

- (void)handleMinShowTimer:(NSTimer *)sender {
    [self hidingAnimated:_animated];
}

- (void)executing {
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Start executing the requested task
        [_executedTarget performSelector:_executedMethod withObject:_executedObject];
#pragma clang diagnostic pop
        // Task completed, update view in main thread (note: view operations should
        // be done only in the main thread
        [self performSelectorOnMainThread:@selector(clear) withObject:nil waitUntilDone:NO];
    }
}

- (void)clear {
    _progressing = NO;
    _executedMethod = nil;
    _executedObject = nil;
    _executedTarget = nil;

    [self hideAnimated:YES];
}

- (void)restore {
    self.text = nil;
    self.detailText = nil;
    [self initializer];
}

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
    
    // Not needed on iOS 8+, compile out when the deployment target allows,
    // to avoid sharedApplication problems on extension targets
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    // Only needed pre iOS 7 when added to a window
    BOOL iOS8OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
    if (iOS8OrLater || ![self.superview isKindOfClass:[UIWindow class]]) return;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat radians = 0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
        else { radians = (CGFloat)M_PI_2; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
        else { radians = 0; }
    }
    _rotationTransform = CGAffineTransformMakeRotation(radians);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
    }
    [self setTransform:_rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
#endif
}
@end

@implementation AXPracticalHUD(Shared)
+ (instancetype)sharedHUD {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)showPieInView:(UIView *)view {
    [self showPieInView:view
                   text:nil
                 detail:nil
          configuration:nil];
}
- (void)showProgressInView:(UIView *)view {
    [self showProgressInView:view
                        text:nil
                      detail:nil
               configuration:nil];
}
- (void)showColorfulProgressInView:(UIView *)view; {
    [self showColorfulProgressInView:view
                                text:nil
                              detail:nil
                       configuration:nil];
}
- (void)showTextInView:(UIView *)view {
    [self showTextInView:view
                    text:nil
                  detail:nil
           configuration:nil];
}
- (void)showSimpleInView:(UIView *)view {
    [self showSimpleInView:view
                      text:nil
                    detail:nil
             configuration:nil];
}
- (void)showErrorInView:(UIView *)view {
    [self showErrorInView:view
                     text:nil
                   detail:nil
            configuration:nil];
}
- (void)showSuccessInView:(UIView *)view {
    [self showSuccessInView:view
                       text:nil
                     detail:nil
              configuration:nil];
}

- (void)showPieInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view animated:YES mode:AXPracticalHUDModeDeterminate text:text detail:detail customView:nil configuration:configuration];
}
- (void)showProgressInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view animated:YES mode:AXPracticalHUDModeDeterminateHorizontalBar text:text detail:detail customView:nil configuration:configuration];
}
- (void)showColorfulProgressInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view animated:YES mode:AXPracticalHUDModeDeterminateColorfulHorizontalBar text:text detail:detail customView:nil configuration:configuration];
}
- (void)showTextInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view animated:YES mode:AXPracticalHUDModeText text:text detail:detail customView:nil configuration:configuration];
}
- (void)showSimpleInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    [self _showInView:view animated:YES mode:AXPracticalHUDModeIndeterminate text:text detail:detail customView:nil configuration:configuration];
}
- (void)showErrorInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AXPracticalHUD.bundle/ax_hud_error"]];
    [self _showInView:view animated:YES mode:AXPracticalHUDModeCustomView text:text detail:detail customView:imageView configuration:configuration];
}
- (void)showSuccessInView:(UIView *)view text:(NSString *)text detail:(NSString *)detail configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AXPracticalHUD.bundle/ax_hud_success"]];
    [self _showInView:view animated:YES mode:AXPracticalHUDModeCustomView text:text detail:detail customView:imageView configuration:configuration];
}

#pragma mark - Private
- (void)_showInView:(UIView *)view animated:(BOOL)animated mode:(AXPracticalHUDMode)mode text:(NSString *)text detail:(NSString *)detail customView:(UIView *)customView configuration:(void(^)(AXPracticalHUD *HUD))configuration
{
    EXECUTE_ON_MAIN_THREAD(^{
        self.mode = mode;
        self.text = text;
        self.customView = customView;
        self.detailText = detail;
        [view addSubview:self];
        if (configuration) {
            configuration(self);
        }
        [self showAnimated:animated];
    });
}
@end

@implementation AXPracticalHUD(Convenence)
+ (instancetype)showHUDInView:(UIView *)view animated:(BOOL)animated {
    AXPracticalHUD *hud = [[AXPracticalHUD alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    [hud showAnimated:YES];
    return hud;
}
+ (BOOL)hideHUDInView:(UIView *)view animated:(BOOL)animated {
    AXPracticalHUD *hud = [self HUDInView:view];
    if (hud) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES];
        return YES;
    }
    return NO;
}
+ (NSInteger)hideAllHUDsInView:(UIView *)view animated:(BOOL)animated {
    NSArray *HUDs = [self HUDsInView:view];
    for (AXPracticalHUD *hud in HUDs) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:animated];
    }
    return HUDs.count;
}
+ (instancetype)HUDInView:(UIView *)view {
    NSEnumerator *subviewEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *hud in subviewEnum) {
        if ([hud isKindOfClass:[AXPracticalHUD class]]) {
            return (AXPracticalHUD *)hud;
        }
    }
    return nil;
}
+ (NSArray *)HUDsInView:(UIView *)view {
    NSMutableArray *HUDs = [NSMutableArray array];
    for (UIView *hud in view.subviews) {
        if ([hud isKindOfClass:[AXPracticalHUD class]]) {
            [HUDs addObject:hud];
        }
    }
    return HUDs;
}
@end