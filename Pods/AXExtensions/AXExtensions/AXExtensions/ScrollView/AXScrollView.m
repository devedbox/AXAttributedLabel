//
//  AXScrollView.m
//  AXExtensions
//
//  Created by ai on 16/3/11.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "AXScrollView.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>

@implementation AXScrollView
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    _maxLoadTimeOfRefresh = 10.f;
    self.refreshFooterEnabled = YES;
    self.refreshHeaderEnabled = YES;
}
#pragma mark - public
- (void)refreshData {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(scrollViewRefreshData:)]) {
        [_refreshDelegate scrollViewRefreshData:self];
    }
    [self performSelector:@selector(endRefreshHeader) withObject:nil afterDelay:_maxLoadTimeOfRefresh];
}

- (void)moreData {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(scrollViewMoreData:)]) {
        [_refreshDelegate scrollViewMoreData:self];
    }
    [self performSelector:@selector(endRefreshFooter) withObject:nil afterDelay:_maxLoadTimeOfRefresh / 2];
}

- (void)endRefreshHeader {
    if (self.mj_header.isRefreshing) {
        [self.mj_header endRefreshing];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)endRefreshFooter {
    if (self.mj_footer.isRefreshing) {
        [self.mj_footer endRefreshing];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setRefreshHeaderEnabled:(BOOL)refreshHeaderEnabled {
    _refreshHeaderEnabled = refreshHeaderEnabled;
    if (_refreshHeaderEnabled) {
        __weak typeof(self) wself = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [wself refreshData];
        }];
        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.f];
        header.stateLabel.font = [UIFont systemFontOfSize:12.f];
        self.mj_header = header;
    } else {
        self.mj_header = nil;
    }
}

- (void)setRefreshFooterEnabled:(BOOL)refreshFooterEnabled {
    _refreshFooterEnabled = refreshFooterEnabled;
    if (_refreshFooterEnabled) {
        __weak typeof(self) wself = self;
        MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [wself moreData];
        }];
        footer.stateLabel.font = [UIFont systemFontOfSize:12.f];
        self.mj_footer = footer;
    } else {
        self.mj_footer = nil;
    }
}
@end

@interface UIScrollView ()
/// Place holder indicator view.
@property(readonly, strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property(readonly, strong, nonatomic) UILabel *placeHolderLabel;
@property(readonly, strong, nonatomic) UIImageView *placeHolderImageView;
@end

@implementation UIScrollView(PlaceHolder)
#pragma mark - Properties
- (NSString *)placeHolderContent {
    return self.placeHolderLabel.text;
}

- (UIFont *)placeHolderFont {
    return self.placeHolderLabel.font;
}

- (UIColor *)placeHolderTextColor {
    return self.placeHolderLabel.textColor;
}

- (CGPoint)placeHolderOffset {
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

- (UIImage *)placeHolderImage {
    return self.placeHolderImageView.image;
}

- (BOOL)indicatorViewEnabled {
    return self.indicatorView.isAnimating;
}

- (void)setIndicatorViewEnabled:(BOOL)indicatorViewEnabled
{
    if (indicatorViewEnabled) {
        self.placeHolderLabel.hidden = YES;
        self.placeHolderImageView.hidden = YES;
        [self insertSubview:self.indicatorView atIndex:0];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:self.placeHolderOffset.x]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:self.placeHolderOffset.y]];
        [self.indicatorView startAnimating];
    } else {
        self.placeHolderImageView.hidden = NO;
        self.placeHolderLabel.hidden = NO;
        [self.indicatorView removeFromSuperview];
    }
}

- (void)setPlaceHolderContent:(NSString *)placeHolderContent {
    if (placeHolderContent && placeHolderContent.length > 0) {
        self.placeHolderLabel.text = placeHolderContent;
        if (self.placeHolderImage != nil) return;
        [self insertSubview:self.placeHolderLabel atIndex:0];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:self.placeHolderOffset.x]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:self.placeHolderOffset.y]];
        [self.placeHolderImageView removeFromSuperview];
        return;
    }
    [self.placeHolderLabel removeFromSuperview];
}

- (void)setPlaceHolderFont:(UIFont *)placeHolderFont {
    self.placeHolderLabel.font = placeHolderFont;
}

- (void)setPlaceHolderTextColor:(UIColor *)placeHolderTextColor {
    self.placeHolderLabel.textColor = placeHolderTextColor;
}

- (void)setPlaceHolderImage:(UIImage *)placeHolderImage {
    if (placeHolderImage) {
        self.placeHolderImageView.image = placeHolderImage;
        if (self.placeHolderContent && self.placeHolderContent.length > 0) {
            [self.placeHolderLabel removeFromSuperview];
        }
        [self insertSubview:self.placeHolderImageView atIndex:0];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:self.placeHolderOffset.x]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHolderImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:self.placeHolderOffset.y]];
        return;
    }
    [self.placeHolderImageView removeFromSuperview];
}

- (void)setPlaceHolderOffset:(CGPoint)placeHolderOffset {
    objc_setAssociatedObject(self, @selector(placeHolderOffset), [NSValue valueWithCGPoint:placeHolderOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeHolderImage != nil) {
        [self removeConstraints:self.constraints];
        [self setPlaceHolderImage:self.placeHolderImage];
    } else {
        if (self.placeHolderContent) {
            [self removeConstraints:self.constraints];
            [self setPlaceHolderContent:self.placeHolderContent];
        }
    }
}

#pragma mark - Private

- (UILabel *)placeHolderLabel {
    UILabel *label = objc_getAssociatedObject(self, _cmd);
    if (!label) {
        label = [[UILabel alloc] initWithFrame:self.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:26];
        label.textAlignment = NSTextAlignmentCenter;
        objc_setAssociatedObject(self, _cmd, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return label;
}

- (UIImageView *)placeHolderImageView {
    UIImageView *imageView = objc_getAssociatedObject(self, _cmd);
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.clipsToBounds = YES;
        imageView.opaque = YES;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        objc_setAssociatedObject(self, _cmd, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return imageView;
}

- (UIActivityIndicatorView *)indicatorView {
    UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, _cmd);
    if (!indicatorView) {
        indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 88.0, 88.0)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicatorView.hidesWhenStopped = YES;
        indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        indicatorView.color = [UIColor grayColor];
        [indicatorView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:88.0]];
        [indicatorView addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:88.0]];
        objc_setAssociatedObject(self, _cmd, indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return indicatorView;
}
@end