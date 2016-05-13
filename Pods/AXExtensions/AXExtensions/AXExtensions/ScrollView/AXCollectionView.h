//
//  AXCollectionView.h
//  AXExtensions
//
//  Created by ai on 16/3/11.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "AXScrollView.h"

@class AXCollectionView;
@protocol AXCollectionViewDelegate <NSObject>
@required
- (void)collectionViewRefreshData:(AXCollectionView *)collectionView;
- (void)collectionViewMoreData:(AXCollectionView *)collectionView;
@end

@interface AXCollectionView : UICollectionView
/// Refresh delegate
@property(assign, nonatomic) IBOutlet id<AXCollectionViewDelegate>refreshDelegate;
/// max load time of refresh, default 10.f
@property(assign, nonatomic) IBInspectable CGFloat maxLoadTimeOfRefresh;
/// Refresh header enabled, Default is YES.
@property(assign, nonatomic) IBInspectable BOOL refreshHeaderEnabled;
/// Refresh footer enabled, Default is YES.
@property(assign, nonatomic) IBInspectable BOOL refreshFooterEnabled;
/// Refresh data
- (void)refreshData;
/// Load more data
- (void)moreData;
/// End header refreshing.
- (void)endRefreshHeader;
/// End footer refreshing.
- (void)endRefreshFooter;
@end