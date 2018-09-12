//
//  UserInfoViewController.h
//  iosapp
//
//  Created by redmooc on 16/3/23.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GFKDUser;

@protocol UserInfoViewControllerDelegate <NSObject>

@optional

- (void) update;

@end

@interface UserInfoViewController : UITableViewController

- (instancetype)initWithMyInformation:(GFKDUser *)myInfo;

@property (nonatomic,assign) id<UserInfoViewControllerDelegate> delegate;

@end
