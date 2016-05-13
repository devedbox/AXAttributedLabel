//
//  AXGradientProgressView.m
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXGradientProgressView.h"

@interface AXGradientProgressView()
@property(strong, nonatomic) CAGradientLayer *gradientLayer;
@end

@implementation AXGradientProgressView
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1.0)]) {
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
    _progress = 0.0;
    _progressHeight = 1.0;
    _colors = [[self class] defaultColors];
    _duration = 0.08;
    
    [self.layer addSublayer:self.gradientLayer];
}
#pragma mark - Override
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview) {
        [self performAnimation];
    } else {
        [_gradientLayer removeAnimationForKey:@"colors"];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize aSize = [super sizeThatFits:size];
    aSize.height = _progressHeight;
    return aSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self sizeToFit];
    
    CGRect rect = _gradientLayer.frame;
    rect.size.width = self.bounds.size.width * MIN(_progress, 1.0);
    rect.size.height = self.bounds.size.height;
    _gradientLayer.frame = rect;
}
#pragma mark - Getters & Setters
- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer) return _gradientLayer;
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.startPoint = CGPointMake(0.0, _progressHeight / 2.0);
    _gradientLayer.endPoint = CGPointMake(1.0, _progressHeight / 2.0);
    _gradientLayer.colors = _colors;
    return _gradientLayer;
}

- (void)setColors:(NSMutableArray *)colors {
    _colors = colors;
    _gradientLayer.colors = _colors;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setProgressHeight:(CGFloat)progressHeight {
    _progressHeight = progressHeight;
    _gradientLayer.startPoint = CGPointMake(0.0, _progressHeight / 2.0);
    _gradientLayer.endPoint = CGPointMake(1.0, _progressHeight / 2.0);
}
#pragma mark - Private helper
- (void)performAnimation {
    CGColorRef color = (__bridge CGColorRef)([_colors lastObject]);
    [_colors removeLastObject];
    [_colors insertObject:(__bridge id)(color) atIndex:0];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    animation.toValue = _colors;
    animation.duration = _duration;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [_gradientLayer addAnimation:animation forKey:@"colors"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self performSelectorOnMainThread:@selector(performAnimation) withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
    }
}

+ (NSMutableArray *)defaultColors {
    NSMutableArray *colors = [NSMutableArray array];
    NSInteger hue = 0;
    while (hue <= 360) {
        UIColor *color = [[UIColor alloc] initWithHue:1.0 * hue / 360.0 saturation:1.0 brightness:1.0 alpha:1.0];
        [colors addObject:(__bridge id)(color.CGColor)];
        hue += 1;
    }
    return colors;
}
@end
