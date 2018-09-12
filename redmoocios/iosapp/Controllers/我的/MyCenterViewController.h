//
//  MyCenterViewController.h
//  iosapp
//
//  Created by redmooc on 16/9/7.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GFKDUser;

@interface MyCenterViewController : UIViewController

- (instancetype)initWithMyInformation:(GFKDUser *)myInfo;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *view_myComment;
@property (weak, nonatomic) IBOutlet UIView *view_myTake;
@property (weak, nonatomic) IBOutlet UIView *view_myStar;

@end
