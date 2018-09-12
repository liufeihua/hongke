//
//  DiscoverCollectionViewCell.h
//  iosapp
//
//  Created by redmooc on 16/7/12.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDDiscover.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

//每行显示格子的列数
#define PerRowGridCount 4
//每列显示格子的行数
#define PerColumGridCount 6
//每个格子的宽度
#define GridWidth (ScreenWidth/PerRowGridCount)
//每个格子的高度
#define GridHeight (ScreenWidth/PerRowGridCount)
//每个格子的X轴间隔
#define PaddingX 0
//每个格子的Y轴间隔
#define PaddingY 0

@interface DiscoverCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, strong)NSIndexPath *indexPath;
-(void)configCell:(GFKDDiscover *)grid withIndexPath:(NSIndexPath *)indexPath;

@end
