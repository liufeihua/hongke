//
//  TimeAlbumTableViewCell.h
//  iosapp
//
//  Created by redmooc on 2018/11/6.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDTakes.h"

@interface TimeAlbumTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UIImageView *image_photo;
@property (weak, nonatomic) IBOutlet UILabel *label_userName;

@property (weak, nonatomic) IBOutlet UILabel *label_time;

- (void) setDateEntity : (GFKDTakes*) _dateEntity;

@end
