//
//  AXPhotoCollectionViewCell.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPhotoCollectionViewCell.h"
#import <AXExtensions/UIImage+TintColor.h>

@interface AXPhotoCollectionViewCell()
@property(strong, nonatomic) UIImageView *markView;
@property(strong, nonatomic) UIView *background;
@end

@implementation AXPhotoCollectionViewCell
#pragma mark - Life cycel
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
    [self.contentView addSubview:self.photoView];
//    [self.contentView addSubview:self.selectedLabel];
    [self.contentView addSubview:self.background];
}
#pragma mark - Override
- (void)prepareForReuse {
    [super prepareForReuse];
    
    _photoView.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _photoView.frame = self.contentView.bounds;
    _selectedLabel.frame = _photoView.bounds;
    CGRect rect_mark = _markView.frame;
    rect_mark.origin.x = (CGRectGetWidth(_photoView.frame) - CGRectGetWidth(rect_mark))/2;
    rect_mark.origin.y = (CGRectGetHeight(_photoView.frame) - CGRectGetHeight(rect_mark))/2;
    _markView.frame = rect_mark;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
//    _selectedLabel.hidden = !selected;
    _background.hidden = !selected;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    _markView.image = [_markView.image tintImageWithColor:tintColor];
}

#pragma mark - Getters
- (UILabel *)selectedLabel {
    if (_selectedLabel) return _selectedLabel;
    _selectedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _selectedLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _selectedLabel.font = [UIFont systemFontOfSize:12];
    _selectedLabel.textColor = [UIColor colorWithRed:0.294 green:0.808 blue:0.478 alpha:1.000];
    _selectedLabel.textAlignment = NSTextAlignmentCenter;
    _selectedLabel.text = @"已选择";
    [_selectedLabel sizeToFit];
    _selectedLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    _selectedLabel.hidden = YES;
    return _selectedLabel;
}

- (UIImageView *)photoView {
    if (_photoView) return _photoView;
    _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _photoView.backgroundColor = [UIColor clearColor];
    _photoView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    _photoView.clipsToBounds = YES;
    return _photoView;
}
- (UIImageView *)markView {
    if (_markView) return _markView;
    _markView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AXImagePickerController.bundle/mark"]];
    _markView.clipsToBounds = YES;
    _markView.contentMode = UIViewContentModeScaleAspectFill;
    _markView.backgroundColor = [UIColor clearColor];
    _markView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [_markView sizeToFit];
    return _markView;
}

- (UIView *)background {
    if (_background) return _background;
    _background = [[UIView alloc] initWithFrame:self.contentView.bounds];
    _background.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_background addSubview:self.markView];
    _background.hidden = YES;
    return _background;
}
@end