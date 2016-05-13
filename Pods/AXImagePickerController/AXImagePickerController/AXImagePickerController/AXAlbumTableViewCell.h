//
//  AXAlbumTableViewCell.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef kAXAlbumTableViewCellHeight
#define kAXAlbumTableViewCellHeight 88.0
#endif
#ifndef kAXAlbumTableViewCellPadding
#define kAXAlbumTableViewCellPadding 10.0
#endif
#ifndef kAXAlbumTableViewCellLeftMargin
#define kAXAlbumTableViewCellLeftMargin 20.0
#endif

@interface AXAlbumTableViewCell : UITableViewCell
/// Album image view
@property(strong, nonatomic) UIImageView *albumView;
/// Album title label
@property(strong, nonatomic) UILabel *albumTitleLabel;
/// Album detail label
@property(strong, nonatomic) UILabel *albumDetailLabel;
/// Album selected info
@property(strong, nonatomic) UILabel *albumSelectedInfo;
@end
