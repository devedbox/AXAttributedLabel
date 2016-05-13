//
//  AXAssetsImageController.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXPreviewImageController.h"

@interface AXAssetsImageController : AXPreviewImageController
/// Assets: PHAsset/ALAsset
@property(weak, nonatomic) id asset;

+ (instancetype)defaultControllerWithAsset:(id)asset;
@end
