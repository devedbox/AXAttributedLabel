//
//  UIViewController+Title.m
//  AXSwift2OC
//
//  Created by ai on 9/6/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "UIViewController+Title.h"
#import <objc/runtime.h>

@implementation UIViewController (Title)
#pragma mark - Getters
- (AXTitleView *)titleView {
    UIView *view = objc_getAssociatedObject(self, _cmd);
    if (view && [view isKindOfClass:[AXTitleView class]]) {
        return (AXTitleView *)view;
    }
    AXTitleView *titleView = [[AXTitleView alloc] init];
    objc_setAssociatedObject(self, _cmd, titleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return titleView;
}
#pragma mark - Public
- (void)setTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font {
    [self setTitle:title];
    if (color) {
        self.titleView.titleLabel.textColor = color;
        self.titleView.activityIndicator.color = color;
    }
    if (font) self.titleView.titleLabel.font = font;
    self.titleView.titleLabel.text = [self title];
    self.navigationItem.titleView = self.titleView;
}
@end

@implementation AXTitleView

@synthesize titleLabel = _titleLabel;

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    self.backgroundColor   = [UIColor clearColor];
    [self addSubview:self.activityIndicator];
    [self addSubview:self.titleLabel];
}

#pragma mark - Override
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self updatePositions];
    }
}

#pragma mark - Getters

- (UIActivityIndicatorView *)activityIndicator {
    if (_activityIndicator) return _activityIndicator;
    _activityIndicator                  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicator.color            = [UIColor colorWithRed:0.100f green:0.100f blue:0.100f alpha:0.800f];
    _activityIndicator.hidesWhenStopped = YES;
    return _activityIndicator;
}
- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel                 = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font            = [UIFont boldSystemFontOfSize:20.f];
    _titleLabel.textColor       = [UIColor colorWithRed:0.100f green:0.100f blue:0.100f alpha:0.800f];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment   = NSTextAlignmentLeft;
    _titleLabel.numberOfLines   = 1;
    _titleLabel.lineBreakMode   = NSLineBreakByTruncatingTail;
    return _titleLabel;
}

#pragma mark - Setters
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    _titleLabel.text = title;
    [self updatePositions];
}

#pragma mark - Private

- (void)updatePositions {
    [_titleLabel sizeToFit];
    
    CGRect rect_acti = _activityIndicator.frame;
    CGRect rect_label = _titleLabel.frame;
    
    rect_acti.size = CGSizeMake(CGRectGetHeight(rect_label), CGRectGetHeight(rect_label));
    rect_label.origin.x = CGRectGetMaxX(rect_acti)+10;
    rect_label.size.width += CGRectGetWidth(rect_acti)+10;
    
    _activityIndicator.frame = rect_acti;
    _titleLabel.frame = rect_label;
    self.frame = CGRectMake(0, 0, rect_label.origin.x+rect_label.size.width, rect_label.size.height);
}
@end