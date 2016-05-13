//
//  AXImagePickerController.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class AXAlbumViewController, AXPhotoViewController;
@protocol AXImagePickerControllerDelegate;

@interface AXImagePickerController : UINavigationController
/// Delegate
@property(assign, nonatomic) id<UINavigationControllerDelegate, AXImagePickerControllerDelegate> delegate;
/// Preview enabled
@property(assign, nonatomic) BOOL previewEnabled;
/// Allows multiple selection
@property(assign, nonatomic) BOOL allowsMultipleSelection;
/// Max allowed count of images. Defaults 9.
@property(assign, nonatomic) NSUInteger maxAllowedSelectionCount;
/// Selection tint color
@property(strong, nonatomic) UIColor *selectionTintColor;
/// Selected image info
@property(copy, nonatomic) NSDictionary *selectedImageInfo;
/// Selected assets
@property(readonly, nonatomic) NSArray *selectedAssets;
/// Selected images
@property(readonly, nonatomic) NSArray *selectedImages;
/// Albums view controller
@property(readonly, nonatomic) AXAlbumViewController *albumsViewController;
/// Photos view controller
@property(readonly, nonatomic) AXPhotoViewController *photoViewController;

- (void)deleteAsset:(id)asset;
@end

@protocol AXImagePickerControllerDelegate <NSObject>
@optional
- (void)imagePickerController:(AXImagePickerController *)picker previewWithImages:(NSArray *)images;
- (void)imagePickerController:(AXImagePickerController *)picker selectedImages:(NSArray *)images;
- (void)imagePickerControllerCanceled:(AXImagePickerController *)picker;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
- (void)imagePickerController:(AXImagePickerController *)picker previewWithImageAssets:(NSArray<PHAsset *>*)imageAssets;
- (void)imagePickerController:(AXImagePickerController *)picker selectedImageAssets:(NSArray<PHAsset *>*)imageAssets;
#else
- (void)imagePickerController:(AXImagePickerController *)picker previewWithImageAssets:(NSArray<ALAsset *>*)imageAssets;
- (void)imagePickerController:(AXImagePickerController *)picker selectedImageAssets:(NSArray<ALAsset *>*)imageAssets;
#endif
@end

@interface AXImagePickerController(Authorization)
+ (void)requestAuthorizationCompletion:(void(^)())completion failure:(void(^)())failure;
@end