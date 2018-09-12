//
//  SideMenuViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/31/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "SideMenuViewController.h"
#import "Config.h"
#import "Utils.h"
#import "SwipableViewController.h"
//#import "PostsViewController.h"
//#import "BlogsViewController.h"
//#import "SoftwareCatalogVC.h"
//#import "SoftwareListVC.h"
#import "SettingsPage.h"
#import "LoginViewController.h"
#import "MyBasicInfoViewController.h"

#import "AppDelegate.h"

#import <RESideMenu.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <ReactiveCocoa.h>
#import "FeedbackPage.h"
#import "SearchSNSViewController.h"
#import "UIView+TopTag.h"
//#import "NewsViewController.h"
#import "AuditPageViewController.h"
#import "CommentListViewController.h"
#import "MessageCenterViewController.h"
#import "UserInfoViewController.h"
#import "PointsRuleViewController.h"
#import "AboutPage.h"
#import "WebHtmlViewController.h"

@interface SideMenuViewController ()

@property(nonatomic,strong) NSArray *cellImgs;
@property(nonatomic,strong) NSArray *cellTitles;

@end

@implementation SideMenuViewController

//static BOOL isNight;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"userRefresh" object:nil];
    
    self.tableView.bounces = NO;
    
    self.tableView.backgroundColor = [UIColor titleBarColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:@"dawnAndNight" object:nil];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
    
//    [self getBadgeNum];
    
    _cellImgs = @[@"sidemenu_QA", @"sidemenu_feedback", @"sidemenu_rule",@"sidemenu_about",@"sidemenu_erweima",@"sidemenu_site",@"sidemenu_exit"];
    _cellTitles = @[@"消息中心", @"意见反馈", @"积分规则",@"关于我们",@"扫码下载",@"设置",@"退出"];
    _hasAuditInfo = 0;
    _AuditInfoBadge = 0;
    
    [self getisAuditpermiss];
}

//- (void) viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    if (_hasAuditInfo) {
//        [self getisAuditpermiss];
//        [self reload];
//    }
//}

- (void) getBadgeNum
{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_MSG_COUNT]
          parameters:@{@"token":[Config getToken],
                       @"nodeIds":@"76"
                       }
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"badge%@",responseObject);
                 NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                 
                 NSString *errorMessage = responseObject[@"reason"];
                 
                 if (errorCode == 1) {
                     NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                     [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                     return;
                     
                 }
                 _badgeValue = [responseObject[@"result"] intValue];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                 });
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                 HUD.labelText = @"网络异常，操作失败";
                 
                 [HUD hide:YES afterDelay:1];
             }
         ];
}

- (void)dawnAndNightMode:(NSNotification *)center
{
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *usersInformation = [Config getUsersInformation];
    UIImage *portrait = [Config getPortrait];
    
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *portraitView = [UIImageView new];
    portraitView.contentMode = UIViewContentModeScaleAspectFit;
    [portraitView setCornerRadius:30];
    portraitView.userInteractionEnabled = YES;
    portraitView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:portraitView];
    
    if (portrait == nil) {
        portraitView.image = [UIImage imageNamed:@"default-portrait"];
    } else {
        portraitView.image = portrait;
    }
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = [usersInformation[1] isEqual:@""]?usersInformation[0]:usersInformation[1]; //
    nameLabel.font = [UIFont boldSystemFontOfSize:20];
    
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode){
        nameLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    } else {
        nameLabel.textColor = [UIColor colorWithHex:0x696969];
    }
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:nameLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(portraitView, nameLabel);
    NSDictionary *metrics = @{@"x": @([UIScreen mainScreen].bounds.size.width / 4 - 15)};
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[portraitView(60)]-10-[nameLabel]-15-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-x-[portraitView(60)]" options:0 metrics:metrics views:views]];
    
    portraitView.userInteractionEnabled = YES;
    nameLabel.userInteractionEnabled = YES;
    [portraitView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
    [nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
        
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _hasAuditInfo?8:7;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        UITableViewCell *cell = [UITableViewCell new];
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xCFCFCF];
        [cell setSelectedBackgroundView:selectedBackground];
    
        cell.imageView.image = [UIImage imageNamed:_cellImgs[indexPath.row]];
        cell.textLabel.text = _cellTitles[indexPath.row];
    

        cell.textLabel.font = [UIFont systemFontOfSize:19];
    
    
//    if (indexPath.row == 0) {
//        NSString *badgeStr;
//        if (_badgeValue > 0) {
//            if (_badgeValue<100) {
//                badgeStr = [@(_badgeValue) stringValue];
//                UIView *tagView = [UIView CreateTopTagNumberView:badgeStr];
//                
//                tagView.frame = CGRectMake(10 + 43 - 21, 56 / 2.0f - 43 / 2.0f, 15.0f, 15.0f);
//                [cell.contentView addSubview:tagView];
//            }else{
//                badgeStr = @"99+";
//                UIView *tagView = [UIView CreateTopTagNumberView:badgeStr];
//                
//                tagView.frame = CGRectMake(10 + 43 - 21, 56 / 2.0f - 43 / 2.0f, 25.0f, 15.0f);
//                [cell.contentView addSubview:tagView];
//            }
//        }
//        
//    }
    
    if (indexPath.row == 1) {
        if (_AuditInfoBadge > 0) {
            NSString *AuditInfoBadgeStr;
            if (_AuditInfoBadge<100) {
                AuditInfoBadgeStr = [@(_AuditInfoBadge) stringValue];
                UIView *tagView = [UIView CreateTopTagNumberView:AuditInfoBadgeStr];
                
                tagView.frame = CGRectMake(10 + 43 - 21, 56 / 2.0f - 43 / 2.0f, 15.0f, 15.0f);
                [cell.contentView addSubview:tagView];
            }else{
                AuditInfoBadgeStr = @"99+";
                UIView *tagView = [UIView CreateTopTagNumberView:AuditInfoBadgeStr];
                
                tagView.frame = CGRectMake(10 + 43 - 21, 56 / 2.0f - 43 / 2.0f, 25.0f, 15.0f);
                [cell.contentView addSubview:tagView];
            }
        }
        
    }
    
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
//            NewsViewController *VC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeMsg cateId:76  isSpecial:0];
//            VC.title = @"消息中心";
//            CommentListViewController *VC = [[CommentListViewController alloc] initWithType:0];
//            VC.title = @"消息中心";
//            [self setContentViewController:VC];
            
            MessageCenterViewController *VC = [[MessageCenterViewController alloc] init];
            VC.title = @"消息中心";
            [self setContentViewController:VC];
            break;
        }
        case 1: {
            if (_hasAuditInfo == 0) {
                [self setContentViewController:[FeedbackPage new]];
            }else{
                AuditPageViewController *VC = [[AuditPageViewController alloc] init];
                VC.title = @"待审稿件";
                
                [self setContentViewController:VC];
            }
             break;
        }
        case 2: {
            if (_hasAuditInfo == 0) {
                [self setContentViewController:[PointsRuleViewController new]];
            }else{
                [self setContentViewController:[FeedbackPage new]];
            }
            
            break;
        }
        case 3: {
            if (_hasAuditInfo == 0) {
                [self setContentViewController:[AboutPage new]];
            }else{
                [self setContentViewController:[PointsRuleViewController new]];
            }
            
            break;
        }
        case 4: {
            if (_hasAuditInfo == 0) {
                [self setContentViewController:[[WebHtmlViewController alloc] initWithTitle:@"扫码下载" WithUrl:HTML_ERWEIMA]];
                ;
            }else{
                [self setContentViewController:[AboutPage new]];
            }
            
            break;
        }
        case 5: {
            if (_hasAuditInfo == 0) {
                [self setContentViewController:[SettingsPage new]];
            }else{
                [self setContentViewController:[[WebHtmlViewController alloc] initWithTitle:@"扫码下载" WithUrl:HTML_ERWEIMA]];
            }
            
            break;
        }
        case 6: {
            if (_hasAuditInfo == 0) {
                UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否确认注销当前登录帐号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                logoutAlert.tag = 3;
                [logoutAlert show];
            }else{
                [self setContentViewController:[SettingsPage new]];
            }
            
            break;
        }
        case 7: {
            if (_hasAuditInfo == 1) {
                UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否确认注销当前登录帐号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                logoutAlert.tag = 3;
                [logoutAlert show];
            }
            
            break;
        }
        default: break;
    }
}


- (void)setContentViewController:(UIViewController *)viewController
{
    viewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
    [nav pushViewController:viewController animated:NO];    
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark - 点击登录

- (void)pushLoginPage
{
    UserInfoViewController *nVcUserInfo = [[UserInfoViewController alloc] initWithMyInformation:[Config getMyInfo]];
    nVcUserInfo.hidesBottomBarWhenPushed = YES;
    [self setContentViewController:nVcUserInfo];
//    if (![Utils isNetworkExist]) {
//        MBProgressHUD *HUD = [Utils createHUD];
//        HUD.mode = MBProgressHUDModeText;
//        HUD.labelText = @"网络无连接，请检查网络";
//        
//        [HUD hide:YES afterDelay:1];
//    } else
//    {
//    if ([Config getToken] == nil) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        [self setContentViewController:loginVC];
//    } else {
//        MyBasicInfoViewController *myVC = [[MyBasicInfoViewController alloc] initWithMyInformation:[Config getMyInfo]];
//        myVC.hidesBottomBarWhenPushed = YES;
//        [self setContentViewController:myVC];
//        return;
//    }
//    }
}

- (void)reload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

/*
 *用户是否有审核权限  m-auditpermiss.htx
 */
- (void) getisAuditpermiss
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_AUDITPERMISS]
      parameters:@{@"token":[Config getToken]
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
                 
             }
             _hasAuditInfo = [responseObject[@"result"][@"hasAuditInfo"] intValue];//total
             _AuditInfoBadge = [responseObject[@"result"][@"total"] intValue];
             if (_hasAuditInfo == 1) {
                 _cellImgs = @[@"sidemenu_QA", @"sidemenu_audit",@"sidemenu_feedback", @"sidemenu_rule",@"sidemenu_about",@"sidemenu_erweima",@"sidemenu_site",@"sidemenu_exit"];
                 _cellTitles = @[@"消息中心",@"待审稿件", @"意见反馈", @"积分规则",@"关于我们",@"扫码下载",@"设置",@"退出"];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {return;}
    
    if(alertView.tag == 3){
        //退出登录
        if (buttonIndex == 1)
        {
            //注销
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.labelText = @"正在注销";
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
            
            NSDictionary *dict = @{@"token": [Config getToken]};
            NSString *str = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_USER_CLEARTOKEN];
            
            [manager GET:str
              parameters:dict
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                     if (errorCode == 1) {
                         [HUD hide:YES];
                         NSString *errorMessage = responseObject[@"reason"];
                         NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                         [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                         return;
                     }
                     [Config reomveToken];
                     [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginViewController];
                     [HUD hide:YES afterDelay:1];
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                     HUD.labelText = @"网络异常，注销失败";
                     
                     [HUD hide:YES afterDelay:1];
                 }
             ];
            
        }
        
    }
}

@end
