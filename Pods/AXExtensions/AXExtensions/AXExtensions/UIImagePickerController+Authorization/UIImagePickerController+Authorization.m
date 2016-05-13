//
//  UIImagePickerController+Authorization.m
//  
//
//  Created by ai on 9/9/15.
//
//
#import <AVFoundation/AVFoundation.h>
#import "UIImagePickerController+Authorization.h"

@implementation UIImagePickerController (Authorization)
+ (void)requestAuthorizationOfCameraCompletion:(void (^)())completion failure:(void (^)())failure {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        if (failure) {
            failure();
        }
    } else {
        if (completion) {
            completion();
        }
    }
}
@end
