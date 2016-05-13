//
//  AXPickerContentView.h
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
#import "AXPickerCollectionViewCell.h"
#import <AXCollectionViewFlowLayout/AXCollectionViewFlowLayout.h>

@class AXPickerContentView;

@protocol AXPickerContentViewDelegate <NSObject>
@optional
- (void)contentViewDidTouchBackground:(AXPickerContentView *)contentView;
- (void)contentViewDidReachLimitedVelocity:(AXPickerContentView *)contentView;
@end

@protocol AXPickerContentViewDataSource <NSObject>
@required
- (NSInteger)ax_collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (AXPickerCollectionViewCell *)ax_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

extern NSString *const kAXPickerContentViewReuseIdentifier;

@interface AXPickerContentView : UIView
/// Delegate
@property(assign, nonatomic) id<AXPickerContentViewDelegate>delegate;
/// DataSoure
@property(assign, nonatomic) id<AXPickerContentViewDataSource>dataSource;
/// Content insets, default is UIEdgeInsetsZero
@property(assign, nonatomic) UIEdgeInsets contentInsets;
/// Content view
@property(readonly, nonatomic) UIView *contentView;
/*!
 *  Reload data of images
 */
- (void)reloadData;
- (void)selectIndexPath:(NSIndexPath *)indexPath;
@end
