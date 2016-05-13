//
//  AXGradientProgressView.h
//  AXSwift2OC
//
//  Created by ai on 9/7/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXGradientProgressView : UIView
/// Progress value
@property(assign, nonatomic) CGFloat progress;
/// Progress height
@property(assign, nonatomic) CGFloat progressHeight;
/// Colors: CGColor
@property(copy, nonatomic) NSMutableArray *colors;
/// Animation duration: 0.08
@property(assign, nonatomic) CGFloat duration;
@end
