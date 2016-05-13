//
//  UIViewController+Title.h
//  AXSwift2OC
//
//  Created by ai on 9/6/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AXTitleView;
@interface UIViewController (Title)
/// Title view
@property(readonly, nonatomic) AXTitleView *titleView;
/*!
 *  Set a title of view controller with a sepefic title and text color of title label and font
 *
 *  @param title a text content of title
 *  @param color a text color of title label
 *  @param font a font of title label
 *
 *  @return Void
 */
- (void)setTitle:(NSString *)title color:(UIColor *)color font:(UIFont *)font;
@end
@interface AXTitleView : UIView
/// Title.
@property(copy, nonatomic) NSString *title;
/// Title label
@property(readonly, strong, nonatomic) UILabel *titleLabel;
/// Title activityIndicator
@property(strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end
