//
//  TimeAlbumTableViewCell.m
//  iosapp
//
//  Created by redmooc on 2018/11/6.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "TimeAlbumTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "OSCAPI.h"

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
    
    [_image_photo sd_setImageWithURL:[NSURL URLWithString:entity.photo] placeholderImage:[UIImage imageNamed:@"default-portrait"]];
    _label_userName.textColor = kNBR_ProjectColor;
    _label_userName.text = entity.username;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:entity.createTime];
    
    NSString *DatesString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [date timeAgoSinceNow]];
    _label_time.textColor = [UIColor grayColor];
    _label_time.attributedText = [[NSAttributedString alloc] initWithString:DatesString
                                                                     attributes:@{
                                                                                  NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                  }];
}

@end
