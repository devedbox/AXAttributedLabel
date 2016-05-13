//
//  AXTableView.h
//  AXExtensions
//
//  Created by ai on 16/3/11.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "AXScrollView.h"

@class AXTableView;
@protocol AXTableViewDelegate <NSObject>
@required
- (void)tableViewRefreshData:(AXTableView *)tableView;
- (void)tableViewMoreData:(AXTableView *)tableView;
@end

@interface AXTableView : UITableView
/// Refresh delegate
@property(assign, nonatomic) IBOutlet id<AXTableViewDelegate>refreshDelegate;
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