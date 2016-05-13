//
//  AXPreviewImageController.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXPreviewImageController : UIViewController
/// Image view
@property(readonly, strong, nonatomic) UIImageView *imageView;

+ (instancetype)defaultControllerWithImage:(UIImage *)image;
@end
