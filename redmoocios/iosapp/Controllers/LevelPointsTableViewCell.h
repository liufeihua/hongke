//
//  LevelPointsTableViewCell.h
//  iosapp
//
//  Created by redmooc on 16/8/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString  *kLevelPointsTableViewCell=@"LevelPointsTableViewCell";

@interface LevelPointsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_name;

@property (weak, nonatomic) IBOutlet UILabel *label_minPoints;
@property (weak, nonatomic) IBOutlet UIImageView *image_rule;


@end
