//
//  AXPreviewController.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPreviewController.h"
#import "AXImagePickerController.h"
#import <AXPracticalHUD/AXPracticalHUD.h>
#import <AXExtensions/UINavigationBar+Separator_hidden.h>
#import <AXExtensions/UIToolbar+Separator_hidden.h>

@interface AXPreviewController()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    /// Send bar button item
    UIBarButtonItem *_sendItem;
}
/// Title label
@property(strong, nonatomic) UILabel *titleLabel __deprecated;
@end

@implementation AXPreviewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (_pageViewController) {
        [self.view addSubview:_pageViewController.view];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(deleteItem:)];
    _sendItem = [[UIBarButtonItem alloc] initWithTitle:@"选择"
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(sendItem:)];
    [self setToolbarItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], _sendItem]];
    self.title = @"预览";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.barTintColor = [UIColor blackColor];
    
    [self.navigationController.navigationBar setSeparatorHidden:YES];
    [self.navigationController.toolbar setSeparatorHidden:YES];
    
    if (self.navigationController.navigationBar.titleTextAttributes == nil) {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:self.selectionTintColor?self.selectionTintColor:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:19]}];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Override
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self.navigationItem setTitle:title];
}
#pragma mark - Public
+ (instancetype)defaultController {
    UIPageViewController *pageVC = [[self class] PageViewController];
    AXPreviewController *previewVC = [[AXPreviewController alloc] init];
    pageVC.automaticallyAdjustsScrollViewInsets = NO;
    [pageVC willMoveToParentViewController:previewVC];
    [previewVC addChildViewController:pageVC];
    [pageVC didMoveToParentViewController:previewVC];
    previewVC.pageViewController = pageVC;
    pageVC.delegate = previewVC;
    pageVC.dataSource = previewVC;
    return previewVC;
}

+ (UIPageViewController *)PageViewController {
    UIPageViewController *pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                           navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                         options:nil];
    pageVC.view.backgroundColor = [UIColor blackColor];
    return pageVC;
}

#pragma mark - Getters
- (UILabel *)titleLabel {
    if (_titleLabel) return _titleLabel;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = self.selectionTintColor;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:19];
    return _titleLabel;
}

- (UIColor *)selectionTintColor {
    UIColor *tintColor = self.imagePickerController.selectionTintColor;
    if (tintColor) {
        return tintColor;
    }
    return [UIColor colorWithRed:0.294 green:0.808 blue:0.478 alpha:1.000];
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
#pragma mark - Setters
- (void)setImageViewControllers:(NSArray *)imageViewControllers {
    _imageViewControllers = [imageViewControllers copy];
    if (_imageViewControllers.count > 0) {
        [_pageViewController setViewControllers:@[_imageViewControllers.firstObject]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    }
}

- (void)setImages:(NSArray *)images {
    _images = [images copy];
    if (_images.count > 0) {
        [_pageViewController setViewControllers:@[[AXPreviewImageController defaultControllerWithImage:[_images firstObject]]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    }
}

- (void)setAssets:(NSArray *)assets {
    _assets = [assets copy];
    if (_assets.count > 0) {
        [_pageViewController setViewControllers:@[[AXAssetsImageController defaultControllerWithAsset:[_assets firstObject]]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
    }
}
#pragma mark - Actions
- (void)deleteItem:(UIBarButtonItem *)sender {
    AXImagePickerController *imagePickerController = self.imagePickerController;
    if (_assets.count <= 1) {
        NSMutableArray *assetsToRemove = [_assets mutableCopy];
        [imagePickerController deleteAsset:[assetsToRemove firstObject]];
        [assetsToRemove removeObjectAtIndex:0];
        _assets = [assetsToRemove copy];
        [imagePickerController popViewControllerAnimated:YES];
    } else {
        [imagePickerController deleteAsset:_currentImageViewController.asset];
        NSMutableArray *assetsToRemove = [_assets mutableCopy];
        [assetsToRemove removeObject:_currentImageViewController.asset];
        _assets = [assetsToRemove copy];
        _sendItem.title = [NSString stringWithFormat:@"选择%@", @(_assets.count)];
    }
}

- (void)sendItem:(UIBarButtonItem *)sender {
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
#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (!_assets) return nil;
    if (![viewController isKindOfClass:[AXAssetsImageController class]] || ![viewController valueForKey:@"asset"]) return nil;
    NSInteger index = [_assets indexOfObject:[viewController valueForKey:@"asset"]];
    if (index == 0) {
        return nil;
    } else {
        return [AXAssetsImageController defaultControllerWithAsset:_assets[index - 1]];
    }
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (!_assets) return nil;
    if (![viewController isKindOfClass:[AXAssetsImageController class]] || ![viewController valueForKey:@"asset"]) return nil;
    NSInteger index = [_assets indexOfObject:[viewController valueForKey:@"asset"]];
    if (index == _assets.count - 1) {
        return nil;
    } else {
        return [AXAssetsImageController defaultControllerWithAsset:_assets[index + 1]];
    }
}
#pragma mark - UIPageViewControllerDelegate
@end
