//
//  AXImagePickerControllerMacro.h
//  AXImagePickerController
//
//  Created by ai on 16/4/22.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#ifndef AXImagePickerControllerMacro_h
#define AXImagePickerControllerMacro_h

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.1
#endif
//#ifdef kCFCoreFoundationVersionNumber_iOS_8_0
//#define kCFCoreFoundationVersionNumber_iOS_8_0 11401.1
//#endif
#ifndef kAXPhotoCollectionViewCellReuseIdentifier
#define kAXPhotoCollectionViewCellReuseIdentifier @"__ax_photo_collectionViewCell"
#endif
#ifndef kAXPhotoCollectionViewCellPadding
#define kAXPhotoCollectionViewCellPadding 2.0
#endif
#ifndef kAXPhotoCollectionViewSize
#define kAXPhotoCollectionViewSize (CGSizeMake((self.view.bounds.size.width - kAXPhotoCollectionViewCellPadding * 4) / 3, (self.view.bounds.size.width - kAXPhotoCollectionViewCellPadding * 2) / 3))
#endif

#endif /* AXImagePickerControllerMacro_h */
