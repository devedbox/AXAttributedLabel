//
//  AXCircleProgressView.h
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXCircleProgressView : UIView
/// Progress value
@property(assign, nonatomic) CGFloat progress;
/// Progress color
@property(strong, nonatomic) UIColor *progressColor;
/// Progress background color
@property(strong, nonatomic) UIColor *progressBgnColor;
/// Annular enabled
@property(assign, nonatomic) BOOL annularEnabled;
@end
