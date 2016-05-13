//
//  PHAsset+Image.h
//  AXSwift2OC
//
//  Created by ai on 9/6/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>

@interface PHAsset (Image)
/*!
 *  Get image of a PHAsset object
 *
 *  @return a image
 */
- (UIImage *)image;
@end
