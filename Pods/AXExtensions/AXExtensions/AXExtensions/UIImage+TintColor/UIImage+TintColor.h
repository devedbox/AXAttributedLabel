//
//  UIImage+TintColor.h
//  AXExtensions
//
//  Created by ai on 15/11/23.
//  Copyright © 2015年 AiXing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(TintColor)
/*!
 *  Get a new tint image with a original image and a tint color.
 *
 *  @param image a original image
 *  @param color a tint color
 *
 *  @return a new image with tint color
 */
+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color;
/*!
 *  Get a a new image with a color
 *
 *  @param color a tint color
 *
 *  @return a new image with tint color
 */
- (instancetype)tintImageWithColor:(UIColor *)color;

+ (instancetype)rectangleImageWithColor:(UIColor *)color size:(CGSize)size;
@end
