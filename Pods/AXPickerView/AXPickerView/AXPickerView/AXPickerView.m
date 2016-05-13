//
//  AXPickerView.m
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

#import <objc/runtime.h>
#import "AXPickerView.h"
#import "AXImagePickerCell.h"
#import "AXPickerViewConstants.h"
#import <AXExtensions/AXScrollView.h>
#import <AXExtensions/PHAsset+Image.h>
#import <AXExtensions/ALAsset+Image.h>
#import <AXPracticalHUD/AXPracticalHUD.h>
#import <AXExtensions/UIToolbar+Separator_hidden.h>
#import <AXExtensions/UIImagePickerController+Authorization.h>

@interface AXPickerView ()<AXPickerContentViewDelegate, AXPickerContentViewDataSource>
/// Title label.
@property(strong, nonatomic) UILabel *titleLabel;
/// Complete button.
@property(strong, nonatomic) UIButton *completeBtn;
/// Cancel button.
@property(strong, nonatomic) UIButton *cancelBtn;
/// Date picker view.
@property(strong, nonatomic) UIDatePicker *datePicker;
/// Common picker view.
@property(strong, nonatomic) UIPickerView *commonPicker;
/// Background view.
@property(strong, nonatomic) AXPickerContentView *backgroundView;
/// Blur effect tool bar.
@property(strong, nonatomic) UIToolbar *effectBar;
/// Blur effect view.
@property(strong, nonatomic) UIVisualEffectView *effectView;
/// Completion call back block.
@property(copy, nonatomic) AXPickerViewCompletion completion;
/// Image picker view completion call back block.
@property(copy, nonatomic) AXImagePickerCompletion imagePickerCompletion;
/// Recoking call back block.
@property(copy, nonatomic) AXPickerViewRevoking revoking;
/// Executing call bacl block.
@property(copy, nonatomic) AXPickerViewExecuting executing;
@end

@interface AXLayer: CALayer
@property (assign, nonatomic) NSInteger tag;
@end

@implementation AXLayer
- (void)setTag:(NSInteger)tag {
    objc_setAssociatedObject(self,
                             @selector(tag),
                             [NSNumber numberWithInteger:tag],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tag {
    NSNumber *tagValue = objc_getAssociatedObject(self, _cmd);
    return tagValue ? [tagValue integerValue] : -1;
}
@end

@implementation AXPickerView
#pragma mark - Life_cycle
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

- (instancetype)initWithStyle:(AXPickerViewStyle)style items:(NSArray *)items {
    if (self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)]) {
        [self initializer];
        _style = style;
        _items = [items copy];
        if (style == AXPickerViewStyleNormal) {
            _separatorInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        } else {
            _separatorInsets = UIEdgeInsetsZero;
        }
    }
    return self;
}

- (void)initializer {
    _style = AXPickerViewStyleNormal;
    _titleFont = [UIFont systemFontOfSize:14];
    _titleTextColor = [kAXDefaultTintColor colorWithAlphaComponent:0.5];
    _cancelFont = [UIFont systemFontOfSize:16];
    _cancelTextColor = [UIColor colorWithRed:0.973 green:0.271 blue:0.231 alpha:1.00];
    _completeFont = [UIFont systemFontOfSize:16];
    _completeTextColor = kAXDefaultSelectedColor;
    _itemFont = [UIFont systemFontOfSize:18];
    _itemConfigs = [NSArray array];
    _separatorColor = kAXDefaultSeparatorColor;
    _separatorInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    _separatorConfigs = @[[AXPickerViewSeparatorConfiguration configurationWithHeight:0.7 insets:UIEdgeInsetsZero color:nil atIndex:0]];
    _customViewInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    _removeFromSuperViewOnHide = YES;
    _scaleBackgroundView = YES;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = kAXDefaultTintColor;
    
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        [self addSubview:self.effectView];
    } else {
        [self addSubview:self.effectBar];
    }
    
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizingCustomView) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Override
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_customView) {
        [self configureCustomView];
        [self addSubview:_customView];
    }
    
    switch (_style) {
        case AXPickerViewStyleNormal:
        {
            NSString *title = self.title;
            if (title && [title length] > 0) {
                [self addSubview:self.titleLabel];
            } else {
                [_titleLabel removeFromSuperview];
            }
            
            NSArray *buttons = [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                if ([evaluatedObject isKindOfClass:[UIButton class]] && [[evaluatedObject valueForKey:@"tag"] integerValue] != 1001 && [[evaluatedObject valueForKey:@"tag"] integerValue] != 1002) {
                    return YES;
                } else {
                    return NO;
                }
            }]];
            
            for (UIButton *button in buttons) {
                [button removeFromSuperview];
            }

            NSInteger count = _items.count;
            for (NSInteger i = 0; i < count; i ++) {
                [self addSubview:[self buttonWithTitle:_items[i] rightHeight:kAXPickerToolBarHeight atIndex:i]];
            }
            
            if (_cancelBtn) {
                _cancelBtn.backgroundColor = [UIColor clearColor];
                [_cancelBtn setBackgroundImage:[self tintImage:[UIImage imageNamed:@"AXPickerView.bundle/ax_button"] WithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            }
        }
            break;
        case AXPickerViewStyleDatePicker:
        {
            [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[AXLayer class]]) {
                    if ([obj valueForKey:@"tag"] > 0) {
                        *stop = YES;
                        [obj removeFromSuperlayer];
                    }
                }
            }];
            // Add custom view
            if (_customView) {
                CGRect rect = self.datePicker.frame;
                rect.origin.y = kAXPickerToolBarHeight + _customView.bounds.size.height + _customViewInsets.top + _customViewInsets.bottom;
                _datePicker.frame = rect;
            } else {
                CGRect rect = self.datePicker.frame;
                rect.origin.y = kAXPickerToolBarHeight;
                _datePicker.frame = rect;
                [self.layer addSublayer:[self separatorWithHeight:1 color:_separatorColor ? _separatorColor : kAXDefaultSeparatorColor insets:_separatorInsets atIndex:1]];
            }
            // Added to view
            [self addSubview:_datePicker];
            [self addSubview:_titleLabel];
            
            if (_cancelBtn) {
                [_cancelBtn setBackgroundColor:kAXDefaultBackgroundColor];
                [_cancelBtn setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }
            break;
        case AXPickerViewStyleCommonPicker:
        {
            [self.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[AXLayer class]]) {
                    if ([obj valueForKey:@"tag"] > 0) {
                        *stop = YES;
                        [obj removeFromSuperlayer];
                    }
                }
            }];
            // Add custom view
            if (_customView) {
                CGRect rect = self.commonPicker.frame;
                rect.origin.y = kAXPickerToolBarHeight + _customView.bounds.size.height + _customViewInsets.top + _customViewInsets.bottom;
                _commonPicker.frame = rect;
            } else {
                CGRect rect = self.commonPicker.frame;
                rect.origin.y = kAXPickerToolBarHeight;
                _commonPicker.frame = rect;
                [self.layer addSublayer:[self separatorWithHeight:1 color:_separatorColor ? _separatorColor : kAXDefaultSeparatorColor insets:_separatorInsets atIndex:1]];
            }
            // Added to view
            [self addSubview:_commonPicker];
            [self addSubview:_titleLabel];
            
            if (_cancelBtn) {
                [_cancelBtn setBackgroundColor:kAXDefaultBackgroundColor];
                [_cancelBtn setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }
            break;
        default:
            break;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize susize = [super sizeThatFits:size];
    susize.width = [UIScreen mainScreen].applicationFrame.size.width;
    
    switch (_style) {
        case AXPickerViewStyleNormal:
        {
            CGFloat height = kAXPickerToolBarHeight;
            NSString *title = self.title;
            if (title && title.length > 0) {
                height += kAXPickerToolBarHeight;
            }
            if (_items && _items.count > 0) {
                height += kAXPickerToolBarHeight * _items.count;
            }
            height += kPadding;
            susize.height = height;
        }
            break;
        case AXPickerViewStyleDatePicker:
        case AXPickerViewStyleCommonPicker:
            susize.height = kAXPickerToolBarHeight + kAXPickerHeight;
            break;
        default:
            break;
    }
    
    if (_customView) {
        susize.height += _customView.bounds.size.height + _customViewInsets.top + _customViewInsets.bottom;
    }
    
    return susize;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        _backgroundView.frame = newSuperview.bounds;
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!self.superview) return;
    
    [self resizingSelfAnimated:NO];
    [self configureTools];
    
    switch (_style) {
        case AXPickerViewStyleNormal:
            if (_items && _items.count > 0) {
                [self addSubview:self.cancelBtn];
            }
            break;
        case AXPickerViewStyleDatePicker:
        case AXPickerViewStyleCommonPicker:
            [self addSubview:self.cancelBtn];
            [self addSubview:self.completeBtn];
            break;
        default:
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        CGRect rect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            _effectView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        } else {
            _effectBar.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
        }
    }
}
#pragma mark - Getters&Setters
- (void)setItems:(NSArray *)items {
    _items = [items copy];
    [self setNeedsDisplay];
    [self resizingSelfAnimated:NO];
}

- (void)setStyle:(AXPickerViewStyle)style {
    _style = style;
    if (_style == AXPickerViewStyleNormal) {
        _separatorInsets = UIEdgeInsetsMake(0, 20, 0, 20);
    } else {
        _separatorInsets = UIEdgeInsetsZero;
    }
}

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    [self setNeedsDisplay];
    [self resizingSelfAnimated:NO];
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self setNeedsDisplay];
    [self configureTools];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    _titleLabel.textColor = titleTextColor;
}

- (void)setCancelFont:(UIFont *)cancelFont {
    _cancelFont = cancelFont;
    _cancelBtn.titleLabel.font = cancelFont;
}

- (void)setCancelTextColor:(UIColor *)cancelTextColor {
    _cancelTextColor = cancelTextColor;
    [_cancelBtn setTintColor:cancelTextColor];
}

- (void)setCompleteFont:(UIFont *)completeFont {
    _completeFont = completeFont;
    _completeBtn.titleLabel.font = completeFont;
}

- (void)setCompleteTextColor:(UIColor *)completeTextColor {
    _completeTextColor = completeTextColor;
    _completeBtn.tintColor = completeTextColor;
}

- (void)setItemFont:(UIFont *)itemFont {
    _itemFont = itemFont;
    [self configureViews];
}

- (void)setItemTintColor:(UIColor *)itemTintColor {
    _itemTintColor = itemTintColor;
    [self configureViews];
}

- (void)setItemConfigs:(NSArray *)itemConfigs {
    _itemConfigs = [itemConfigs copy];
    [self configureViews];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    [self configureViews];
}

- (void)setSeparatorInsets:(UIEdgeInsets)separatorInsets {
    _separatorInsets = separatorInsets;
    [self configureViews];
}

- (void)setSeparatorConfigs:(NSArray *)separatorConfigs {
    _separatorConfigs = [separatorConfigs copy];
    [self configureViews];
}

- (void)setCustomViewInsets:(UIEdgeInsets)customViewInsets {
    _customViewInsets = customViewInsets;
    [self setNeedsDisplay];
}

- (void)setDelegate:(id<AXPickerViewDelegate>)delegate {
    _delegate = delegate;
    if (_style == AXPickerViewStyleCommonPicker) {
        _commonPicker.delegate = delegate;
    }
}

- (void)setDataSource:(id<AXPickerViewDataSource>)dataSource {
    _dataSource = dataSource;
    if (_style == AXPickerViewStyleCommonPicker) {
        _commonPicker.dataSource = dataSource;
    }
}

- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAXPickerToolBarHeight * 2.0, kAXPickerToolBarHeight)];
    _titleLabel.font = _titleFont;
    _titleLabel.textColor = _titleTextColor;
    _titleLabel.backgroundColor = kAXDefaultBackgroundColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 1;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    return _titleLabel;
}

- (UIButton *)completeBtn {
    if (_completeBtn) return _completeBtn;
    _completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _completeBtn.backgroundColor = kAXDefaultBackgroundColor;
    _completeBtn.tintColor = _completeTextColor;
    _completeBtn.titleLabel.font = _completeFont;
    [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_completeBtn addTarget:self action:@selector(didConfirm:) forControlEvents:UIControlEventTouchUpInside];
    _completeBtn.tag = 1001;
    return _completeBtn;
}

- (UIButton *)cancelBtn {
    if (_cancelBtn) return _cancelBtn;
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _cancelBtn.backgroundColor = kAXDefaultBackgroundColor;
    _cancelBtn.tintColor = _cancelTextColor;
    _cancelBtn.titleLabel.font = _cancelFont;
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(didCancel:) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.tag = 1002;
    return _cancelBtn;
}

- (UIDatePicker *)datePicker {
    if (_datePicker) return _datePicker;
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, kAXPickerToolBarHeight, self.bounds.size.width, kAXPickerHeight)];
    _datePicker.backgroundColor = kAXDefaultBackgroundColor;
    _datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT+8"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSDate *minDate = [dateFormat dateFromString:@"1900-01-01 00:00:00"];
    _datePicker.minimumDate = minDate;
    _datePicker.maximumDate = [NSDate date];
    [_datePicker setDate:[NSDate date] animated:YES];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    return _datePicker;
}

- (UIPickerView *)commonPicker {
    if (_commonPicker) return _commonPicker;
    _commonPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, kAXPickerToolBarHeight, self.bounds.size.width, kAXPickerHeight)];
    _commonPicker.backgroundColor = kAXDefaultBackgroundColor;
    _commonPicker.delegate = _delegate;
    _commonPicker.dataSource = _dataSource;
    _commonPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    return _commonPicker;
}

- (AXPickerContentView *)backgroundView {
    if (_backgroundView) return _backgroundView;
    _backgroundView = [[AXPickerContentView alloc] initWithFrame:CGRectZero];
    _backgroundView.delegate = self;
    _backgroundView.dataSource = self;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return _backgroundView;
}

- (UIToolbar *)effectBar {
    if (_effectBar) return _effectBar;
    _effectBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    _effectBar.translucent = YES;
    _effectBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_effectBar setSeparatorHidden:YES];
    return _effectBar;
}

- (UIVisualEffectView *)effectView {
    if (_effectView) return _effectView;
    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _effectView.tintColor = [UIColor clearColor];
    _effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return _effectView;
}
#pragma mark - Public_interface

- (void)showAnimated:(BOOL)animated completion:(AXPickerViewCompletion)completion revoking:(AXPickerViewRevoking)revoking executing:(AXPickerViewExecuting)executing {}

- (void)show:(BOOL)animated completion:(AXPickerViewCompletion)completion revoking:(AXPickerViewRevoking)revoking executing:(AXPickerViewExecuting)executing
{
    if (!_view) return;
    
    // Prepare animating
    self.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    
    _completion = completion;
    _revoking = revoking;
    _executing = executing;
    
    if (_delegate && [_delegate respondsToSelector:@selector(pickerViewWillShow:)]) {
        [_delegate pickerViewWillShow:self];
    }
    
    [_view addSubview:_backgroundView];
    [_view addSubview:self];
    
    if (animated) {
        self.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, self.bounds.size.height), CGAffineTransformMakeScale(1, 1));
        self.alpha = 1.0;
        
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:1.0
                            options:7
                         animations:^{
                             _backgroundView.alpha = 1.0;
                             self.transform = CGAffineTransformIdentity;
                             if (_scaleBackgroundView) {
                                 if ([_view isKindOfClass:[UIWindow class]]) {
                                     UIView *view = ((UIView *)_view.subviews[0]);
                                     CGFloat scale = (view.bounds.size.height - 40) / view.bounds.size.height;
                                     view.transform = CGAffineTransformMakeScale(scale, scale);
                                     UIInterpolatingMotionEffect *xMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                                     UIInterpolatingMotionEffect *yMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                                     CGFloat xMax = view.bounds.size.width * (1 - scale);
                                     CGFloat yMax = view.bounds.size.height * (1 - scale);
                                     xMotion.maximumRelativeValue = @(xMax / 2);
                                     xMotion.minimumRelativeValue = @(-xMax / 2);
                                     yMotion.maximumRelativeValue = @(yMax / 4);
                                     yMotion.minimumRelativeValue = @(-yMax / 2);
                                     view.motionEffects = @[xMotion, yMotion];
                                 } else {
                                     CGFloat scale = (_view.bounds.size.height - 40) / _view.bounds.size.height;
                                     _view.transform = CGAffineTransformMakeScale(scale, scale);
                                     UIInterpolatingMotionEffect *xMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                                     UIInterpolatingMotionEffect *yMotion = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                                     CGFloat xMax = _view.bounds.size.width * (1 - scale);
                                     CGFloat yMax = _view.bounds.size.height * (1 - scale);
                                     xMotion.maximumRelativeValue = @(xMax / 2);
                                     xMotion.minimumRelativeValue = @(-xMax / 2);
                                     yMotion.maximumRelativeValue = @(yMax / 4);
                                     yMotion.minimumRelativeValue = @(-yMax / 2);
                                 }
                             }
                         } completion:^(BOOL finished) {
                             EXECUTE_ON_MAIN_THREAD(^{
                                 if (finished && _delegate && [_delegate respondsToSelector:@selector(pickerViewDidShow:)]) {
                                     [_delegate pickerViewDidShow:self];
                                 }
                             });
                         }];
    } else {
        self.alpha = 1.0;
        _backgroundView.alpha = 1.0;
    }
}

- (void)hideAnimated:(BOOL)animated completion:(void (^)())completion {}

- (void)hide:(BOOL)animated completion:(void (^)())completion {
    if (!self.superview) return;
    
    // Prepare animating
    if (_delegate && [_delegate respondsToSelector:@selector(pickerViewWillHide:)]) {
        [_delegate pickerViewWillHide:self];
    }
    
    void(^__completion)() = ^() {
        if (self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        } else {
            self.alpha = 0.0;
        }
        [_backgroundView removeFromSuperview];
        self.transform = CGAffineTransformIdentity;
        if (_delegate && [_delegate respondsToSelector:@selector(pickerViewDidHide:)]) {
            [_delegate pickerViewDidHide:self];
        }
        
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        
        if (completion) {
            EXECUTE_ON_MAIN_THREAD(^{
                completion();
            });
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.00
                            options:7
                         animations:^{
                             _backgroundView.alpha = 0.0;
                             self.transform = CGAffineTransformMakeTranslation(0.0, self.bounds.size.height);
                             if (_scaleBackgroundView) {
                                 id view = self.superview;
                                 if ([view isKindOfClass:[UIWindow class]]) {
                                     UIView *targetView = ((UIView *)[view subviews][0]);
                                     targetView.transform = CGAffineTransformIdentity;
                                     targetView.motionEffects = @[];
                                 } else {
                                     self.superview.transform = CGAffineTransformIdentity;
                                     self.superview.motionEffects = @[];
                                 }
                             }
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 __completion();
                             }
                         }];
    } else {
        _backgroundView.alpha = 0.0;
        self.transform = CGAffineTransformMakeTranslation(0.0, self.bounds.size.height);
        __completion();
    }
}

#pragma mark - Private_helper
- (UIVisualEffectView *)subEffectView NS_AVAILABLE_IOS(8_0) {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, self.bounds.size.width, kAXPickerToolBarHeight);
    effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return effectView;
}

- (UIButton *)buttonWithTitle:(NSString *)title rightHeight:(CGFloat)height atIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    button.backgroundColor = [UIColor clearColor];
    [button setBackgroundImage:[self tintImage:[UIImage imageNamed:@"AXPickerView.bundle/ax_button"] WithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    UIColor * __block aItemColor;
    UIFont * __block aItemFont;
    [_itemConfigs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AXPickerViewItemConfiguration class]]) {
            AXPickerViewItemConfiguration *config = (AXPickerViewItemConfiguration *)obj;
            if (index == config.index) {
                aItemColor = config.tintColor;
                aItemFont = config.textFont;
                *stop = YES;
            }
        }
    }];
    
    button.tintColor = aItemColor ? aItemColor : (_itemTintColor?_itemTintColor:self.tintColor);
    button.titleLabel.font = aItemFont ? aItemFont : (_itemFont?_itemFont:[UIFont systemFontOfSize:18]);
    
    // Origin y
    CGFloat originY = kAXPickerToolBarHeight * (self.title.length > 0 ? index + 1 : index);
    if (_customView) {
        originY += _customView.bounds.size.height + _customViewInsets.top + _customViewInsets.bottom;
    }
    button.frame = CGRectMake(0, originY, self.bounds.size.width, kAXPickerToolBarHeight);
    button.tag = index+1;
    
    // Add targets
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    // Add separator layers
    UIEdgeInsets __block insets = _separatorInsets;
    UIColor *__block separatorColor = nil;
    CGFloat __block _height = .5;
    [_separatorConfigs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AXPickerViewSeparatorConfiguration class]]) {
            AXPickerViewSeparatorConfiguration *config = (AXPickerViewSeparatorConfiguration *)obj;
            if (index == config.index) {
                *stop = YES;
                insets = config.insets;
                separatorColor = config.color;
                _height = config.height;
            }
        }
    }];

    if (index == 0) {
        if (!_customView) {
            [button.layer addSublayer:[self separatorWithHeight:_height color:separatorColor ? separatorColor : (_separatorColor?_separatorColor:kAXDefaultSeparatorColor) insets:insets atIndex:0]];
        }
    } else {
        [button.layer addSublayer:[self separatorWithHeight:_height color:separatorColor ? separatorColor : (_separatorColor?_separatorColor:kAXDefaultSeparatorColor) insets:insets atIndex:0]];
    }
    return button;
}

- (AXLayer *)separatorWithHeight:(CGFloat)height color:(UIColor *)color insets:(UIEdgeInsets)insets atIndex:(NSInteger)index {
    AXLayer *layer = [AXLayer layer];
    layer.frame = CGRectMake(insets.left, kAXPickerToolBarHeight * index, self.bounds.size.width - (insets.left + insets.right), height);
    layer.backgroundColor = color.CGColor;
    layer.tag = index+1;
    return layer;
}

- (void)configureViews {
    self.titleLabel.font = _titleFont;
    _titleLabel.textColor = _titleTextColor;
    
    switch (_style) {
        case AXPickerViewStyleNormal:
//            [self configureNormal];
            [self setNeedsDisplay];
            break;
        case AXPickerViewStyleDatePicker:
        case AXPickerViewStyleCommonPicker:
            [self configurePicker];
            break;
        default:
            break;
    }
}

- (void)configureCustomView {
    CGFloat originY = 0.f;
    switch (_style) {
        case AXPickerViewStyleNormal:
        {
            NSString *title = self.title;
            if (title.length > 0) {
                originY = kAXPickerToolBarHeight;
            }
        }
            break;
        default:
            break;
    }
    
    CGRect rect = self.customView.frame;
    rect.origin.y = originY + _customViewInsets.top;
    rect.origin.x = _customViewInsets.left;
    rect.size.width = self.bounds.size.width - (_customViewInsets.left + _customViewInsets.right);
    _customView.frame = rect;
    [self resizingCustomView];
    [self sizeToFit];
    [self setNeedsDisplay];
    [self resizingSelfAnimated:NO];
    
    _customView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
}

- (void)configureNormal __deprecated {
    NSArray *buttons = [self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[UIButton class]]) {
            return YES;
        } else {
            return NO;
        }
    }]];
    for (UIButton *button in buttons) {
        BOOL(^separatorFilter)(id, NSDictionary*) = ^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if ([evaluatedObject isKindOfClass:[AXLayer class]] && [evaluatedObject valueForKey:@"tag"]>0) {
                return YES;
            } else {
                return NO;
            }
        };
        NSInteger index = [buttons indexOfObject:button];
        CALayer *separator = [[button.layer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:separatorFilter]] firstObject];
        if (_separatorConfigs && [_separatorConfigs count] > 0) {
            [_separatorConfigs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[AXPickerViewSeparatorConfiguration class]]) {
                    AXPickerViewSeparatorConfiguration *config = (AXPickerViewSeparatorConfiguration *)obj;
                    if (config.index == index-1) {
                        if (separator) {
                            CGRect rect = separator.frame;
                            rect.origin.x = config.insets.left;
                            rect.size.width = self.bounds.size.width - (config.insets.left + config.insets.right);
                            rect.size.height = config.height;
                            separator.frame = rect;
                            separator.backgroundColor = config.color.CGColor ? config.color.CGColor : (_separatorColor.CGColor?_separatorColor.CGColor:kAXDefaultSeparatorColor.CGColor);
                            [button.layer setNeedsLayout];
                        }
                        *stop = YES;
                    }
                }
            }];
        } else {
            if (separator) {
                separator.backgroundColor = (_separatorColor ? _separatorColor : kAXDefaultSeparatorColor).CGColor;
                CGRect rect = separator.frame;
                rect.origin.x = _separatorInsets.left;
                rect.size.width = self.bounds.size.width - (_separatorInsets.left + _separatorInsets.right);
                rect.size.height = .5;
                separator.frame = rect;
                [button.layer setNeedsLayout];
            }
        }
        if (_itemConfigs && [_itemConfigs count] > 0) {
            [_itemConfigs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[AXPickerViewItemConfiguration class]]) {
                    AXPickerViewItemConfiguration *config = (AXPickerViewItemConfiguration *)obj;
                    if (config.index == index-1) {
                        button.tintColor = config.tintColor;
                        button.titleLabel.font = config.textFont;
                        *stop = YES;
                    }
                }
            }];
        } else {
            button.tintColor = _itemTintColor ? _itemTintColor : self.tintColor;
            button.titleLabel.font = _itemFont?_itemFont:[UIFont systemFontOfSize:18];
        }
    }
    self.cancelBtn.titleLabel.font = _cancelFont;
    _cancelBtn.tintColor = _cancelTextColor;
}

- (void)configurePicker {
    self.cancelBtn.titleLabel.font = _cancelFont;
    _cancelBtn.tintColor = _cancelTextColor;
    self.completeBtn.titleLabel.font = _completeFont;
    _completeBtn.tintColor = _completeTextColor;
}

- (void)configureTools {
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    CGRect rect = _titleLabel.frame;
    rect.size.height = kAXPickerToolBarHeight;
    
    switch (_style) {
        case AXPickerViewStyleNormal:
        {
            CGSize size = CGSizeMake(self.bounds.size.width, kAXPickerToolBarHeight);
            NSInteger count = [_items count];
            NSString *title = self.title;
            CGFloat originY = kAXPickerToolBarHeight * (count + (title.length > 0 ? 1 : 0)) + kPadding;
            if (_customView) {
                originY += _customView.bounds.size.height + _customViewInsets.top + _customViewInsets.bottom;
            }
            self.cancelBtn.frame = CGRectMake(0.f, originY, size.width, size.height);
            _cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            rect.origin.x = 0.f;
            rect.size.width = self.bounds.size.width;
        }
            break;
        case AXPickerViewStyleDatePicker:
        case AXPickerViewStyleCommonPicker:
        {
            CGSize size = CGSizeMake(kAXPickerToolBarHeight, kAXPickerToolBarHeight);
            self.cancelBtn.frame = CGRectMake(0.f, 0.f, size.width, size.height);
            _cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
            self.completeBtn.frame = CGRectMake(self.bounds.size.width - size.width, 0.f, size.width, size.height);
            _completeBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
            rect.size.width = self.bounds.size.width - kAXPickerToolBarHeight * 2.0;
            rect.origin.x = (self.bounds.size.width - rect.size.width) / 2;
        }
            break;
        default:
            break;
    }
    _titleLabel.frame = rect;
}

- (void)resizingSelfAnimated:(BOOL)animated {
    if (!self.superview) return;
    CGSize size = [self sizeThatFits:self.bounds.size];
    CGFloat originY = self.superview.bounds.size.height - size.height;
    
    CGRect rect = self.frame;
    rect.origin.y = originY;
    
    if (animated) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.frame = rect;
                         }];
    } else {
        self.frame = CGRectMake(0.f, originY, size.width, size.height);
    }
}

- (void)resizingCustomView {
    if (![_customView isKindOfClass:[UILabel class]]) return;
    UILabel *label = (UILabel *)_customView;
    CGSize usedSize = [label.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-_customViewInsets.left-_customViewInsets.right, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName : label.font}
                                               context:nil].size;
    CGRect rect = label.frame;
    rect.size.width = ceil(usedSize.width);
    rect.size.height = ceil(usedSize.height);
    label.frame = rect;
    
    [self setNeedsDisplay];
}

- (UIImage *)tintImage:(UIImage *)image WithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Private_actions
- (void)buttonClicked:(UIButton *)sender {
    [self hide:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(pickerView:didSelectedItem:atIndex:)]) {
            [_delegate pickerView:self didSelectedItem:[sender titleForState:UIControlStateNormal] atIndex:sender.tag - 1];
        }
    }];
    if (_executing) {
        EXECUTE_ON_MAIN_THREAD(^{
            _executing([sender titleForState:UIControlStateNormal], sender.tag - 1, self);
        });
    }
}

- (void)didConfirm:(UIButton *)sender {
    [self hide:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(pickerViewDidConfirm:)]) {
            [_delegate pickerViewDidConfirm:self];
        }
    }];
    if (_completion) {
        EXECUTE_ON_MAIN_THREAD(^{
            _completion(self);
        });
    }
}

- (void)didCancel:(UIControl *)sender {
    [self hide:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(pickerViewDidCancel:)]) {
            [_delegate pickerViewDidCancel:self];
        }
    }];
    if (_revoking) {
        EXECUTE_ON_MAIN_THREAD(^{
            _revoking(self);
        });
    }
}
#pragma mark - AXPickerContentViewDelegate
- (void)contentViewDidTouchBackground:(AXPickerContentView *)contentView {
    [self hide:YES completion:NULL];
}

- (void)contentViewDidReachLimitedVelocity:(AXPickerContentView *)contentView {
    [self hide:YES completion:NULL];
}

#pragma mark - AXPickerContentViewDataSource
- (NSInteger)ax_collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.previewDataSource ax_collectionView:collectionView numberOfItemsInSection:section];
}

- (AXPickerCollectionViewCell *)ax_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.previewDataSource ax_collectionView:collectionView cellForItemAtIndexPath:indexPath];
}
@end

#pragma mark - Implementation_DatePicker
@implementation AXPickerView(DatePicker)
- (NSDate *)selectedDate {
    if (_style == AXPickerViewStyleDatePicker) {
        return self.datePicker.date;
    }
    return nil;
}
@end
#pragma mark - Implementation_CommonPicker
@implementation AXPickerView(CommonPicker)
- (NSInteger)numberOfComponents {
    return _commonPicker.numberOfComponents;
}

- (NSInteger)selectedRowInComponent:(NSInteger)component {
    return [_commonPicker selectedRowInComponent:component];
}

- (void)reloadData {
    [_commonPicker reloadAllComponents];
}
@end
#pragma mark - Implementation_Convenience
@implementation AXPickerView(Convenience)
- (UILabel *)tipsLabel {
    if ([self.customView isKindOfClass:[UILabel class]]) {
        return (UILabel *)self.customView;
    }
    return nil;
}

- (UIFont *)tipsFont {
    return self.tipsLabel.font;
}

- (void)setTipsFont:(UIFont *)tipsFont {
    [self.tipsLabel setFont:tipsFont];
    CGRect rect = self.tipsLabel.frame;
    CGSize usedSize = [self.tipsLabel.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : tipsFont} context:nil].size;
    rect.size = CGSizeMake(ceil(usedSize.width), ceil(usedSize.height));
    self.tipsLabel.frame = rect;
    [self setNeedsDisplay];
    [self resizingSelfAnimated:NO];
}

+ (instancetype)showInView:(UIView *)view animated:(BOOL)animated style:(AXPickerViewStyle)style items:(NSArray *)items title:(NSString *)title tips:(NSString *)tips configuration:(AXPickerViewConfiguration)configuration completion:(AXPickerViewCompletion)completion revoking:(AXPickerViewRevoking)revoking executing:(AXPickerViewExecuting)executing
{
    UIView *aCustomView = nil;
    if (tips && tips.length > 0) {
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize usedSize = [tips boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName : font}
                                             context:nil].size;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ceil(usedSize.width), ceil(usedSize.height))];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByTruncatingTail;
        label.backgroundColor = [UIColor clearColor];
        label.font = font;
        label.textColor = [kAXDefaultTintColor colorWithAlphaComponent:0.5];
        label.text = tips;
        aCustomView = label;
    }
    return [self showInView:view animated:animated style:style items:items title:title customView:aCustomView configuration:configuration completion:completion revoking:revoking executing:executing];
}
+ (instancetype)showInView:(UIView *)view animated:(BOOL)animated style:(AXPickerViewStyle)style items:(NSArray *)items title:(NSString *)title customView:(UIView *)customView configuration:(AXPickerViewConfiguration)configuration completion:(AXPickerViewCompletion)completion revoking:(AXPickerViewRevoking)revoking executing:(AXPickerViewExecuting)executing
{
    AXPickerView *pickerView = [[AXPickerView alloc] initWithStyle:style
                                                             items:items];
    // Set property
    if (!view) {
        UIWindow *keyWindow = nil;
        NSInteger i = 0;
        while (keyWindow == nil && i <= [UIApplication sharedApplication].windows.count) {
            UIWindow *_keyWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:i++];
            if ([_keyWindow isKeyWindow]) {
                keyWindow = _keyWindow;
            }
        }
        pickerView.view = keyWindow;
    } else {
        pickerView.view = view;
    }
    pickerView.title = title;
    pickerView.customView = customView;
    [pickerView sizeToFit];
    // Configure if needed
    if (configuration) {
        EXECUTE_ON_MAIN_THREAD(^{
            configuration(pickerView);
        });
    }
    // Show
    [pickerView show:YES completion:completion revoking:revoking executing:executing];
    return pickerView;
}
@end
#pragma mark - Implementation_ImagePicker

#define kImagePickerReuseIdentifier @"AXImagePickerCell"
#define kImagePickerRightHeight 220
#define kImagePickerMinWidth 110

@implementation AXPickerView(ImagePicker)
#pragma mark - Public
+ (instancetype)showImagePickerInView:(UIView *)view animated:(BOOL)animated allowsMultipleSelection:(BOOL)allowsMultipleSelection containsCamera:(BOOL)containsCamera configuration:(AXPickerViewConfiguration)configuration completion:(AXPickerViewCompletion)completion revoking:(AXPickerViewRevoking)revoking imagePickercompletion:(AXImagePickerCompletion)imagePickerCompletion
{
    NSArray *items = @[];
    if (containsCamera) {
        items = @[@"拍摄", @"从相册选取"];
    } else {
        items = @[@"从相册选取"];
    }
    AXPickerView *pickerView = [[AXPickerView alloc] initWithStyle:AXPickerViewStyleNormal items:items];
    pickerView.containsCamera = containsCamera;
    pickerView.separatorInsets = UIEdgeInsetsZero;
    pickerView.maxAllowedSelectionCount = 9;
    pickerView.view = view;
    if (configuration) {
        configuration(pickerView);
    }
    pickerView.imagePickerCompletion = imagePickerCompletion;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, kImagePickerRightHeight)
                                                          collectionViewLayout:layout];
    pickerView.allowsMultipleSelection = allowsMultipleSelection;
    collectionView.allowsMultipleSelection = allowsMultipleSelection;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[AXImagePickerCell class] forCellWithReuseIdentifier:kImagePickerReuseIdentifier];
    collectionView.delegate = pickerView;
    collectionView.dataSource = pickerView;
    pickerView.customView = collectionView;
    /*
    AXPracticalHUD *hud = [AXPracticalHUD showHUDInView:collectionView animated:YES];
    hud.translucent = YES;
    hud.lockBackground = YES;
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:0.5 completion:nil];
     */
    [pickerView enumerateAssetsGroupCompletion:nil];
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:pickerView];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleALLibraryChangedNotification:) name:ALAssetsLibraryChangedNotification object:nil];
    }
    [AXImagePickerController requestAuthorizationCompletion:^{
        [collectionView reloadData];
        [pickerView show:YES completion:completion revoking:revoking executing:^(NSString *selectedTitle, NSInteger index, AXPickerView *inPickerView) {
            NSInteger indexInfo = 0;
            if (pickerView.containsCamera) {
                indexInfo = index;
            } else {
                indexInfo = index + 1;
            }
            switch (indexInfo) {
                case 0:
                {
                    [UIImagePickerController requestAuthorizationOfCameraCompletion:^{
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.delegate = pickerView;
                        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                            UIViewController *controller = pickerView.window.rootViewController;
                            pickerView.removeFromSuperViewOnHide = NO;
                            if (controller) {
                                UIViewController *presentedController = controller.presentedViewController;
                                if (presentedController) {
                                    [presentedController presentViewController:imagePicker
                                                                      animated:YES
                                                                    completion:nil];
                                } else {
                                    [controller presentViewController:imagePicker
                                                             animated:YES
                                                           completion:nil];
                                }
                            }
                        } else {
                            [[AXPracticalHUD sharedHUD] showErrorInView:pickerView.window
                                                                   text:@"相机不可用"
                                                                 detail:@"请检查并重试"
                                                          configuration:^(AXPracticalHUD *HUD) {
                                                              HUD.translucent = YES;
                                                              HUD.lockBackground = YES;
                                                              HUD.dimBackground = YES;
                                                              HUD.position  = AXPracticalHUDPositionCenter;
                                                              HUD.animation = AXPracticalHUDAnimationFade;
                                                              HUD.restoreEnabled = YES;
                                                              [HUD hideAnimated:YES
                                                                     afterDelay:4.0
                                                                     completion:nil];
                                                          }];
                        }
                    } failure:^{
                        [[AXPracticalHUD sharedHUD] showErrorInView:pickerView.window
                                                               text:@"访问相机失败"
                                                             detail:@"请前往 设置->隐私->相机 允许应用访问相机"
                                                      configuration:^(AXPracticalHUD *HUD) {
                                                          HUD.translucent = YES;
                                                          HUD.lockBackground = YES;
                                                          HUD.dimBackground = YES;
                                                          HUD.position  = AXPracticalHUDPositionCenter;
                                                          HUD.animation = AXPracticalHUDAnimationFade;
                                                          HUD.restoreEnabled = YES;
                                                          [HUD hideAnimated:YES
                                                                 afterDelay:4.0
                                                                 completion:nil];
                                                      }];
                    }];
                }
                    break;
                case 1:
                {
                    [AXImagePickerController requestAuthorizationCompletion:^{
                        AXImagePickerController *imagePicker = [[AXImagePickerController alloc] init];
                        imagePicker.delegate = pickerView;
                        imagePicker.maxAllowedSelectionCount = pickerView.maxAllowedSelectionCount;
                        imagePicker.selectionTintColor = pickerView.selectionTintColor;
                        imagePicker.allowsMultipleSelection = pickerView.allowsMultipleSelection;
                        UIViewController *controller = pickerView.window.rootViewController;
                        pickerView.removeFromSuperViewOnHide = NO;
                        objc_setAssociatedObject(pickerView, @selector(imagePickerController), imagePicker, OBJC_ASSOCIATION_ASSIGN);
                        if (controller) {
                            UIViewController *presentedController = controller.presentedViewController;
                            if (presentedController) {
                                [presentedController presentViewController:imagePicker
                                                                  animated:YES
                                                                completion:nil];
                            } else {
                                [controller presentViewController:imagePicker
                                                         animated:YES
                                                       completion:nil];
                            }
                        }
                    } failure:^{
                        [[AXPracticalHUD sharedHUD] showErrorInView:pickerView.window
                                                               text:@"访问相册失败"
                                                             detail:@"请前往 设置->隐私->照片 允许应用访问相册"
                                                      configuration:^(AXPracticalHUD *HUD) {
                                                          HUD.translucent = YES;
                                                          HUD.lockBackground = YES;
                                                          HUD.dimBackground = YES;
                                                          HUD.position  = AXPracticalHUDPositionCenter;
                                                          HUD.animation = AXPracticalHUDAnimationFade;
                                                          HUD.restoreEnabled = YES;
                                                          [HUD hideAnimated:YES
                                                                 afterDelay:4.0
                                                                 completion:nil];
                                                      }];
                    }];
                }
                    break;
                case 2:
                {
                    if ([pickerView.customView isKindOfClass:[UICollectionView class]]) {
                        NSMutableArray *images = [NSMutableArray array];
                        for (NSIndexPath *indexPath in [(UICollectionView *)pickerView.customView indexPathsForSelectedItems]) {
                            if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
                                PHAsset *asset = [pickerView.photoAssetsResult objectAtIndex:indexPath.item];
                                UIImage *image = [asset image];
                                if (image) {
                                    [images addObject:image];
                                }
                            } else {
                                ALAsset *asset = [pickerView.photoAssets objectAtIndex:indexPath.item];
                                UIImage *image = [asset image];
                                if (image) {
                                    [images addObject:image];
                                }
                            }
                        }
                        if (pickerView.imagePickerCompletion) {
                            pickerView.imagePickerCompletion(pickerView, images);
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }];
    } failure:^{
        
    }];
    return pickerView;
}
#pragma mark - Setters&Getters
- (PHFetchResult *)photoAssetsResult {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) return obj;
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                     subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                     options:nil];
    PHAssetCollection *topCollection = [collectionResult firstObject];
    if (topCollection) {
        PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:topCollection
                                                                   options:options];
        objc_setAssociatedObject(self, _cmd, assetResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return assetResult;
    }
    return obj;
}

- (void)setPhotoAssetsResult:(PHFetchResult *)photoAssetsResult {
    objc_setAssociatedObject(self, @selector(photoAssetsResult), photoAssetsResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ALAssetsLibrary *)photoLibrary {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) return obj;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    objc_setAssociatedObject(self, _cmd, library, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return library;
}

- (void)setPhotoLibrary:(ALAssetsLibrary *)photoLibrary {
    objc_setAssociatedObject(self, @selector(photoLibrary), photoLibrary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)photoAssets {
    return [objc_getAssociatedObject(self, _cmd) mutableCopy];
}

- (BOOL)containsCamera {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj boolValue];
    }
    return YES;
}

- (void)setContainsCamera:(BOOL)containsCamera {
    objc_setAssociatedObject(self, @selector(containsCamera), @(containsCamera), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)allowsMultipleSelection {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj boolValue];
    }
    return NO;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    objc_setAssociatedObject(self, @selector(allowsMultipleSelection), @(allowsMultipleSelection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)maxAllowedSelectionCount
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setMaxAllowedSelectionCount:(NSUInteger)maxAllowedSelectionCount {
    objc_setAssociatedObject(self, @selector(maxAllowedSelectionCount), @(maxAllowedSelectionCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)selectionTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSelectionTintColor:(UIColor *)selectionTintColor {
    objc_setAssociatedObject(self, @selector(selectionTintColor), selectionTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AXImagePickerController *)imagePickerController {
    return objc_getAssociatedObject(self, _cmd);
}
#pragma mark - Public
- (void)enumerateAssetsGroupCompletion:(void(^)())completion {
    [self.photoLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                         if (group) {
                                             *stop = YES;
                                             NSMutableArray *photoAssets = [NSMutableArray array];
                                             [group enumerateAssetsWithOptions:NSEnumerationReverse
                                                                    usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                        if (result) {
                                                                            [photoAssets addObject:result];
                                                                        }
                                                                        if (photoAssets.count == group.numberOfAssets - 1) {
                                                                            *stop = YES;
                                                                            objc_setAssociatedObject(self, @selector(photoAssets), photoAssets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                                                                            if ([_customView isKindOfClass:[UICollectionView class]] && [_customView respondsToSelector:@selector(reloadData)]) {
                                                                                [_customView performSelector:@selector(reloadData)
                                                                                                  withObject:nil];
                                                                            }
                                                                            if (completion) {
                                                                                EXECUTE_ON_MAIN_THREAD(^{
                                                                                    completion();
                                                                                });
                                                                            }
                                                                        }
                                                                    }];
                                         }
                                     } failureBlock:^(NSError *error) {
#if DEBUG
                                         NSLog(@"error: %@", error);
#endif
                                     }];
}

#pragma mark - Private
- (CGSize)rightSizeWithOriginalSize:(CGSize)size rightHeight:(CGFloat)height {
    return CGSizeMake(MAX(kImagePickerMinWidth, size.width * (height / size.height)), height);
}

- (void)handleALLibraryChangedNotification:(NSNotification *)aNotification {
    [self enumerateAssetsGroupCompletion:nil];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *change = [changeInstance changeDetailsForFetchResult:self.photoAssetsResult];
    if (change.hasIncrementalChanges) {
        self.photoAssetsResult = [change fetchResultAfterChanges];
        if ([self.customView isKindOfClass:[UICollectionView class]]) {
            [_customView performSelector:@selector(reloadData)];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        PHAsset *asset = [self.photoAssetsResult objectAtIndex:indexPath.item];
        return [self rightSizeWithOriginalSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) rightHeight:kImagePickerRightHeight];
    } else {
        ALAsset *asset = [self.photoAssets objectAtIndex:indexPath.item];
        return [self rightSizeWithOriginalSize:asset.defaultRepresentation.dimensions rightHeight:kImagePickerRightHeight];
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        NSInteger count = self.photoAssetsResult ? self.photoAssetsResult.count : 0;
        if (count > 0) {
            [collectionView setIndicatorViewEnabled:NO];
        } else {
            [collectionView setIndicatorViewEnabled:YES];
        }
        return count;
    } else {
        NSInteger count = self.photoAssets ? self.photoAssets.count : 0;
        if (count > 0) {
            [collectionView setIndicatorViewEnabled:NO];
        } else {
            [collectionView setIndicatorViewEnabled:YES];
        }
        return count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AXImagePickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImagePickerReuseIdentifier
                                                                        forIndexPath:indexPath];
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        PHAsset *asset = [self.photoAssetsResult objectAtIndex:indexPath.item];
        CGSize targetSize = [self rightSizeWithOriginalSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) rightHeight:kImagePickerRightHeight];
        PHImageRequestOptions *options = objc_getAssociatedObject(self, _cmd);
        if (!options) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.synchronous = YES;
            objc_setAssociatedObject(self, _cmd, options, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        typeof(cell) __weak wcell = cell;
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(targetSize.width * 2, targetSize.height * 2)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result) {
                                                        dispatch_barrier_async(dispatch_get_main_queue(), ^{
                                                            wcell.imageView.image = result;
                                                        });
                                                    }
                                                }];
    } else {
        ALAsset *asset = [self.photoAssets objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    }
//    cell.label.textColor = self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor;
    cell.tintColor = self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor;
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    PHImageRequestOptions *options = objc_getAssociatedObject(self, @selector(collectionView:cellForItemAtIndexPath:));
    if (options) {
        options.synchronous = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    PHImageRequestOptions *options = objc_getAssociatedObject(self, @selector(collectionView:cellForItemAtIndexPath:));
    if (options) {
        options.synchronous = YES;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView indexPathsForSelectedItems].count >= self.maxAllowedSelectionCount) {
        return NO;
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.allowsMultipleSelection) {
        NSInteger count = [collectionView indexPathsForSelectedItems].count;
        if (count > 0) {
            if (self.containsCamera) {
                self.items = @[@"拍摄", @"从相册选取", [NSString stringWithFormat:@"已选择%@张", @(count)]];
                AXPickerViewItemConfiguration *config = [AXPickerViewItemConfiguration configurationWithTintColor:self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor
                                                                                                             font:nil
                                                                                                          atIndex:2];
                self.itemConfigs = @[config];
            } else {
                self.items = @[@"从相册选取", [NSString stringWithFormat:@"已选择%@张", @(count)]];
                AXPickerViewItemConfiguration *config = [AXPickerViewItemConfiguration configurationWithTintColor:self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor
                                                                                                             font:nil
                                                                                                          atIndex:1];
                self.itemConfigs = @[config];
            }
            return;
        }
        if (self.containsCamera) {
            self.items = @[@"拍摄", @"从相册选取"];
        } else {
            self.items = @[@"从相册选取"];
        }
        self.itemConfigs = nil;
    } else {
        NSInteger count = [collectionView indexPathsForSelectedItems].count;
        if (count > 0) {
            if (self.containsCamera) {
                self.items = @[@"拍摄", @"从相册选取", @"选择"];
                AXPickerViewItemConfiguration *config = [AXPickerViewItemConfiguration configurationWithTintColor:self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor
                                                                                                             font:nil
                                                                                                          atIndex:2];
                self.itemConfigs = @[config];
            } else {
                self.items = @[@"从相册选取", @"选择"];
                AXPickerViewItemConfiguration *config = [AXPickerViewItemConfiguration configurationWithTintColor:self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor
                                                                                                             font:nil
                                                                                                          atIndex:1];
                self.itemConfigs = @[config];
            }
            return;
        }
        if (self.containsCamera) {
            self.items = @[@"拍摄", @"从相册选取"];
        } else {
            self.items = @[@"从相册选取"];
        }
        self.itemConfigs = nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger count = [collectionView indexPathsForSelectedItems].count;
    if (count > 0) {
        if (self.containsCamera) {
            self.items = @[@"拍摄", @"从相册选取", [NSString stringWithFormat:@"已选择%@张", @(count)]];
            AXPickerViewItemConfiguration *config = [AXPickerViewItemConfiguration configurationWithTintColor:self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor
                                                                                                         font:nil
                                                                                                      atIndex:2];
            self.itemConfigs = @[config];
        } else {
            self.items = @[@"从相册选取", [NSString stringWithFormat:@"已选择%@张", @(count)]];
            AXPickerViewItemConfiguration *config = [AXPickerViewItemConfiguration configurationWithTintColor:self.selectionTintColor ? self.selectionTintColor : kAXDefaultSelectedColor
                                                                                                         font:nil
                                                                                                      atIndex:1];
            self.itemConfigs = @[config];
        }
        return;
    } else {
        if (self.containsCamera) {
            self.items = @[@"拍摄", @"从相册选取"];
        } else {
            self.items = @[@"从相册选取"];
        }
        self.itemConfigs = nil;
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (_imagePickerCompletion) {
        _imagePickerCompletion(self, @[image]);
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        if (!self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (_revoking) {
        _revoking(self);
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        if (!self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
    }];
}
#pragma mark - AXImagePickerControllerDelegate
- (void)imagePickerController:(AXImagePickerController *)picker selectedImages:(NSArray *)images {
    if (_imagePickerCompletion) {
        _imagePickerCompletion(self, images);
    }
    if (!self.removeFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
}
- (void)imagePickerControllerCanceled:(AXImagePickerController *)picker {
    if (_revoking) {
        _revoking(self);
    }
    if (!self.removeFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.selectionTintColor) {
        viewController.navigationController.navigationBar.tintColor = self.selectionTintColor;
    } else {
        viewController.navigationController.navigationBar.tintColor = kAXDefaultSelectedColor;
    }
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
}
- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    return UIInterfaceOrientationMaskAll;
}
- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController
{
    return UIInterfaceOrientationPortrait;
}
@end

@implementation AXPickerView(ImagePreview)
- (void)setPreviewDataSource:(id<AXPickerViewPreviewImageDatasource>)previewDataSource {
    objc_setAssociatedObject(self, @selector(previewDataSource), previewDataSource, OBJC_ASSOCIATION_ASSIGN);
    [self.backgroundView reloadData];
}

- (id<AXPickerViewPreviewImageDatasource>)previewDataSource {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)selectIndexPath:(NSIndexPath *)indexPath {
    [self.backgroundView selectIndexPath:indexPath];
}
@end

#pragma mark - Implementation_ItemConfiguration
@implementation AXPickerViewItemConfiguration
- (instancetype)initWithTintColor:(UIColor *)tintColor font:(UIFont *)textFont atIndex:(NSInteger)index {
    if (self = [super init]) {
        _tintColor = tintColor;
        _textFont = textFont;
        _index = index;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return self.index == [[object valueForKey:@"index"] integerValue];
}

+ (instancetype)configurationWithTintColor:(UIColor *)tintColor font:(UIFont *)textFont atIndex:(NSInteger)index {
    return [[self alloc] initWithTintColor:tintColor font:textFont atIndex:index];
}
@end
#pragma mark - Implementation_SeparatorConfiguration
@implementation AXPickerViewSeparatorConfiguration
- (instancetype)initWithHeight:(CGFloat)height insets:(UIEdgeInsets)insets color:(UIColor *)color atIndex:(NSInteger)index {
    if (self = [super init]) {
        _height = height;
        _insets = insets;
        _color = color;
        _index = index;
    }
    return self;
}

+ (instancetype)configurationWithHeight:(CGFloat)height insets:(UIEdgeInsets)insets color:(UIColor *)color atIndex:(NSInteger)index {
    return [[self alloc] initWithHeight:height insets:insets color:color atIndex:index];
}
@end