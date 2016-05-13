//
//  AXCollectionView.m
//  AXExtensions
//
//  Created by ai on 16/3/11.
//  Copyright © 2016年 AiXing. All rights reserved.
//

#import "AXCollectionView.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>

@implementation AXCollectionView
#pragma mark - Life cycle

- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)initializer {
    _maxLoadTimeOfRefresh = 10.f;
    self.refreshFooterEnabled = YES;
    self.refreshHeaderEnabled = YES;
}

#pragma mark - public
- (void)refreshData {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(collectionViewRefreshData:)]) {
        [_refreshDelegate collectionViewRefreshData:self];
    }
    [self performSelector:@selector(endRefreshHeader) withObject:nil afterDelay:_maxLoadTimeOfRefresh];
}

- (void)moreData {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(collectionViewMoreData:)]) {
        [_refreshDelegate collectionViewMoreData:self];
    }
    [self performSelector:@selector(endRefreshFooter) withObject:nil afterDelay:_maxLoadTimeOfRefresh / 2];
}

- (void)endRefreshHeader {
    if (self.mj_header.isRefreshing) {
        [self.mj_header endRefreshing];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)endRefreshFooter {
    if (self.mj_footer.isRefreshing) {
        [self.mj_footer endRefreshing];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setRefreshHeaderEnabled:(BOOL)refreshHeaderEnabled {
    _refreshHeaderEnabled = refreshHeaderEnabled;
    if (_refreshHeaderEnabled) {
        __weak typeof(self) wself = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [wself refreshData];
        }];
        header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:12.f];
        header.stateLabel.font = [UIFont systemFontOfSize:12.f];
        self.mj_header = header;
    } else {
        self.mj_header = nil;
    }
}

- (void)setRefreshFooterEnabled:(BOOL)refreshFooterEnabled {
    _refreshFooterEnabled = refreshFooterEnabled;
    if (_refreshFooterEnabled) {
        __weak typeof(self) wself = self;
        MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [wself moreData];
        }];
        footer.stateLabel.font = [UIFont systemFontOfSize:12.f];
        self.mj_footer = footer;
    } else {
        self.mj_footer = nil;
    }
}

@end