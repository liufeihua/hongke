//
//  AudioViewController.m
//  iosapp
//
//  Created by redmooc on 16/8/16.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AudioViewController.h"
#import "NewsBarViewController.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "GFKDTopNodes.h"

@interface AudioViewController ()

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadVideo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeByNumber.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":@"video"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             
             [self showVideo:responseObject[@"result"]];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

- (void) showVideo:(NSDictionary *)dic{
    GFKDTopNodes *topNodes = [[GFKDTopNodes alloc] initWithDict:dic];
    
    NewsBarViewController *  videoVC=[[NewsBarViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[topNodes.cateId intValue] isSpecial:0];
    [videoVC.view setFrame:self.view.bounds];
    [self addChildViewController:videoVC];
    [self.view addSubview:videoVC.view];
}

@end
