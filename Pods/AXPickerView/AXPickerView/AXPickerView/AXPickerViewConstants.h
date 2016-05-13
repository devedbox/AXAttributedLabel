//
//  AXPickerViewConstants.h
//  AXPickerView
//
//  Created by xing Ai on 9/6/15.
//  Copyright (c) 2015 xing Ai. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#ifndef AXPickerViewConstants_h
#define AXPickerViewConstants_h


#endif /* AXPickerViewConstants_h */

#ifndef kAXDefaultTintColor
#define kAXDefaultTintColor [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1.000]
#endif
#ifndef kAXDefaultSelectedColor
#define kAXDefaultSelectedColor [UIColor colorWithRed:0.294 green:0.808 blue:0.478 alpha:1.000]
#endif
#ifndef kAXDefaultSeparatorColor
#define kAXDefaultSeparatorColor [UIColor colorWithRed:0.824 green:0.824 blue:0.824 alpha:1.000]
#endif
#ifndef kAXDefaultBackgroundColor
#define kAXDefaultBackgroundColor [UIColor colorWithRed:0.965 green:0.965 blue:0.965 alpha:0.700]
#endif
#ifndef kAXPickerToolBarHeight
#define kAXPickerToolBarHeight 44.0f
#endif
#ifndef kAXPickerHeight
#define kAXPickerHeight 216.0f
#endif
#define kPadding 5.0f
#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.1
#endif
#ifndef EXECUTE_ON_MAIN_THREAD
#define EXECUTE_ON_MAIN_THREAD(block) \
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif