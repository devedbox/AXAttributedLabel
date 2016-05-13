//
//  ALAsset+Image.h
//  AXSwift2OC
//
//  Created by ai on 9/6/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIImage.h>

@interface ALAsset (Image)
/*!
 *  Get image of a ALAsset object
 *
 *  @return a image
 */
- (UIImage *)image;
@end
