//
//  AvatarImageView.m
//  iosapp
//
//  Created by redmooc on 16/7/4.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AvatarImageView.h"
#import "UserDetailsViewController.h"
#import "Config.h"
#import "OSCAPI.h"
#import "Utils.h"
#import <MBProgressHUD.h>


@interface AvatarImageView()
{
    UIViewController *pushedViewController;
    int pushUserId;
    
}

@end

@implementation AvatarImageView

- (void) enableAvatarModeWithUserInfoDict : (int) userId pushedView : (UIViewController*) _viewController
{
    pushedViewController = _viewController;
    pushUserId = userId;
    [self getUserInfo];
    UITapGestureRecognizer *avatarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTap:)];
    [self addGestureRecognizer:avatarTapGesture];
    self.userInteractionEnabled = YES;
    
}

- (void) avatarTap : (UITapGestureRecognizer*) gesture
{
    UserDetailsViewController *userInfoVC = [[UserDetailsViewController alloc] initWithEntity:_userInfoEntity];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [pushedViewController.navigationController pushViewController:userInfoVC animated:YES];
}

- (void) getUserInfo{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_GETUSERINFO];
    parameters = @{
                   @"token": [Config getToken],
                   @"uid": @(pushUserId),
                   };
    
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  return;
              }
              _userInfoEntity = [[GFKDUser alloc] initWithDict:responseObject[@"result"]];
              
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"用户信息获取失败";
              
              [HUD hide:YES afterDelay:1];
              
          }
     ];
}

@end
