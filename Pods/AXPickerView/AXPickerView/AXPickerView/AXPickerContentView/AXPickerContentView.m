//
//  AXPickerContentView.m
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

#import "AXPickerContentView.h"

#ifndef kAXPickerContentViewHorizontalBeyonds
#define kAXPickerContentViewHorizontalBeyonds 10
#endif
#ifndef kAXPickerContentViewDefaultAlpha
#define kAXPickerContentViewDefaultAlpha 0.3
#endif
#ifndef kAXPickerContentViewHeavyAlpha
#define kAXPickerContentViewHeavyAlpha 0.8
#endif

@interface AXPickerContentView()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AXPickerCollectionViewCellDelegate>
{
    /// Offset
    CGFloat _alpha;
    CGFloat _velocity;
    NSIndexPath *_selectedIndexPath;
}
/// Colloection content view
@property(strong, nonatomic) UICollectionView *collectionView;
@end

NSString *const kAXPickerContentViewReuseIdentifier = @"ax_picker_content_view_reuse_identifier";

@implementation AXPickerContentView
#pragma mark - Initializer
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
    _alpha = kAXPickerContentViewDefaultAlpha;
    _velocity = 1.0;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.collectionView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

- (void)iniatialProperties {
    _contentInsets = UIEdgeInsetsZero;
}

#pragma mark - Override
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Get current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    // Set fill color
    CGContextSetGrayFillColor(context, 0.0, _alpha * _velocity);
    CGContextBeginPath(context);
    CGRect rect_self = self.bounds;
    CGContextMoveToPoint(context, CGRectGetMinX(rect_self) + 0.0, CGRectGetMinY(rect_self));
    CGContextAddArc(context, CGRectGetMaxX(rect_self) - 0.0, CGRectGetMinY(rect_self) + 0.0, 0.0, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect_self) - 0.0, CGRectGetMaxY(rect_self) - 0.0, 0.0, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect_self) + 0.0, CGRectGetMaxY(rect_self) - 0.0, 0.0, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect_self) + 0.0, CGRectGetMinY(rect_self) + 0.0, 0.0, M_PI, 3 * M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    UIGraphicsPopContext();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Get initial frame info of views
    CGRect rect_view = _collectionView.frame;
    // Calculate with hidden
    if (_collectionView.hidden) {
    } else {
        // Calculate size and origin of content view
        rect_view.size.width = CGRectGetWidth(self.bounds) - (_contentInsets.left + _contentInsets.right);
        rect_view.size.height = CGRectGetWidth(self.bounds) - (_contentInsets.top + _contentInsets.bottom);
        rect_view.origin.x = _contentInsets.left;
        rect_view.origin.y = _contentInsets.top;
    }
    // Set the newest calculated origin and size to the views
    _collectionView.frame = rect_view;
    _collectionView.contentSize = CGSizeMake(rect_view.size.width + kAXPickerContentViewHorizontalBeyonds * 2.0, rect_view.size.height);
}

#pragma mark - Getters
- (UIView *)contentView {
    return _collectionView;
}

- (NSString *)registeredIdentifier {
    return kAXPickerContentViewReuseIdentifier;
}

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    AXCollectionViewFlowLayout *layout = [[AXCollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.clipsToBounds = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[AXPickerCollectionViewCell class] forCellWithReuseIdentifier:kAXPickerContentViewReuseIdentifier];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    return _collectionView;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.bounds.size;
    return CGSizeMake(size.width - (_contentInsets.left + _contentInsets.right), size.width - (_contentInsets.top + _contentInsets.bottom));
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger num = [_dataSource ax_collectionView:collectionView numberOfItemsInSection:section];
    if (num == 0) {
        collectionView.hidden = YES;
    } else {
        collectionView.hidden = NO;
    }
    return num;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AXPickerCollectionViewCell *cell = [_dataSource ax_collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
#pragma mark - Private helper
- (CGSize)proposedSizeOfImageWithImageSize:(CGSize)imageSize boundsOfImageView:(CGRect)bounds {
    CGSize size = imageSize;
    if (size.width > bounds.size.width) {
        CGFloat delta = bounds.size.width / size.width;
        size = CGSizeMake(bounds.size.width, size.height * delta);
    }
    return size;
}

#pragma mark - Actions
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    if (!_collectionView.hidden) {
        CGPoint location = [tap locationInView:self];
        if (!CGRectContainsPoint(_collectionView.frame, location)) {
            if (_delegate && [_delegate respondsToSelector:@selector(contentViewDidTouchBackground:)]) {
                [_delegate contentViewDidTouchBackground:self];
            }
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(contentViewDidTouchBackground:)]) {
            [_delegate contentViewDidTouchBackground:self];
        }
    }
}

- (void)reloadData {
    [_collectionView reloadData];
}

- (void)selectIndexPath:(NSIndexPath *)indexPath {
    _selectedIndexPath = indexPath;
}

#pragma mark - AXPickerCollectionViewCellDelegate
- (void)collectionViewCellDidBeginDraging:(AXPickerCollectionViewCell *)cell {
    _alpha = 0.8;
}

- (void)collectionViewCell:(AXPickerCollectionViewCell *)cell didMoveToPoint:(CGPoint)location {
    cell.imageView.transform = CGAffineTransformMakeTranslation(location.x, location.y);
    // Get the proposed size of image in the window
    CGSize size = [self proposedSizeOfImageWithImageSize:cell.imageView.image.size boundsOfImageView:cell.imageView.bounds];
    // Moved instance
    CGFloat xVelocity = 1.0 - (ABS(location.x) / size.width);
    CGFloat yVelocity = 1.0 - (ABS(location.y) / size.height);
    _velocity = MIN(xVelocity, yVelocity);
    [self setNeedsDisplay];
}

- (void)collectionViewCellDidStopDraging:(AXPickerCollectionViewCell *)cell {
    _alpha = kAXPickerContentViewDefaultAlpha;
    CGAffineTransform transfrom = cell.imageView.transform;
    CGSize size = [self proposedSizeOfImageWithImageSize:cell.imageView.image.size boundsOfImageView:cell.imageView.bounds];
    CGRect bounds = cell.imageView.bounds;
    if (ABS(transfrom.tx) > size.width / 2 || (transfrom.ty < 0 ? -transfrom.ty > size.height / 2 : transfrom.ty > (size.height / 2 + bounds.size.height - size.height))) {
        if (_delegate && [_delegate respondsToSelector:@selector(contentViewDidReachLimitedVelocity:)]) {
            [_delegate contentViewDidReachLimitedVelocity:self];
        }
        if (transfrom.ty > 0) {
            if ((transfrom.ty - (bounds.size.height - size.height)) / ABS(transfrom.tx) > size.height / size.width) {
                transfrom.ty = bounds.size.height;
            } else {
                if (transfrom.tx > 0) {
                    transfrom.tx = bounds.size.width;
                } else {
                    transfrom.tx = -bounds.size.width;
                }
            }
        } else {
            if (ABS(transfrom.ty) / ABS(transfrom.tx) > size.height / size.width) {
                transfrom.ty = -bounds.size.height;
            } else {
                if (transfrom.tx > 0) {
                    transfrom.tx = bounds.size.width;
                } else {
                    transfrom.tx = -bounds.size.width;
                }
            }
        }
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:0.9
                            options:7.0
                         animations:^{
                             cell.imageView.transform = transfrom;
                         } completion:nil];
    } else if (!CGAffineTransformIsIdentity(cell.imageView.transform)) {
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.7
                            options:7.0
                         animations:^{
                             cell.imageView.transform = CGAffineTransformIdentity;
                             if (_velocity != 1.0) {
                                 _velocity = 1.0;
                                 [self setNeedsDisplay];
                             }
                         } completion:nil];
    }
}
@end