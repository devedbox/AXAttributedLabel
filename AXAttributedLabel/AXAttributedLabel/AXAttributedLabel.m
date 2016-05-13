//
//  AXAttributedLabel.m
//  AXAttributedLabel
//
//  Created by ai on 16/5/6.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXAttributedLabel.h"
#import <objc/runtime.h>

#ifndef kAXImageDetector
#define kAXImageDetector @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
#endif

@interface AXTextAttachment : NSTextAttachment
/// Font size.
@property(assign, nonatomic) CGFloat fontSize;
@end

@implementation AXTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    return CGRectMake(0,  -ceil((CGRectGetHeight(lineFrag)-_fontSize)*1.3), lineFrag.size.height, lineFrag.size.height);
}
@end

@interface _AXTextStorage : NSTextStorage
{
@private
    NSMutableAttributedString *_storage;
}
/// Detector types.
@property(assign, nonatomic) AXAttributedLabelDetectorTypes detectorTypes;
/// Image detector string.
@property(copy, nonatomic) NSString *imageDetector;
@end

static NSString *const kAXPhone = @"phone";
static NSString *const kAXDate = @"date";
static NSString *const kAXURL = @"url";
static NSString *const kAXAddress = @"address";
static NSString *const kAXTransit = @"transit";

@interface AXAttributedLabel ()<UITextViewDelegate>
{
    @private
    NSString *_storage;
    UIFont   *_font;
    UIColor  *_textColor;
    UIView   * __weak _textContainerView;
    /// Attributed label delegate.
    id<AXAttributedLabelDelegate> __weak __delegate;
    /// Touch background view.
    UIView  *_touchView;
    /// Touch begined.
    BOOL     _touchBegan;
}
/// Links.
@property(strong, nonatomic) NSMutableArray *links;
@end

@interface NSURL (AXAttributedLabel)
/// Result object.
@property(readwrite, strong, nonatomic) NSTextCheckingResult *result;
/// Flag string.
@property(readwrite, strong, nonatomic) NSString *flag;
@end
@implementation NSURL (AXAttributedLabel)
- (NSTextCheckingResult *)result {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setResult:(NSTextCheckingResult *)result {
    objc_setAssociatedObject(self, @selector(result), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)flag {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlag:(NSString *)flag {
    objc_setAssociatedObject(self, @selector(flag), flag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (instancetype)URLWithFlag:(NSString *)flag urlString:(NSString *)urlString result:(NSTextCheckingResult *)result {
    NSURL *url = [NSURL URLWithString:urlString?:flag];
    url.flag = flag;
    url.result = result;
    return url;
}
@end

@interface NSTextCheckingResult (AXAttributedLabel)
/// URL.
@property(readwrite, strong, nonatomic) NSURL *flagedUrl;
@end
@implementation NSTextCheckingResult (AXAttributedLabel)
- (NSURL *)flagedUrl {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFlagedUrl:(NSURL * _Nullable)flagedUrl {
    objc_setAssociatedObject(self, @selector(flagedUrl), flagedUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation AXAttributedLabel
#pragma mark - Initializer
+ (instancetype)attributedLabel {
    AXAttributedLabel *label = [[AXAttributedLabel alloc] init];
    label.attributedEnabled = YES;
    return label;
}

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

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:CGRectZero textContainer:textContainer]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)initializer {
    // Super properties.
    super.editable     = NO;
    super.selectable   = YES;
    super.scrollsToTop = NO;
    super.delegate     = self;
    //------------------
    _font              = [UIFont systemFontOfSize:15];
    _textColor         = [UIColor blackColor];
    _verticalAlignment = AXAttributedLabelVerticalAlignmentTop;
    self.detectorTypes = AXAttributedLabelDetectorTypeDate|AXAttributedLabelDetectorTypeLink|AXAttributedLabelDetectorTypePhoneNumber;
    super.textContainerInset = UIEdgeInsetsMake(4, 0, 4, 0);
    self.userInteractionEnabled = YES;
    // Set the image indicator view to hidden and get the refrence of the text container view.
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view setHidden:YES];
            [view removeFromSuperview];
        } else if ([view isKindOfClass:NSClassFromString(@"_UITextContainerView")]) {
            _textContainerView = view;
            for (UIView *view in _textContainerView.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"UITextSelectionView")]) {
                    [view setHidden:YES];
                    [view setAlpha:0.0];
                }
            }
        }
    }
    // Disable the pan force gesture.
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:NSClassFromString(@"_UIPreviewInteractionTouchObservingGestureRecognizer")] || [gesture isKindOfClass:NSClassFromString(@"_UIPreviewGestureRecognizer")] || [gesture isKindOfClass:NSClassFromString(@"_UITextSelectionForceGesture")] || [gesture isKindOfClass:NSClassFromString(@"_UIRevealGestureRecognizer")]) {
            gesture.enabled = NO;
        }
    }
    // Set up text container.
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textContainer.widthTracksTextView = YES;
    self.textContainer.heightTracksTextView = YES;
}
#pragma mark - Override
- (BOOL)canBecomeFirstResponder {
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:) || action == @selector(copy:) || action == @selector(cut:) || action == @selector(select:) || action == @selector(selectAll:)) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"_UIRevealGestureRecognizer")]) {
        if (_verticalAlignment != AXAttributedLabelVerticalAlignmentTop) {
            return NO;
        } else {
            return _allowsPreviewURLs;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return [super hitTest:point withEvent:event];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 0 || !_shouldInteractWithExclusionViews) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (UIView *view in _exclusionViews) {
        if (CGRectContainsPoint(view.frame, point)) {
            _touchView.frame = CGRectInset(view.frame, -2, -2);
            _touchView.hidden = NO;
            _touchBegan = YES;
            objc_setAssociatedObject(_touchView, _cmd, view, OBJC_ASSOCIATION_ASSIGN);
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.count == 0) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    if (_touchBegan) {
        CGPoint point = [[touches anyObject] locationInView:self];
        for (UIView *view in _exclusionViews) {
            if (CGRectContainsPoint(view.frame, point)) {
                _touchView.frame = CGRectInset(view.frame, -2, -2);
                _touchView.hidden = NO;
                objc_setAssociatedObject(_touchView, _cmd, view, OBJC_ASSOCIATION_ASSIGN);
            } else {
                _touchView.hidden = YES;
                objc_setAssociatedObject(_touchView, _cmd, nil, OBJC_ASSOCIATION_ASSIGN);
            }
        }
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchBegan) {
        _touchView.hidden = YES;
        _touchBegan = NO;
        UIView *view = objc_getAssociatedObject(_touchView, @selector(touchesBegan:withEvent:));
        if (view) {
            [self didSelectExclusionViewsAtIndex:[_exclusionViews indexOfObject:view]];
            objc_setAssociatedObject(_touchView, @selector(touchesBegan:withEvent:), nil, OBJC_ASSOCIATION_ASSIGN);
        }
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_touchBegan) {
        _touchView.hidden = YES;
        _touchBegan = NO;
    }
    [super touchesCancelled:touches withEvent:event];
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize susize = [super sizeThatFits:size];
    susize.width = self.frame.size.width;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
    susize.height = ceil([self.layoutManager usedRectForTextContainer:self.textContainer].size.height)+self.textContainerInset.top+self.textContainerInset.bottom;
    return susize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Layout the text container view.
    if (_textContainerView) {
        CGRect rect_container = _textContainerView.frame;
        [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
        CGSize usedSize = [self.layoutManager usedRectForTextContainer:self.textContainer].size;
        rect_container.size = CGSizeMake(ceil(usedSize.width)+self.textContainerInset.left+self.textContainerInset.right, ceil(usedSize.height+self.textContainerInset.top+self.textContainerInset.bottom));
        if (CGRectGetHeight(rect_container)>=CGRectGetHeight(self.frame)) {
            // Use AXAttributedLabelVerticalAlignmentTop.
            rect_container.origin.y = .0;
            rect_container.size.height = CGRectGetHeight(self.frame);
        } else {
            // Use the vertical alignment.
            switch (_verticalAlignment) {
                case AXAttributedLabelVerticalAlignmentTop:
                    rect_container.origin.y = .0;
                    break;
                case AXAttributedLabelVerticalAlignmentBottom:
                    rect_container.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(rect_container);
                    break;
                case AXAttributedLabelVerticalAlignmentCenter:
                default:
                    rect_container.origin.y = CGRectGetHeight(self.frame)*.5-CGRectGetHeight(rect_container)*.5;
                    break;
            }
        }
        _textContainerView.frame = rect_container;
    }
}
#pragma mark - Getters
- (NSString *)text {
    return _storage?:super.text;
}

- (UIFont *)font {
    if (_attributedEnabled) {
        // Get the font of attributed string.
        if (self.attributedText.length == 0) {
            return super.font;
        }
        UIFont *font = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
        return font ? font : super.font;
    } else {
        return super.font;
    }
}

- (UIColor *)textColor {
    if (_attributedEnabled) {
        // Get the text color of attributed string.
        if (self.attributedText.length == 0) {
            return super.textColor;
        }
        UIColor *color = [self.attributedText attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
        return color?color:super.textColor;
    } else {
        return super.textColor;
    }
}

- (BOOL)isShouldInteractWithURLs {
    return _shouldInteractWithURLs;
}

- (BOOL)isShouldInteractWithAttachments {
    return _shouldInteractWithAttachments;
}

- (NSLineBreakMode)lineBreakMode {
    return self.textContainer.lineBreakMode;
}

- (NSUInteger)numberOfLines {
    return self.textContainer.maximumNumberOfLines;
}

- (NSArray<UIBezierPath *> *)exclusionPaths {
    return self.textContainer.exclusionPaths;
}

- (NSArray *)textCheckingResults {
    NSMutableArray *results = [_links mutableCopy];
    if (!results) {
        results = [@[] mutableCopy];
    }
    NSError *error;
    NSRegularExpression *image = [[NSRegularExpression alloc] initWithPattern:_imageDetector?_imageDetector:kAXImageDetector options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(error == nil, @"%@", error);
    NSDataDetector *other = [NSDataDetector dataDetectorWithTypes:_detectorTypes error:&error];
    NSAssert(error == nil, @"%@", error);
    [results addObjectsFromArray:[image matchesInString:_storage options:0 range:NSMakeRange(0, _storage.length)]];
    [results addObjectsFromArray:[other matchesInString:_storage options:0 range:NSMakeRange(0, _storage.length)]];
    return results;
}
#pragma mark - Setters
- (void)setText:(NSString *)text {
    // Store the copy version of text.
    _storage = [text copy];
    if (_attributedEnabled) {
        // Set attributed label text string.
        super.text = nil;
        self.attributedText = [self attributedString];
    } else {
        self.attributedText = nil;
        super.dataDetectorTypes = UIDataDetectorTypeNone;
        super.text = _storage;
        super.font = _font;
        super.textColor = _textColor;
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (_attributedEnabled) {
        // Set the font of attributed text.
        self.attributedText = [self attributedString];
    } else {
        super.font = font;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    if (_attributedEnabled) {
        // Set the text color of attributed text.
        self.attributedText = [self attributedString];
    } else {
        super.textColor = textColor;
    }
}

- (void)setAttributedEnabled:(BOOL)attributedEnabled {
    _attributedEnabled = attributedEnabled;
    [self setText:_storage];
}

- (void)setDetectorTypes:(AXAttributedLabelDetectorTypes)detectorTypes {
    _detectorTypes = detectorTypes;
    if (_shouldInteractWithURLs) {
        // Address.
        if (_detectorTypes&AXAttributedLabelDetectorTypeAddress) { if (!(super.dataDetectorTypes&UIDataDetectorTypeAddress)) {
            super.dataDetectorTypes|=UIDataDetectorTypeAddress;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypeAddress) {
            super.dataDetectorTypes&=~UIDataDetectorTypeAddress;
        }}
        // Calendar event.
        if (_detectorTypes&AXAttributedLabelDetectorTypeDate) { if (!(super.dataDetectorTypes&UIDataDetectorTypeCalendarEvent)) {
            super.dataDetectorTypes|=UIDataDetectorTypeCalendarEvent;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypeCalendarEvent) {
            super.dataDetectorTypes&=~UIDataDetectorTypeCalendarEvent;
        }}
        // Link.
        if (_detectorTypes&AXAttributedLabelDetectorTypeLink) { if (!(super.dataDetectorTypes&UIDataDetectorTypeLink)) {
            super.dataDetectorTypes|=UIDataDetectorTypeLink;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypeLink) {
            super.dataDetectorTypes&=~UIDataDetectorTypeLink;
        }}
        // Phone number.
        if (_detectorTypes&AXAttributedLabelDetectorTypePhoneNumber) { if (!(super.dataDetectorTypes&UIDataDetectorTypePhoneNumber)) {
            super.dataDetectorTypes|=UIDataDetectorTypePhoneNumber;
        }} else { if (super.dataDetectorTypes&UIDataDetectorTypePhoneNumber) {
            super.dataDetectorTypes&=~UIDataDetectorTypePhoneNumber;
        }}
    } else {
        super.dataDetectorTypes=UIDataDetectorTypeNone;
    }
    [self setText:_storage];
}

- (void)setVerticalAlignment:(AXAttributedLabelVerticalAlignment)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    [self setNeedsLayout];
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    [super setDelegate:self];
}

- (void)setAllowsPreviewURLs:(BOOL)allowsPreviewURLs {
    _allowsPreviewURLs = allowsPreviewURLs;
    // Disable the preview gesture.
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:NSClassFromString(@"_UIRevealGestureRecognizer")]) {
            if (_verticalAlignment != AXAttributedLabelVerticalAlignmentTop) {
                gesture.enabled = NO;
                return;
            }
            gesture.enabled = _allowsPreviewURLs;
        }
    }
}

- (void)setShouldInteractWithURLs:(BOOL)shouldInteractWithURLs {
    _shouldInteractWithURLs = shouldInteractWithURLs;
    [self setDetectorTypes:_detectorTypes];
}

- (void)setShouldInteractWithAttachments:(BOOL)shouldInteractWithAttachments {
    _shouldInteractWithAttachments = shouldInteractWithAttachments;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    self.textContainer.lineBreakMode = lineBreakMode;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
    self.textContainer.maximumNumberOfLines = numberOfLines;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
}

- (void)setExclusionPaths:(NSArray<UIBezierPath *> *)exclusionPaths {
    self.textContainer.exclusionPaths = exclusionPaths;
    [self.layoutManager ensureLayoutForTextContainer:self.textContainer];
}

- (void)setExclusionViews:(NSArray<UIView *> *)exclusionViews {
    _exclusionViews = [exclusionViews copy];
    NSMutableArray *exclusionPaths = [@[] mutableCopy];
    for (UIView *view in _textContainerView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in _exclusionViews) {
        CGRect frame = view.frame;
        frame.origin.x += self.textContainerInset.left;
        frame.origin.y += self.textContainerInset.top;
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:view.frame cornerRadius:view.layer.cornerRadius];
        [exclusionPaths addObject:bezier];
        view.frame = frame;
        [_textContainerView addSubview:view];
        view.userInteractionEnabled = YES;
    }
    [self setExclusionPaths:exclusionPaths];
    if (!_touchView) {
        _touchView = [[UIView alloc] initWithFrame:CGRectZero];
        _touchView.layer.cornerRadius = 4.0;
        _touchView.layer.masksToBounds = YES;
        _touchView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _touchView.hidden = YES;
        [_textContainerView addSubview:_touchView];
    }
}

#pragma mark - Public
- (void)addLinkWithTextCheckingResult:(NSTextCheckingResult *)result {
    if (!_links) {
        _links = [@[] mutableCopy];
    }
    if (![_links containsObject:result]) {
        [_links addObject:result];
    }
    [self setText:_storage];
}

- (void)addLinkToURL:(NSURL *)url withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult linkCheckingResultWithRange:range URL:url];
    result.flagedUrl = [NSURL URLWithFlag:kAXURL urlString:url.absoluteString result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToAddress:(NSDictionary *)addressComponents withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult addressCheckingResultWithRange:range components:addressComponents];
    result.flagedUrl = [NSURL URLWithFlag:kAXURL urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToPhoneNumber:(NSString *)phoneNumber withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult phoneNumberCheckingResultWithRange:range phoneNumber:phoneNumber];
    result.flagedUrl = [NSURL URLWithFlag:kAXPhone urlString:[NSString stringWithFormat:@"tel:%@",phoneNumber] result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToDate:(NSDate *)date withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult dateCheckingResultWithRange:range date:date];
    result.flagedUrl = [NSURL URLWithFlag:kAXDate urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult dateCheckingResultWithRange:range date:date timeZone:timeZone duration:duration];
    result.flagedUrl = [NSURL URLWithFlag:kAXDate urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}
- (void)addLinkToTransitInformation:(NSDictionary *)components withRange:(NSRange)range {
    NSTextCheckingResult *result = [NSTextCheckingResult transitInformationCheckingResultWithRange:range components:components];
    result.flagedUrl = [NSURL URLWithFlag:kAXTransit urlString:nil result:result];
    [self addLinkWithTextCheckingResult:result];
}

- (CGRect)boundingRectForTextRange:(NSRange)range {
    return [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
}
#pragma mark - Private
- (NSAttributedString *)attributedString {
    if (_storage.length == 0) {
        return nil;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[_storage copy]];
    [attributedString addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, attributedString.length)];
    NSError *error;
    
    if (_detectorTypes&AXAttributedLabelDetectorTypeImage) {
        static NSRegularExpression *imageRE;
        imageRE = imageRE?:[[NSRegularExpression alloc] initWithPattern:_imageDetector?_imageDetector:kAXImageDetector options:NSRegularExpressionCaseInsensitive error:&error];
        NSAssert(error == nil, @"%@", error);
        [imageRE enumerateMatchesInString:_storage options:0 range:NSMakeRange(0, _storage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            AXTextAttachment *attachment = [[AXTextAttachment alloc] initWithData:nil ofType:nil];
            attachment.fontSize = _font.pointSize;
            NSString *imageString = [_storage substringWithRange:result.range];
            attachment.image = [_attribute imageAttachmentForAttributedLabel:self result:[result copy]];
            NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSRange targetRange = [attributedString.string rangeOfString:imageString];
            [attributedString replaceCharactersInRange:targetRange withAttributedString:attachString];
            [attributedString addAttribute:NSFontAttributeName value:_font range:NSMakeRange(targetRange.location, 1)];
        }];
    } if (_detectorTypes&AXAttributedLabelDetectorTypeTransitInformation) {
        // Transit information detector.
        static NSDataDetector *transitInformation;
        transitInformation = transitInformation?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeTransitInformation error:&error];
        NSAssert(error == nil, @"%@", error);
        [transitInformation enumerateMatchesInString:_storage options:0 range:NSMakeRange(0, _storage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString *string = [_storage substringWithRange:result.range];
            NSURL *url = [NSURL URLWithFlag:kAXTransit urlString:nil result:[result copy]];
            NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:_font}];
            NSRange targetRange = [attributedString.string rangeOfString:string];
            [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
        }];
    }
    if (!_shouldInteractWithURLs) {
        if (_detectorTypes&AXAttributedLabelDetectorTypeDate) {
            // Date detecor.
            static NSDataDetector *date;
            date = date?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
            NSAssert(error == nil, @"%@", error);
            [date enumerateMatchesInString:_storage options:0 range:NSMakeRange(0, _storage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *string = [_storage substringWithRange:result.range];
                NSString *dateStr = string;
                NSURL *url = [NSURL URLWithFlag:kAXDate urlString:nil result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSLinkAttributeName:url?:dateStr,NSFontAttributeName:_font}];
                NSRange targetRange = [attributedString.string rangeOfString:string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        } if (_detectorTypes&AXAttributedLabelDetectorTypeLink) {
            // Link detecor.
            static NSDataDetector *link;
            link = link?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
            NSAssert(error == nil, @"%@", error);
            [link enumerateMatchesInString:_storage options:0 range:NSMakeRange(0, _storage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *string = [_storage substringWithRange:result.range];
                NSURL *url = [NSURL URLWithFlag:kAXURL urlString:string result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:_font}];
                NSRange targetRange = [attributedString.string rangeOfString:string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        } if (_detectorTypes&AXAttributedLabelDetectorTypeAddress) {
            // Address detecor.
            static NSDataDetector *address;
            address = address?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress error:&error];
            NSAssert(error == nil, @"%@", error);
            [address enumerateMatchesInString:_storage options:0 range:NSMakeRange(0, _storage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *string = [_storage substringWithRange:result.range];
                NSURL *url = [NSURL URLWithFlag:kAXAddress urlString:nil result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:_font}];
                NSRange targetRange = [attributedString.string rangeOfString:string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        } if (_detectorTypes&AXAttributedLabelDetectorTypePhoneNumber) {
            // Phone number detecor.
            static NSDataDetector *phone;
            phone = phone?:[NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
            NSAssert(error == nil, @"%@", error);
            [phone enumerateMatchesInString:_storage options:0 range:NSMakeRange(0, _storage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSString *string = [_storage substringWithRange:result.range];
                NSURL *url = [NSURL URLWithFlag:kAXPhone urlString:[NSString stringWithFormat:@"tel:%@",string] result:[result copy]];
                NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:_font}];
                NSRange targetRange = [attributedString.string rangeOfString:string];
                [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
            }];
        }
    }
    
    for (NSTextCheckingResult *result in _links) {
        NSString *string = [_storage substringWithRange:result.range];
        NSURL *url = [NSURL URLWithFlag:result.flagedUrl.flag urlString:result.flagedUrl.absoluteString result:[result copy]];
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:string attributes:@{NSLinkAttributeName:url,NSFontAttributeName:_font}];
        NSRange targetRange = [attributedString.string rangeOfString:string];
        [attributedString replaceCharactersInRange:targetRange withAttributedString:attr];
    }
    return attributedString;
}

- (void)didSelectExclusionViewsAtIndex:(NSUInteger)index {
    if (_exclusionViewHandler) {
        _exclusionViewHandler(self, index);
    }
    if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectExclusionViewAtIndex:)]) {
        [_attribute attributedLabel:self didSelectExclusionViewAtIndex:index];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {return NO;}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {return NO;}
- (void)textViewDidBeginEditing:(UITextView *)textView {}
- (void)textViewDidEndEditing:(UITextView *)textView {}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {return NO;}
- (void)textViewDidChange:(UITextView *)textView {}
- (void)textViewDidChangeSelection:(UITextView *)textView {}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (_shouldInteractWithURLs) {
        return _shouldInteractWithURLs;
    }
    if ([URL.flag isEqualToString:kAXURL]) {// url.
        if (_urlHandler) {
            _urlHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectURL:)]) {
            [_attribute attributedLabel:self didSelectURL:URL];
        }
    } else if ([URL.flag isEqualToString:kAXDate]) {// date.
        if (_dateHandler) {
            _dateHandler(self, URL.result);
        }
        if (URL.result.timeZone && [_attribute respondsToSelector:@selector(attributedLabel:didSelectDate:timeZone:duration:)]) {
            [_attribute attributedLabel:self didSelectDate:URL.result.date timeZone:URL.result.timeZone duration:URL.result.duration];
        } if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectDate:)]) {
            [_attribute attributedLabel:self didSelectDate:URL.result.date];
        }
    } else if ([URL.flag isEqualToString:kAXPhone]) {// phone number.
        if (_phoneHandler) {
            _phoneHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectPhoneNumber:)]) {
            [_attribute attributedLabel:self didSelectPhoneNumber:[[URL.absoluteString componentsSeparatedByString:@":"] lastObject]];
        }
    } else if ([URL.flag isEqualToString:kAXAddress]) {// address.
        if (_addressHandler) {
            _addressHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectAddress:)]) {
            [_attribute attributedLabel:self didSelectAddress:URL.result.addressComponents];
        }
    } else if ([URL.flag isEqualToString:kAXTransit]) {// transit.
        if (_transitHandler) {
            _transitHandler(self, URL.result);
        }
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectTransitInformation:)]) {
            [_attribute attributedLabel:self didSelectTransitInformation:URL.result.components];
        }
    } else {
        if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectTextCheckingResult:)]) {
            [_attribute attributedLabel:self didSelectTextCheckingResult:URL.result];
        }
    }
    return _shouldInteractWithURLs;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    if (_shouldInteractWithURLs) {
        return _shouldInteractWithURLs;
    }
    if ([_attribute respondsToSelector:@selector(attributedLabel:didSelectAttachment:)]) {
        [_attribute attributedLabel:self didSelectAttachment:textAttachment];
    }
    return _shouldInteractWithAttachments;
}
@end