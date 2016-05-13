//
//  AXPickerCollectionViewCell.h
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

#import <UIKit/UIKit.h>

@class AXPickerCollectionViewCell;

@protocol AXPickerCollectionViewCellDelegate <NSObject>
- (void)collectionViewCellDidBeginDraging:(AXPickerCollectionViewCell *)cell;
- (void)collectionViewCell:(AXPickerCollectionViewCell *)cell didMoveToPoint:(CGPoint)location;
- (void)collectionViewCellDidStopDraging:(AXPickerCollectionViewCell *)cell;
@end

@interface AXPickerCollectionViewCell : UICollectionViewCell
/// Delegate
@property(assign, nonatomic) id<AXPickerCollectionViewCellDelegate>delegate;
/// Image view
@property(strong, nonatomic) UIImageView *imageView;
/// Index path
@property(strong, nonatomic) NSIndexPath *indexPath;
@end
