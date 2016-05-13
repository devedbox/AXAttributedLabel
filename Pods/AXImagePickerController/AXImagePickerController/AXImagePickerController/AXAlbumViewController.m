//
//  AXAlbumViewController.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXAlbumViewController.h"
#import "AXPhotoViewController.h"
#import "AXAlbumTableViewCell.h"
#import "AXImagePickerControllerMacro.h"

@interface AXAlbumViewController()
{
    ALAssetsLibrary *_albumLibrary;
    UITableView *_albumView;
}
@end

static NSString *kAXAlbumTableViewCellReuseIdentifier = @"__ax_album_tableViewCell";

@implementation AXAlbumViewController
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"相册";
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"相册";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.albumView];
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0) {
        [self loadGroupsCompletion:NULL];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view bringSubviewToFront:_albumView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_albumView reloadData];
}
#pragma mark - Getters
- (ALAssetsLibrary *)albumLibrary {
    if (_albumLibrary) return _albumLibrary;
    _albumLibrary = [[ALAssetsLibrary alloc] init];
    return _albumLibrary;
}
#pragma mark - Setters
- (void)setAlbumGroups:(NSArray *)albumGroups {
    _albumGroups = [albumGroups copy];
    [_albumView reloadData];
}

#pragma mark - Getters
- (UITableView *)albumView {
    if (_albumView) return _albumView;
    _albumView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _albumView.backgroundColor = [UIColor clearColor];
    _albumView.delegate = self;
    _albumView.dataSource = self;
    [_albumView registerClass:[AXAlbumTableViewCell class] forCellReuseIdentifier:kAXAlbumTableViewCellReuseIdentifier];
    _albumView.rowHeight = kAXAlbumTableViewCellHeight;
    _albumView.separatorInset = UIEdgeInsetsMake(0, kAXAlbumTableViewCellHeight, 0, 0);
    return _albumView;
}

- (NSArray *)albumList {
    if (_albumList) return _albumList;
    
    NSMutableArray *albumList = [NSMutableArray array];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount >= 0"];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"estimatedAssetCount" ascending:NO]];
    options.includeAllBurstAssets = NO;
    options.includeHiddenAssets = NO;
    
    PHFetchResult *smartAlbumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                               subtype:PHAssetCollectionSubtypeAny
                                                                               options:options];
    PHFetchResult *albumResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                                          subtype:PHAssetCollectionSubtypeAny
                                                                          options:options];
    [smartAlbumResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            if ([[obj valueForKey:@"assetCollectionSubtype"] integerValue] != PHAssetCollectionSubtypeSmartAlbumAllHidden) {
                PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj
                                                                      options:nil];
                if (result.count > 0) {
                    [albumList addObject:obj];
                }
            }
        }
    }];
    
    [albumResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj
                                                                  options:nil];
            if (result.count > 0) {
                [albumList addObject:obj];
            }
        }
    }];
    
    [albumList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PHFetchResult *result1 = [PHAsset fetchAssetsInAssetCollection:obj1 options:nil];
        PHFetchResult *result2 = [PHAsset fetchAssetsInAssetCollection:obj2 options:nil];
        if (result1.count >= result2.count) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    _albumList = [albumList copy];
    
    return _albumList;
}

- (id)topAlbumInfo {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        return [self.albumList firstObject];
    } else {
        return [self.albumGroups firstObject];
    }
}

#pragma mark - Public
- (void)loadGroupsCompletion:(void(^)())completion {
    NSMutableArray *groups = [NSMutableArray array];
    [self.albumLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                         if (group && [group numberOfAssets] > 0) {
                                             [groups addObject:group];
                                         }
                                         [groups sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                             if ([obj1 numberOfAssets] >= [obj2 numberOfAssets]) {
                                                 return NSOrderedAscending;
                                             } else {
                                                 return NSOrderedDescending;
                                             }
                                         }];
                                         self.albumGroups = groups;
                                         if (completion) {
                                             completion();
                                         }
                                     } failureBlock:^(NSError *error) {
#if DEBUG
                                         NSLog(@"error: %@", error);
#endif
                                         if (completion) {
                                             completion();
                                         }
                                     }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        return _albumList ? _albumList.count : 0;
    } else {
        return _albumGroups ? _albumGroups.count : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AXAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAXAlbumTableViewCellReuseIdentifier
                                                                 forIndexPath:indexPath];
    
    NSString *selectedImageKey = @"";
    
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        PHAssetCollection *album = _albumList[indexPath.row];
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:album
                                                                   options:options];
        [[PHImageManager defaultManager] requestImageForAsset:[assetResult firstObject]
                                                   targetSize:CGSizeMake(kAXAlbumTableViewCellHeight * 2, kAXAlbumTableViewCellHeight * 2)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    cell.albumView.image = result;
                                                }];
        cell.albumDetailLabel.text = [NSString stringWithFormat:@"%@", @(assetResult.count)];
        cell.albumTitleLabel.text = album.localizedTitle;
        selectedImageKey = album.localizedTitle;
    } else {
        ALAssetsGroup *group = _albumGroups[indexPath.row];
        cell.albumView.image = [UIImage imageWithCGImage:[group posterImage]];
        selectedImageKey = [NSString stringWithFormat:@"%@", [group valueForProperty:ALAssetsGroupPropertyName]];
        cell.albumTitleLabel.text = selectedImageKey;
        cell.albumDetailLabel.text = [NSString stringWithFormat:@"%@", @([group numberOfAssets])];
    }
    
    AXImagePickerController *imagePickerController = self.imagePickerController;
    NSArray *images = [imagePickerController.selectedImageInfo objectForKey:selectedImageKey];
    if (images && images.count > 0) {
        cell.albumSelectedInfo.text = [NSString stringWithFormat:@"%@", @(images.count)];
    } else {
        cell.albumSelectedInfo.text = @"";
    }
    cell.albumSelectedInfo.textColor = self.selectionTintColor;
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        PHAssetCollection *collection = [_albumList objectAtIndex:indexPath.row];
        AXPhotoViewController *photoVC = [[AXPhotoViewController alloc] initWithPhotoCollection:collection];
        photoVC.title = collection.localizedTitle;
        [self.navigationController pushViewController:photoVC animated:YES];
    } else {
        ALAssetsGroup *group = [_albumGroups objectAtIndex:indexPath.row];
        AXPhotoViewController *photoVC = [[AXPhotoViewController alloc] initWithAssetsGroup:group];
        photoVC.title = [NSString stringWithFormat:@"%@", [group valueForProperty:ALAssetsGroupPropertyName]];
        [self.navigationController pushViewController:photoVC animated:YES];
    }
}
@end