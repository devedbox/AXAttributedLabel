//
//  ViewController.m
//  AXAttributedLabel
//
//  Created by ai on 16/5/6.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ViewController.h"
#import "AXAttributedLabel/AXAttributedLabel.h"
#import <AXPickerView/AXPickerView.h>

@interface ViewController ()<AXAttributedLabelDelegate>
@property(weak, nonatomic) IBOutlet AXAttributedLabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _label.attribute = self;
    _label.text = @"Multiple availability att[sss]ributes can be placed on a declaration, which may correspond to different platforms. Only the availability attr[sss]ibute with the platform[sss] correcorre 明天 sponding to the target pla[sss]tform will be used. https://www.baidu.com the availability 15680002585 any others wil[sss]l be ignored. If no 成都市成华区二仙桥东三路1号 availability attribute specifies availability for the cu[sss]rrent target platform, the a[sss]vailability attributes are ignored.";
//    _label.attributedEnabled = NO;
    _label.allowsPreviewURLs = YES;
    _label.shouldInteractWithURLs = YES;
    _label.shouldInteractWithExclusionViews = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*.5-45, 45, 90, 90)];
    imageView.image = [UIImage imageNamed:@"avatar.jpg"];
//    _label.exclusionPaths = @[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(CGRectGetWidth(self.view.frame)*.5-45, 20, 90, 90) cornerRadius:30]];
    _label.exclusionViews = @[imageView];
    [_label addLinkToPhoneNumber:@"15680002585" withRange:NSMakeRange(0, 11)];
    _label.detectorTypes |= AXAttributedLabelDetectorTypeImage|AXAttributedLabelDetectorTypeLink|AXAttributedLabelDetectorTypeTransitInformation|AXAttributedLabelDetectorTypeAddress;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
@end
