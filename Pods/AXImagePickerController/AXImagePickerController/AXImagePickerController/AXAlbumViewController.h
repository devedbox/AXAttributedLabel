//
//  AXAlbumViewController.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXViewController.h"

@interface AXAlbumViewController : AXViewController<UITableViewDataSource, UITableViewDelegate>
/// Album library
@property(readonly, strong, nonatomic) ALAssetsLibrary *albumLibrary NS_DEPRECATED_IOS(7_0, 8_0);
/// Album groups of ALAssetsGroup
@property(copy, nonatomic) NSArray *albumGroups NS_DEPRECATED_IOS(7_0, 8_0);
/// Album list of PHAssetCollection
@property(copy, nonatomic) NSArray *albumList NS_AVAILABLE_IOS(8_0);
/// Album view
@property(readonly, strong, nonatomic) UITableView *albumView;
/// Top album info
@property(readonly, nonatomic) id topAlbumInfo NS_AVAILABLE_IOS(7_0);

- (void)loadGroupsCompletion:(void(^)())completion;
@end
