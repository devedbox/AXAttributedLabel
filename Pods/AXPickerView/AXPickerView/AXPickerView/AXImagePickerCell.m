//
//  AXImagePickerCell.m
//  AXPickerView
//
//  Created by xing Ai on 9/6/15.
//  Copyright (c) 2015 xing Ai. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "AXImagePickerCell.h"
#import <AXExtensions/UIImage+TintColor.h>

@interface AXImagePickerCell()
@property(strong, nonatomic) UIImageView *markView;
@property(strong, nonatomic) UIView *background;
@end

@implementation AXImagePickerCell
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

- (void)initializer {
    [self.contentView addSubview:self.imageView];
    /// Note: property `label` is deprecated sence version 1.0.2
//    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.background];
}

#pragma mark - Getters
- (UILabel *)label {
    if (_label) return _label;
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.font = [UIFont systemFontOfSize:12];
    _label.textColor = [UIColor colorWithRed:0.294 green:0.808 blue:0.478 alpha:1.000];
    _label.text = @"已选择";
    [_label sizeToFit];
    _label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _label.hidden = YES;
    return _label;
}

- (UIImageView *)imageView {
    if (_imageView) return _imageView;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.backgroundColor = [UIColor clearColor];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    return _imageView;
}

- (UIImageView *)markView {
    if (_markView) return _markView;
    _markView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"AXPickerView.bundle/mark"] tintImageWithColor:[UIColor colorWithWhite:0 alpha:0.6]]];
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
#pragma mark - Override
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    _background.hidden = !selected;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _imageView.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.contentView.bounds;
    CGRect rect = _label.frame;
    rect.origin.x = (_imageView.bounds.size.width - rect.size.width) / 2;
    rect.origin.y = (_imageView.bounds.size.height - rect.size.height) / 2;
    _label.frame = rect;
    CGRect rect_mark = _markView.frame;
    rect_mark.origin.x = (CGRectGetWidth(_imageView.frame) - CGRectGetWidth(rect_mark))/2;
    rect_mark.origin.y = (CGRectGetHeight(_imageView.frame) - CGRectGetHeight(rect_mark))/2;
    _markView.frame = rect_mark;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
}
@end