//
//  AXAlbumTableViewCell.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXAlbumTableViewCell.h"
#import "AXImagePickerControllerMacro.h"

@interface AXAlbumTableViewCell()
/// Effect view
@property(strong, nonatomic) UIView *albumEffectView;
@end

@implementation AXAlbumTableViewCell
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    [self.contentView addSubview:self.albumView];
    [self.contentView addSubview:self.albumTitleLabel];
    [self.contentView addSubview:self.albumDetailLabel];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self addObserver:self forKeyPath:@"albumSelectedInfo.text" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"albumSelectedInfo.text"];
}

#pragma mark - Override
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"albumSelectedInfo.text"]) {
        [_albumSelectedInfo sizeToFit];
        NSString *selectedInfo = [change objectForKey:NSKeyValueChangeNewKey];
        if ([selectedInfo isKindOfClass:[NSString class]]) {
            if (selectedInfo.length > 0) {
                self.accessoryType = UITableViewCellAccessoryNone;
                self.accessoryView = _albumSelectedInfo;
            } else {
                self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                self.accessoryView = nil;
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_albumDetailLabel sizeToFit];
    [_albumTitleLabel sizeToFit];
    
    _albumView.frame = CGRectMake(0, (self.contentView.bounds.size.height - kAXAlbumTableViewCellHeight) / 2, kAXAlbumTableViewCellHeight, kAXAlbumTableViewCellHeight);
    _albumTitleLabel.frame = CGRectMake(CGRectGetMaxX(_albumView.frame) + kAXAlbumTableViewCellLeftMargin, (self.contentView.bounds.size.height - (_albumTitleLabel.bounds.size.height + _albumDetailLabel.bounds.size.height + kAXAlbumTableViewCellPadding)) / 2, _albumTitleLabel.bounds.size.width, _albumTitleLabel.bounds.size.height);
    _albumDetailLabel.frame = CGRectMake(_albumTitleLabel.frame.origin.x, CGRectGetMaxY(_albumTitleLabel.frame) + kAXAlbumTableViewCellPadding, _albumDetailLabel.bounds.size.width, _albumDetailLabel.bounds.size.height);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _albumView.image = nil;
    _albumDetailLabel.text = nil;
    _albumSelectedInfo.text = nil;
    _albumTitleLabel.text = nil;
}

#pragma mark - Getters
- (UIImageView *)albumView {
    if (_albumView) return _albumView;
    _albumView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _albumView.opaque = YES;
    _albumView.contentMode = UIViewContentModeScaleAspectFill;
    _albumView.clipsToBounds = YES;
    _albumView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    return _albumView;
}

- (UILabel *)albumTitleLabel {
    if (_albumTitleLabel) return _albumTitleLabel;
    _albumTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _albumTitleLabel.font = [UIFont systemFontOfSize:17];
    _albumTitleLabel.textColor = [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1.000];
    _albumTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    return _albumTitleLabel;
}

- (UILabel *)albumDetailLabel {
    if (_albumDetailLabel) return _albumDetailLabel;
    _albumDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _albumDetailLabel.font = [UIFont systemFontOfSize:12];
    _albumDetailLabel.textColor = [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:0.500];
    _albumDetailLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    return _albumDetailLabel;
}

- (UILabel *)albumSelectedInfo {
    if (_albumSelectedInfo) return _albumSelectedInfo;
    _albumSelectedInfo = [[UILabel alloc] initWithFrame:CGRectZero];
    _albumSelectedInfo.textAlignment = NSTextAlignmentCenter;
    _albumSelectedInfo.font = [UIFont systemFontOfSize:34];
    _albumSelectedInfo.textColor = [UIColor colorWithRed:0.294 green:0.808 blue:0.478 alpha:1.000];
    _albumSelectedInfo.backgroundColor = [UIColor clearColor];
    _albumSelectedInfo.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    return _albumSelectedInfo;
}

- (UIView *)albumEffectView {
    if (_albumEffectView) return _albumEffectView;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        _albumEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    } else {
        _albumEffectView = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [_albumEffectView setValue:@(YES) forKey:@"translucent"];
        for (UIView *view in [_albumEffectView subviews]) {
            if ([view isKindOfClass:[UIImageView class]] && [[view subviews] count] == 0) {
                [view setHidden:YES];
            }
        }
    }
    _albumEffectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return _albumEffectView;
}
@end