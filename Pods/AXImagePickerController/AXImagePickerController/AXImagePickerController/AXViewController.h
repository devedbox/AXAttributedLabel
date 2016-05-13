//
//  AXViewController.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AXPracticalHUD/AXPracticalHUD.h>
#import "AXImagePickerController.h"

@protocol AXImagePickerControllerDelegate;

@interface AXViewController : UIViewController
/// Title label
@property(strong, nonatomic) UILabel *titleLabel __deprecated;
/// Count label
@property(strong, nonatomic) UILabel *countLabel;
/// Selection color
@property(strong, nonatomic) UIColor *selectionTintColor;
/// Image picker controller
@property(readonly, nonatomic) AXImagePickerController *imagePickerController;

- (void)updateSelectionInfo;
@end
