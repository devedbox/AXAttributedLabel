//
//  AXPhotoCollectionViewCell.h
//  AXSwift2OC
//
//  Created by ai on 9/8/15.
//  Copyright © 2015 ai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXPhotoCollectionViewCell : UICollectionViewCell
/// Selected label info
@property(strong, nonatomic) UILabel *selectedLabel __deprecated;
/// Photo image view
@property(strong, nonatomic) UIImageView *photoView;
@end
