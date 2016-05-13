//
//  PHAsset+Image.m
//  AXSwift2OC
//
//  Created by ai on 9/6/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "PHAsset+Image.h"
#import <Photos/PHImageManager.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.1
#endif

@implementation PHAsset (Image)
- (UIImage *)image {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        UIImage * __block image;
        [[PHImageManager defaultManager] requestImageForAsset:self
                                                   targetSize:PHImageManagerMaximumSize
                                                  contentMode:PHImageContentModeDefault
                                                      options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    image = result;
                                                }];
        return image;
    } else {
        return nil;
    }
}
@end
