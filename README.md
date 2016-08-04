# AXAttributedLabel[![Build Status](https://travis-ci.org/devedbox/AXAttributedLabel.svg?branch=master)](https://travis-ci.org/devedbox/AXAttributedLabel)[![Version](https://img.shields.io/cocoapods/v/AXAttributedLabel.svg?style=flat)](http://cocoapods.org/pods/AXAttributedLabel)[![License](https://img.shields.io/cocoapods/l/AXAttributedLabel.svg?style=flat)](http://cocoapods.org/pods/AXAttributedLabel)[![Platform](https://img.shields.io/cocoapods/p/AXAttributedLabel.svg?style=flat)](http://cocoapods.org/pods/AXAttributedLabel)

##Summary
`AXAttributedLabel` is a lightweight attributed text tool based on __TextKit__ using `UITextView` as structures. With `AXAttributedLabel`, you can show text content with phone/address/date as attributed text on a interacting view. You can add custom link to the _label_ and capture the actions of touch on the links. On iOS9.0 (IPhone 6s) and higher platforms, you can interact with links using __Peek__ and __Pop__ to preview the content of links.

[![sample2](http://ww1.sinaimg.cn/large/d2297bd2gw1f6hhddhg0mg20ac0iju0x.gif)](http://ww1.sinaimg.cn/large/d2297bd2gw1f6hhddhg0mg20ac0iju0x.gif)

## Features
> Data detection supported.
> 
> __Peek__&__Pop__ to preview the links.
> 
> Insert any images into text content.
> 
> Long press to show menu and customize the edit menu.
> 
> Added customizable links.

## Requirements

`AXAttributedLabel` used on iOS 7.0 and higher version system of IPhone. It needs：

>* Foundation.framework
>* UIKit.framework

You best use the __newest__ version of xcode when you use the label to your projects.

## Adding AXAttributedLabel to your projet
### CocoaPods
[CocoaPods](http://cocoapods.org) is the recommended way to add AXAttributedLabel to your project.

1. Add a pod entry for AXAttributedLabel to your Podfile `pod 'AXAttributedLabel', '~> 0.2.9'`
2. Install the pod(s) by running `pod install`.
3. Include AXPopoverView wherever you need it with `#import "AXAttributedLabel.h"`.

### Source files

Alternatively you can directly add the `AXAttributedLabel.h` and `AXAttributedLabel.m`  source files to your project.

1. Download the [latest code version](https://github.com/devedbox/AXAttributedLabel/archive/master.zip) or add the repository as a git submodule to your git-tracked project. 
2. Open your project in Xcode, then drag and drop `AXAttributedLabel.h` and `AXAttributedLabel.m` onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project. 
3. Include AXAttributedLabel wherever you need it with `#import "AXAttributedLabel.h"`.

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 

## Usage

`AXAttributedLabel` is simple to use just like `UILabel` or `UITextView`. Before you use it, make sure you initialize correctly like:
```objective-c
    _label = [AXAttributedLabel attributedLabel];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.attribute = self;
    _label.text = @"Multiple availability att[sss]ributes can be placed on a declaration, which may correspond to different platforms. Only the availability attr[sss]ibute with the platform[sss] correcorre 明天 sponding to the target pla[sss]tform will be used. https://www.baidu.com the availability 15680002585 any others wil[sss]l be ignored. If no 成都市成华区二仙桥东三路1号 availability attribute specifies availability for the cu[sss]rrent target platform, the a[sss]vailability attributes are ignored.";
```
And make sure `_label.attributedEnabled = NO;` is setted. `attributedEnabled` controls the detection of data. Default is `YES` to detect data and not to if it's `NO`.
### Set data detector
Like this:
```objective-c
_label.detectorTypes |= AXAttributedLabelDetectorTypeImage|AXAttributedLabelDetectorTypeLink|AXAttributedLabelDetectorTypeTransitInformation|AXAttributedLabelDetectorTypeAddress;
```
### Interact with links
If you want to interact with links. Add these codes after your initializer of `AXAttributedLabel`: 
```objective-c
    _label.shouldInteractWithURLs = YES;
    _label.shouldInteractWithExclusionViews = YES;
```
### Preview links using __3D Touch__
Make sure you set interact enabled and add these codes:
```objective-c
     _label.allowsPreviewURLs = YES;
```
This will work.
### Add images to content
Example:
```objective-c
     UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*.5-45, 45, 90, 90)];
    imageView.image = [UIImage imageNamed:@"avatar.jpg"];
    _label.exclusionViews = @[imageView];
```
### Add custom edit menu options
Example:
```objective-c
    _label.showsMenuItems = YES;
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
    [_label setMenuItems:@[item, item1, item2, item3, item4, item5, item6]];
```
Just make sure `showsMenuItems` set to `YES` first.
### Using delegate
Example:

```objective-c
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
```

## Contact me
If you find any bugs or require new features, please let me know:

`Wechat&Phone：15680002585`

`Weibo: @devedbox`

`GitHub: https://github.com/devedbox`

`LinkedIn：艾星`

`Email：devedbox@gmail.com`