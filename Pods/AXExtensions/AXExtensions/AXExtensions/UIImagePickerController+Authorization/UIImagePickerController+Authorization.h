//
//  UIImagePickerController+Authorization.h
//  
//
//  Created by ai on 9/9/15.
//
//

#import <UIKit/UIKit.h>

@interface UIImagePickerController (Authorization)
+ (void)requestAuthorizationOfCameraCompletion:(void(^)())completion failure:(void(^)())failure;
@end
