//
//  AXViewController.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXViewController.h"
#import "AXPreviewController.h"
#import "AXImagePickerControllerMacro.h"
#import <AXExtensions/UIToolbar+Separator_hidden.h>
#import <AXExtensions/UINavigationBar+Separator_hidden.h>

@interface AXViewController()
/// Background effect view
@property(strong, nonatomic) UIView *backgroundView;
@end

@implementation AXViewController
@synthesize selectionTintColor = _selectionTintColor;
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [self setToolbarItems:[self toolBarButtonItems]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *navigationController = self.navigationController;
    navigationController.navigationBar.tintColor = self.selectionTintColor;
    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    navigationController.navigationBar.barTintColor = nil;
    navigationController.toolbar.barStyle = UIBarStyleDefault;
    navigationController.toolbar.tintColor = self.selectionTintColor;
    navigationController.toolbar.barTintColor = nil;
    [navigationController.navigationBar setSeparatorHidden:NO];
    [navigationController.toolbar setSeparatorHidden:NO];
    if (navigationController.navigationBar.titleTextAttributes == nil) {
        [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:self.selectionTintColor?self.selectionTintColor:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:19]}];
    }
    [self setTitle:self.title];
    [self updateSelectionInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AXImagePickerController *imagePickerController = self.imagePickerController;
    if (imagePickerController) {
        NSDictionary *selectedImageInfo = imagePickerController.selectedImageInfo;
        if (selectedImageInfo && [selectedImageInfo isKindOfClass:[NSDictionary class]]) {
            if (selectedImageInfo.count > 0) {
                [imagePickerController setToolbarHidden:NO animated:YES];
            } else {
                [imagePickerController setToolbarHidden:YES animated:YES];
            }
        }
    }
}

#pragma mark - Getters
- (NSArray *)toolBarButtonItems {
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(preview:)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(send:)];
    return @[left, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithCustomView:self.countLabel], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], right];
}

- (UIView *)backgroundView {
    if (_backgroundView) return _backgroundView;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        _backgroundView.frame = self.view.bounds;
    } else {
        _backgroundView = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [_backgroundView setValue:@(YES) forKey:@"translucent"];
        [_backgroundView performSelector:@selector(setSeparatorHidden:) withObject:@(YES)];
    }
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return _backgroundView;
}

- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = self.selectionTintColor;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:19];
    return _titleLabel;
}

- (UILabel *)countLabel {
    if (_countLabel) return _countLabel;
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLabel.textColor = self.selectionTintColor;
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.font = [UIFont systemFontOfSize:23];
    return _countLabel;
}

- (UIColor *)selectionTintColor {
    if (_selectionTintColor) return _selectionTintColor;
    return self.imagePickerController.selectionTintColor;
}

- (AXImagePickerController *)imagePickerController {
    if (self.navigationController) {
        if ([self.navigationController isKindOfClass:[AXImagePickerController class]]) {
            return (AXImagePickerController *)self.navigationController;
        } else {
            return nil;
        }
    }
    return nil;
}

- (void)setSelectionTintColor:(UIColor *)selectionTintColor {
    _selectionTintColor = selectionTintColor;
    if (self.navigationController.navigationBar.titleTextAttributes == nil) {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:selectionTintColor?selectionTintColor:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:19]}];
    }
    self.navigationController.navigationBar.tintColor = self.selectionTintColor;
    self.navigationController.toolbar.tintColor = self.selectionTintColor;
}

#pragma mark - Override
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self.navigationItem setTitle:title];
}

#pragma mark - Actions
- (void)cancel:(UIBarButtonItem *)sender {
    if (self.presentingViewController) {
        AXImagePickerController *imagePickerController = self.imagePickerController;
        id delegate = imagePickerController.delegate;
        if (![delegate conformsToProtocol:NSProtocolFromString(@"AXImagePickerControllerDelegate")]) {
        } else if (delegate && [delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
            [delegate performSelector:@selector(imagePickerControllerDidCancel:) withObject:imagePickerController];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)preview:(UIBarButtonItem *)sender {
    AXImagePickerController *imagePickerController = self.imagePickerController;
    BOOL previewEnabled = imagePickerController.previewEnabled;
    if (previewEnabled) {
        AXPracticalHUD *hud = [AXPracticalHUD showHUDInView:self.view animated:YES];
        hud.translucent = YES;
        AXPreviewController *previewController = [AXPreviewController defaultController];
        previewController.assets = imagePickerController.selectedAssets;
        [hud hideAnimated:YES
               afterDelay:1.0
               completion:^{
                   [imagePickerController pushViewController:previewController animated:YES];
               }];
    } else {
        id<AXImagePickerControllerDelegate> delegate = imagePickerController.delegate;
        if ([delegate respondsToSelector:@selector(imagePickerController:previewWithImages:)]) {
            [delegate imagePickerController:imagePickerController previewWithImages:imagePickerController.selectedImages];
        }
        if ([delegate respondsToSelector:@selector(imagePickerController:previewWithImageAssets:)]) {
            [delegate imagePickerController:imagePickerController previewWithImageAssets:imagePickerController.selectedAssets];
        }
    }
}

- (void)send:(UIBarButtonItem *)sender {
    AXImagePickerController *imagePickerController = self.imagePickerController;
    AXPracticalHUD *hud = [AXPracticalHUD showHUDInView:self.view animated:YES];
    hud.translucent = YES;
    id<AXImagePickerControllerDelegate> delegate = imagePickerController.delegate;
    NSArray *selectedImages = imagePickerController.selectedImages;
    if (!delegate) {
        [hud hideAnimated:YES];
        return;
    }
    if (!selectedImages) {
        [hud hideAnimated:YES];
        return;
    }
    [hud hideAnimated:YES
           afterDelay:1.0
           completion:^{
               [self dismissViewControllerAnimated:YES
                                        completion:^{
                                            if ([delegate respondsToSelector:@selector(imagePickerController:selectedImages:)]) {
                                                [delegate imagePickerController:imagePickerController selectedImages:imagePickerController.selectedImages];
                                            }
                                            if ([delegate respondsToSelector:@selector(imagePickerController:selectedImageAssets:)]) {
                                                [delegate imagePickerController:imagePickerController selectedImageAssets:imagePickerController.selectedAssets];
                                            }
                                        }];
           }];
}

#pragma mark - Public
- (void)updateSelectionInfo {
    AXImagePickerController *imagePickerController = self.imagePickerController;
    NSArray *selectedImageInfos = imagePickerController.selectedImageInfo.allValues;
    if (!selectedImageInfos || [selectedImageInfos isKindOfClass:[NSArray class]]) return;
    NSInteger countOfSelectedPhotos = 0;
    for (NSArray *imageInfo in selectedImageInfos) {
        countOfSelectedPhotos += imageInfo.count;
    }
    if (imagePickerController.allowsMultipleSelection) {
        _countLabel.text = [NSString stringWithFormat:@"%@/%@", @(countOfSelectedPhotos), @(imagePickerController.maxAllowedSelectionCount)];
        [_countLabel sizeToFit];
    } else {
        _countLabel.text = nil;
        [_countLabel sizeToFit];
    }
}
#pragma mark - StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}
@end