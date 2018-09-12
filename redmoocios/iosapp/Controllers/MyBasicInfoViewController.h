//
//  MyBasicInfoViewController.h
//  iosapp
//
//  Created by 李萍 on 15/2/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GFKDUser;

@interface MyBasicInfoViewController : UITableViewController

- (instancetype)initWithMyInformation:(GFKDUser *)myInfo;

@end
