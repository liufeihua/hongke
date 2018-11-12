//
//  TimeAlbumTableViewCell.m
//  iosapp
//
//  Created by redmooc on 2018/11/6.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "TimeAlbumTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TimeAlbumTableViewCell
{
    GFKDTakes       *entity;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setDateEntity : (GFKDTakes*) _dateEntity
{
    entity = _dateEntity;
    if (entity.images.count > 0) {
        [_image sd_setImageWithURL:[NSURL URLWithString:entity.images[0]] placeholderImage:[UIImage imageNamed:@"item_default"]];
    }
    _label_title.text = entity.title;
}

@end
