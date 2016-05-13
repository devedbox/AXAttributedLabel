//
//  UILabel+Pop.m
//  AXExtensions
//
//  Created by ai on 16/5/9.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "UILabel+Pop.h"
#import <pop/POP.h>
#import <objc/runtime.h>

@implementation UILabel(Pop)

- (CGFloat)speed {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setSpeed:(CGFloat)speed {
    objc_setAssociatedObject(self, @selector(speed), @(speed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)duration {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setDuration:(CGFloat)duration {
    objc_setAssociatedObject(self, @selector(duration), @(duration), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)pop_setText:(NSString *)text {
    NSTimeInterval duration = self.duration;
    NSTimeInterval perSpeed = self.speed;
    NSInteger __block count = 0;
    
    POPAnimatableProperty * nameProp = [POPAnimatableProperty propertyWithName:@"count" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = MIN(++count, text.length);
        };
        // write value
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setText:[text substringWithRange:NSMakeRange(0, values[0])]];
        };
        // dynamics threshold
        prop.threshold = 0.01;
    }];
    
    if (perSpeed > 0) {
        duration = perSpeed*text.length;
    }
    POPBasicAnimation *nameAnim = [POPBasicAnimation animation];
    nameAnim.duration = duration;
    nameAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    nameAnim.property = nameProp;
    nameAnim.fromValue = @(0);
    nameAnim.toValue = @(text.length);
    
    [self pop_removeAllAnimations];
    [self pop_addAnimation:nameAnim forKey:@"counting"];
}

@end