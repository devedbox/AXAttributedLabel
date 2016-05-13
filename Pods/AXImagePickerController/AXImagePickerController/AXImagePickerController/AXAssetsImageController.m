//
//  AXAssetsImageController.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXAssetsImageController.h"
#import <AXExtensions/PHAsset+Image.h>
#import <AXExtensions/ALAsset+Image.h>

@implementation AXAssetsImageController
+ (instancetype)defaultControllerWithAsset:(id)asset {
    AXAssetsImageController *controller = [[AXAssetsImageController alloc] init];
    controller.asset = asset;
    if (![asset isKindOfClass:[PHAsset class]] && ![asset isKindOfClass:[ALAsset class]]) return nil;
    UIImage *image = [asset valueForKey:@"image"];
    if (image) {
        controller.imageView.image = image;
    }
    return controller;
}
@end