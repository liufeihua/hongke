//
//  DiscoverCollectionViewCell.m
//  iosapp
//
//  Created by redmooc on 16/7/12.
//  Copyright © 2016年 redmooc. All rights reserved.
//
#define RGBA(r,g,b,a)      [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]
#import "DiscoverCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "Utils.h"

@implementation DiscoverCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self confingSubViews];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)confingSubViews{

    //UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    //[bgImgView setImage:[UIImage imageNamed:@"app_item_bg"]];
    //[self.contentView addSubview:bgImgView];
    
   //[self setFrame:CGRectMake(0, 0, self.contentView.frame.size.width+0.45, self.contentView.frame.size.height+0.45)];
//    self.contentView.layer.borderColor = ZWCollectionViewFlowLayout;;
//    self.contentView.layer.borderWidth = 0.3;
    float topX = (self.contentView.frame.size.height - 26 -20 -10 )/2.0;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/2-13, topX, 26 , 26)];
    [self.contentView addSubview:self.imageView];
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 36 + topX, self.contentView.frame.size.width, 20)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    
    [self.contentView addSubview:self.titleLabel];
}

-(void)configCell:(GFKDDiscover *)grid withIndexPath:(NSIndexPath *)indexPath{
    self.indexPath = indexPath;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:grid.image] placeholderImage:[UIImage imageNamed:@"item_default"]];
    self.titleLabel.text = grid.name;

}


@end
