//
//  UINavigationBar+Separator_hidden.m
//  AXSwift2OC
//
//  Created by ai on 9/5/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "UINavigationBar+Separator_hidden.h"

@implementation UINavigationBar (Separator_hidden)
- (void)setSeparatorHidden:(BOOL)hidden {
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[UIImageView class]] && [[view subviews] count] > 0) {
            for (UIView *separator in view.subviews) {
                if ([separator isKindOfClass:[UIImageView class]]) {
                    [separator setHidden:hidden];
                }
            }
        }
    }
}
@end
