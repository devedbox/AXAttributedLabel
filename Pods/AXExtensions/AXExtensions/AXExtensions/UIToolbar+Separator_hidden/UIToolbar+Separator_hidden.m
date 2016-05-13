//
//  UIToolbar+Separator_hidden.m
//  AXSwift2OC
//
//  Created by ai on 9/5/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import "UIToolbar+Separator_hidden.h"

@implementation UIToolbar (Separator_hidden)
- (void)setSeparatorHidden:(BOOL)hidden {
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[UIImageView class]] && [[view subviews] count] == 0) {
            [view setHidden:hidden];
        }
    }
}
@end
