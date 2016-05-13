//
//  AXPreviewController.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXAssetsImageController.h"

@class AXImagePickerController;

@interface AXPreviewController : UIViewController
/// Assets
@property(copy, nonatomic) NSArray *assets;
/// Images
@property(copy, nonatomic) NSArray *images;
/// Image view controllers -> AXPreviewImageViewController
@property(copy, nonatomic) NSArray *imageViewControllers;
/// Selection color
@property(readonly, nonatomic) UIColor *selectionTintColor;
/// Image picker controller
@property(readonly, nonatomic) AXImagePickerController *imagePickerController;
/// Current image view controller
@property(weak, nonatomic) AXAssetsImageController *currentImageViewController;
/// Page view controller
@property(weak, nonatomic) UIPageViewController *pageViewController;
/// Get a page view controller
+ (UIPageViewController *)PageViewController;
/// Get a default preview view controller
+ (instancetype)defaultController;
@end
