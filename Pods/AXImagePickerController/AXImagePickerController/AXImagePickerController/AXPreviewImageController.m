//
//  AXPreviewImageController.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPreviewImageController.h"

@interface AXPreviewImageController()
{
    UIImageView *_imageView;
}
@end

@implementation AXPreviewImageController
#pragma mark - Life cycle
+ (instancetype)defaultControllerWithImage:(UIImage *)image {
    AXPreviewImageController *controller = [[AXPreviewImageController alloc] init];
    controller.imageView.image = image;
    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageView];
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _imageView.frame = self.view.bounds;
}
#pragma mark - Getters
- (UIImageView *)imageView {
    if (_imageView) return _imageView;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.backgroundColor = [UIColor blackColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _imageView.clipsToBounds = YES;
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
    _imageView.frame = self.view.bounds;
    return _imageView;
}

#pragma mark - Actions
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    [self.navigationController setNavigationBarHidden:!(self.navigationController.navigationBarHidden) animated:YES];
    [self.navigationController setToolbarHidden:!(self.navigationController.toolbarHidden) animated:YES];
}
@end
