//
//  AXPhotoViewController.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXViewController.h"
#import "AXAlbumViewController.h"

@interface AXPhotoViewController : AXViewController<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
/// Assets library
@property(readonly, strong, nonatomic) ALAssetsLibrary *assetsLibrary NS_DEPRECATED_IOS(7_0, 8_0);
/// Assets collection
@property(readonly, strong, nonatomic) PHAssetCollection *photoCollection NS_AVAILABLE_IOS(8_0);
/// Assets group of ALAssetsGroup
@property(readonly, strong, nonatomic) ALAssetsGroup *assetsGroup NS_DEPRECATED_IOS(7_0, 8_0);
/// Photos
@property(readonly, strong, nonatomic) id photos NS_AVAILABLE_IOS(7_0);
/// Assets of ALAsset
@property(readonly, copy, nonatomic) NSArray __block *assets NS_DEPRECATED_IOS(7_0, 8_0);
/// Photo view
@property(readonly, strong, nonatomic) UICollectionView *photoView;
/// Album view controller.
@property(weak, nonatomic) AXAlbumViewController *albumViewController;

- (instancetype)initWithPhotoCollection:(PHAssetCollection *)collection NS_AVAILABLE_IOS(8_0);
- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group NS_DEPRECATED_IOS(7_0, 8_0);
@end
