//
//  ViewController2.m
//  AXAttributedLabel
//
//  Created by ai on 16/5/17.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ViewController2.h"
#import "AXAttributedLabel.h"
#import <AXPickerView/AXPickerView.h>

@interface ViewController2 ()<AXAttributedLabelDelegate>
/// Attributed label.
@property(strong, nonatomic) AXAttributedLabel *attrLabel;
/// Background view.
@property(strong, nonatomic) UIView *backgroundView;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.backgroundView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:.0]];
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:275]];
    _attrLabel.preferredMaxLayoutWidth = 275-10;
    [self.backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:400]];
    
    _attrLabel.text = @"Multiple availability att[sss]ributes can be placed on a declaration, which may correspond to different platforms. Only the availability attr[sss]ibute with the platform[sss] correcorre 明天 sponding to the target pla[sss]tform will be used. https://www.baidu.com the availability 15680002585 any others wil[sss]l be ignored. If no 成都市成华区二仙桥东三路1号 availability attribute specifies availability for the cu[sss]rrent target platform, the a[sss]vailability attributes are ignored.";
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*.5-45, 45, 90, 90)];
    imageView.image = [UIImage imageNamed:@"avatar.jpg"];
    _attrLabel.exclusionViews = @[imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (AXAttributedLabel *)attrLabel {
    if (_attrLabel) return _attrLabel;
    _attrLabel = [AXAttributedLabel attributedLabel];
    _attrLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _attrLabel.attribute = self;
    _attrLabel.allowsPreviewURLs = YES;
    _attrLabel.shouldInteractWithURLs = YES;
    _attrLabel.shouldInteractWithExclusionViews = YES;
    [_attrLabel addLinkToPhoneNumber:@"15680002585" withRange:NSMakeRange(0, 11)];
    _attrLabel.detectorTypes |= AXAttributedLabelDetectorTypeImage|AXAttributedLabelDetectorTypeLink|AXAttributedLabelDetectorTypeTransitInformation|AXAttributedLabelDetectorTypeAddress;
    _attrLabel.showsMenuItems = YES;
    AXMenuItem *item = [AXMenuItem itemWithTitle:@"aaa" handler:^(AXAttributedLabel * _Nonnull label, AXMenuItem * _Nonnull item) {
        NSLog(@"aaa");
    }];
    AXMenuItem *item1 = [AXMenuItem itemWithTitle:@"bbb" handler:^(AXAttributedLabel * _Nonnull label, AXMenuItem * _Nonnull item) {
        NSLog(@"bbb");
    }];
    AXMenuItem *item2 = [AXMenuItem itemWithTitle:@"ccc" handler:^(AXAttributedLabel * _Nonnull label, AXMenuItem * _Nonnull item) {
        NSLog(@"ccc");
    }];
    AXMenuItem *item3 = [AXMenuItem itemWithTitle:@"ddd" handler:^(AXAttributedLabel * _Nonnull label, AXMenuItem * _Nonnull item) {
        NSLog(@"ddd");
    }];
    AXMenuItem *item4 = [AXMenuItem itemWithTitle:@"eee" handler:^(AXAttributedLabel * _Nonnull label, AXMenuItem * _Nonnull item) {
        NSLog(@"eee");
    }];
    AXMenuItem *item5 = [AXMenuItem itemWithTitle:@"fff" handler:^(AXAttributedLabel * _Nonnull label, AXMenuItem * _Nonnull item) {
        NSLog(@"fff");
    }];
    AXMenuItem *item6 = [AXMenuItem itemWithTitle:@"hhh" handler:^(AXAttributedLabel * _Nonnull label, AXMenuItem * _Nonnull item) {
        NSLog(@"hhh");
    }];
    [_attrLabel setMenuItems:@[item, item1, item2, item3, item4, item5, item6]];
    return _attrLabel;
}

- (UIView *)backgroundView {
    if (_backgroundView) return _backgroundView;
    _backgroundView = [UIView new];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [_backgroundView addSubview:self.attrLabel];
    [_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_attrLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_backgroundView attribute:NSLayoutAttributeTop multiplier:1 constant:5]];
    [_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_attrLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_backgroundView attribute:NSLayoutAttributeLeft multiplier:1 constant:5]];
    [_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_attrLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_backgroundView attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]];
    [_backgroundView addConstraint:[NSLayoutConstraint constraintWithItem:_attrLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_backgroundView attribute:NSLayoutAttributeRight multiplier:1 constant:-5]];
    return _backgroundView;
}

#pragma mark - AXAttributedLabelDelegate
- (UIImage *)imageAttachmentForAttributedLabel:(AXAttributedLabel *)attl result:(NSTextCheckingResult *)result {
    return [UIImage imageNamed:@"avatar.jpg"];
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectURL:(NSURL *)url {
    [AXPickerView showInView:self.view.window animated:YES style:0 items:@[url.absoluteString] title:@"打开链接？" tips:[NSString stringWithFormat:@"点击打开链接:%@", url.absoluteString] configuration:NULL completion:^(AXPickerView *pickerView) {
        pickerView.tipsLabel.textAlignment = NSTextAlignmentCenter;
    } revoking:NULL executing:^(NSString *selectedTitle, NSInteger index, AXPickerView *inPickerView) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectAddress:(NSDictionary *)addressComponents {
    [AXPickerView showInView:self.view.window animated:YES style:0 items:[addressComponents allValues] title:@"地址" tips:@"显示所有地址" configuration:NULL completion:^(AXPickerView *pickerView) {
        pickerView.tipsLabel.textAlignment = NSTextAlignmentCenter;
    } revoking:NULL executing:NULL];
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectPhoneNumber:(NSString *)phoneNumber {
    [AXPickerView showInView:self.view.window animated:YES style:0 items:@[phoneNumber] title:@"拨打电话？" tips:[NSString stringWithFormat:@"点击拨打电话:%@", phoneNumber] configuration:NULL completion:^(AXPickerView *pickerView) {
        pickerView.tipsLabel.textAlignment = NSTextAlignmentCenter;
    } revoking:NULL executing:^(NSString *selectedTitle, NSInteger index, AXPickerView *inPickerView) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
        }
    }];
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectDate:(NSDate *)date {
    NSLog(@"date:%@",date);
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectDate:(NSDate *)date timeZone:(NSTimeZone *)timeZone duration:(NSTimeInterval)duration {
    NSLog(@"date:%@",date);
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectTransitInformation:(NSDictionary *)components {
    
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectAttachment:(NSTextAttachment *)attachment {
    NSLog(@"attachment:%@",attachment);
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result {
    
}
- (void)attributedLabel:(AXAttributedLabel *)attributedLabel didSelectExclusionViewAtIndex:(NSUInteger)index {
    NSLog(@"selected exclusion view at index: %@", @(index));
}

#pragma mark - Actions
- (void)test:(id)sender {
    
}
@end