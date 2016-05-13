//
//  ALAsset+Image.m
//  AXSwift2OC
//
//  Created by ai on 9/6/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "ALAsset+Image.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
@implementation ALAsset (Image)
- (UIImage *)image {
    return [UIImage imageWithCGImage:[[self defaultRepresentation] fullResolutionImage]];
}
@end
#pragma clang diagnostic pop