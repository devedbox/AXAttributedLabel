//
//  AXImagePickerController.m
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "AXImagePickerController.h"
#import "AXAlbumViewController.h"
#import "AXPhotoViewController.h"
#import "AXImagePickerControllerMacro.h"

@interface AXImagePickerController()
{
    AXAlbumViewController *_albumsViewController;
    AXPhotoViewController *_photoViewController;
    dispatch_once_t onceToken;
}
@end

@implementation AXImagePickerController
@synthesize delegate = _delegate, selectionTintColor = _selectionTintColor;
#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        dispatch_once(&onceToken, ^{
            [self initializer];
        });
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    if (self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass]) {
        dispatch_once(&onceToken, ^{
            [self initializer];
        });
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        dispatch_once(&onceToken, ^{
            [self initializer];
        });
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        dispatch_once(&onceToken, ^{
            [self initializer];
        });
    }
    return self;
}

- (void)initializer {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        [self pushViewController:self.albumsViewController animated:NO];
        if (self.photoViewController) {
            [self pushViewController:_photoViewController animated:NO];
        }
    } else {
        if (self.photoViewController) {
            [self pushViewController:self.albumsViewController animated:NO];
            [self pushViewController:_photoViewController animated:NO];
        } else {
            [self.albumsViewController loadGroupsCompletion:^{
                id group = [_albumsViewController topAlbumInfo];
                if (group && [group isKindOfClass:[ALAssetsGroup class]]) {
                    _photoViewController = [[AXPhotoViewController alloc] initWithAssetsGroup:group];
                    _photoViewController.title = [group valueForProperty:ALAssetsGroupPropertyName];
                }
                if (_photoViewController) {
                    [self pushViewController:self.albumsViewController animated:NO];
                    [self pushViewController:_photoViewController animated:NO];
                } else {
                    [self pushViewController:self.albumsViewController animated:NO];
                }
            }];
        }
    }
    
    [self addObserver:self forKeyPath:@"selectedImageInfo" options:NSKeyValueObservingOptionNew context:nil];
    _previewEnabled = YES;
    _maxAllowedSelectionCount = 9;
    _selectionTintColor = [UIColor colorWithRed:0.294 green:0.808 blue:0.478 alpha:1.000];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selectedImageInfo"];
}

#pragma mark - Override
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedImageInfo"]) {
        NSDictionary *selectedImageInfo = [change objectForKey:NSKeyValueChangeNewKey];
        if ([selectedImageInfo isKindOfClass:[NSDictionary class]]) {
            if (selectedImageInfo.count > 0) {
                [self setToolbarHidden:NO animated:YES];
            } else {
                [self setToolbarHidden:YES animated:YES];
            }
        }
    }
}
#pragma mark - Getters
- (NSArray *)selectedAssets {
    NSArray *albumSelections = [_selectedImageInfo allValues];
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (NSArray *selections in albumSelections) {
        [selectedAssets addObjectsFromArray:selections];
    }
    [selectedAssets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            if ([[obj1 creationDate] timeIntervalSince1970] >= [[obj2 creationDate] timeIntervalSince1970]) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        } else {
            if ([[obj1 valueForProperty:ALAssetPropertyDate] timeIntervalSince1970] >= [[obj2 valueForProperty:ALAssetPropertyDate] timeIntervalSince1970]) {
                return NSOrderedAscending;
            } else {
                return NSOrderedDescending;
            }
        }
    }];
    return [selectedAssets copy];
}

- (NSArray *)selectedImages {
    NSMutableArray *selectedImages = [NSMutableArray array];
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        NSArray *selectedAssets = self.selectedAssets;
        for (PHAsset *asset in selectedAssets) {
            [[PHImageManager defaultManager] requestImageForAsset:asset
                                                       targetSize:PHImageManagerMaximumSize
                                                      contentMode:PHImageContentModeDefault
                                                          options:options
                                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                                        if (result) {
                                                            [selectedImages addObject:result];
                                                        }
                                                    }];
        }
    } else {
        for (ALAsset *asset in self.selectedAssets) {
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
            if (image) {
                [selectedImages addObject:image];
            }
        }
    }
    return [selectedImages copy];
}

- (AXAlbumViewController *)albumsViewController {
    if (_albumsViewController) return _albumsViewController;
    _albumsViewController = [[AXAlbumViewController alloc] init];
    return _albumsViewController;
}

- (AXPhotoViewController *)photoViewController {
    if (_photoViewController) return _photoViewController;
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        PHAssetCollection *collection = self.albumsViewController.topAlbumInfo;
        _photoViewController = [[AXPhotoViewController alloc] initWithPhotoCollection:collection];
        _photoViewController.title = collection.localizedTitle;
    } else {
        ALAssetsGroup *group = self.albumsViewController.topAlbumInfo;
        _photoViewController = [[AXPhotoViewController alloc] initWithAssetsGroup:group];
        _photoViewController.albumViewController = _albumsViewController;
        _photoViewController.title = [group valueForProperty:ALAssetsGroupPropertyName];
    }
    return _photoViewController;
}

- (UIColor *)selectionTintColor {
    if (_selectionTintColor) return _selectionTintColor;
    return [UIColor colorWithRed:0.294 green:0.808 blue:0.478 alpha:1.000];
}

- (void)setSelectionTintColor:(UIColor *)selectionTintColor {
    _selectionTintColor = selectionTintColor;
    _albumsViewController.selectionTintColor = _selectionTintColor;
    _photoViewController.selectionTintColor = _selectionTintColor;
}
#pragma mark - Setters
- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    _allowsMultipleSelection = allowsMultipleSelection;
    _photoViewController.photoView.allowsMultipleSelection = _allowsMultipleSelection;
}

#pragma mark - Actions
- (void)deleteAsset:(id)asset {
    NSMutableArray * __block assetsToRemove;
    for (NSString *key in [_selectedImageInfo allKeys]) {
        // Get the selected assets with a key
        NSArray *selectedAssets = [_selectedImageInfo objectForKey:key];
        [selectedAssets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isEqual:asset]) {
                *stop = YES;
                assetsToRemove = [selectedAssets mutableCopy];
                NSMutableDictionary * selectedImageInfo = [_selectedImageInfo mutableCopy];
                [assetsToRemove removeObjectAtIndex:idx];
                // Set the new assets
                [selectedImageInfo setObject:assetsToRemove forKey:key];
                self.selectedImageInfo = selectedImageInfo;
                return;
            }
        }];
    }
}
@end

@implementation AXImagePickerController(Authorization)
+ (void)requestAuthorizationCompletion:(void (^)())completion failure:(void (^)())failure {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            if (completion) {
                completion();
            }
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    if (completion) {
                        completion();
                    }
                } else {
                    if (failure) {
                        failure();
                    }
                }
            }];
        }
    } else {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
            if (completion) {
                completion();
            }
        } else {
            if (failure) {
                failure();
            }
        }
    }
}
@end