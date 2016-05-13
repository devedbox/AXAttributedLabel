//
//  AXPracticalHUDContentView.h
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AXPracticalHUDTranslucentStyle) {
    AXPracticalHUDTranslucentStyleLight,
    AXPracticalHUDTranslucentStyleDark
};

@interface AXPracticalHUDContentView : UIView
/// Color
@property(strong, nonatomic) UIColor *color;
/// End colot
@property(strong, nonatomic) UIColor *endColor;
/// Translucent
@property(assign, nonatomic) BOOL translucent;
/// Translucent style
@property(assign, nonatomic) AXPracticalHUDTranslucentStyle translucentStyle;
/// Opacity
@property(assign, nonatomic) CGFloat opacity;
@end
