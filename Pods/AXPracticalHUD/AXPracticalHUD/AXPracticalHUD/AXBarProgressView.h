//
//  AXBarProgressView.h
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXBarProgressView : UIView
/// Progress value
@property(assign, nonatomic) CGFloat progress;
/// Line color
@property(strong, nonatomic) UIColor *lineColor;
/// Progress color
@property(strong, nonatomic) UIColor *progressColor;
/// Track color
@property(strong, nonatomic) UIColor *trackColor;
@end
