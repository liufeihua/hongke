//
//  UserDetailsViewController.h
//  iosapp
//
//  Created by redmooc on 16/7/4.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDUser.h"

@interface UserDetailsViewController : UIViewController
{
    UITableView *myTableview;
    NSMutableArray *leftArr;
    NSMutableArray *rightArr;
}

@property (nonatomic, strong)  GFKDUser *userInfoEntity;

- (instancetype)initWithEntity:(GFKDUser *)entity;

@end
