//
//  GFKDContentViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/12.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDContentViewController.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import <MBProgressHUD.h>
#import "GFKDTopNodes.h"
#import "AppDelegate.h"
#import "NewsViewController.h"
#import "SwipableViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "SideMenuViewController.h"
#import "SearchArticleViewController.h"

#import "UIView+Frame.h"
#import "NewsBarViewController.h"

#import "PushNewsMsg.h"
#import "PushWebLinkMsg.h"
#import "NewsDetailBarViewController.h"


#import "NewsTableViewPage.h"

#import "LeadViewController.h"

@interface GFKDContentViewController ()<UINavigationControllerDelegate,LeadViewControllerDelegate>
{
//    NewsViewController *newsViewCtl;//新闻
//    NewsViewController  *recommendViewCtl;//推荐
//    NewsViewController  *combineViewCtl;//综合
//    NewsViewController  *specialViewCtl;//special专题
    
}
@property(nonatomic,strong)UIButton *rightItem;
@property(nonatomic,assign,getter=isWeatherShow)BOOL weatherShow;
//@property(nonatomic,strong)SXWeatherView *weatherView;
@property(nonatomic,strong) SwipableViewController *newsVc;

@end

@implementation GFKDContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self showLeadView];
    
    [self loadTOPList];
    // Do any additional setup after loading the view.
    
//    UIButton *rightItem = [[UIButton alloc]init];
//    self.rightItem = rightItem;
//    UIWindow *win = [UIApplication sharedApplication].windows.firstObject;
//    [win addSubview:rightItem];
//    rightItem.y = 30;
//    rightItem.width = 20;
//    rightItem.height = 20;
//    [rightItem addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
//    rightItem.x = [UIScreen mainScreen].bounds.size.width - rightItem.width - 15;
//    NSLog(@"%@",NSStringFromCGRect(rightItem.frame));
//    [rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dawnAndNightMode:) name:@"dawnAndNight" object:nil];
    
    self.rightItem.hidden = NO;
    self.rightItem.alpha = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.rightItem.alpha = 1;
    }];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushMsgShow:) name:@"PUSHMSGSHOW" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"dawnAndNight" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PUSHMSGSHOW" object:nil];
    
    self.rightItem.hidden = YES;
    self.rightItem.transform = CGAffineTransformIdentity;
    [self.rightItem setImage:[UIImage imageNamed:@"top_navigation_square"] forState:UIControlStateNormal];
}

- (void)dawnAndNightMode:(NSNotification *)center
{
    //newsViewCtl.view.backgroundColor = [UIColor themeColor];
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationbarColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor titleBarColor]];
    
    SwipableViewController *newsVc = self.navigationController.viewControllers[0];
    [newsVc.titleBar setTitleButtonsColor];
    [newsVc.viewPager.controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewController *table = obj;
        [table.navigationController.navigationBar setBarTintColor:[UIColor navigationbarColor]];
        [table.tabBarController.tabBar setBarTintColor:[UIColor titleBarColor]];
        [table.tableView reloadData];
    }];
    
}



- (void) loadTOPList
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_TOP_LIST]
      parameters:@{@"token":[Config getToken]}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"loadTOPList%@",responseObject);
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             [self showTopNodes:responseObject[@"result"]];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

- (void) showTopNodes:(NSMutableArray *) array
{
    NSMutableArray *title = [[NSMutableArray alloc] init];
    [title addObject:@"推荐"];
//    int newsId = 0;
//    int specialId = 0;
//    int combineId = 0;
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    [controllers addObject:[[NewsBarViewController alloc]  initWithNewsListType:NewsListTypeHomeNews cateId:0  isSpecial:0]];//推荐controller
 
    for (int i=0; i<array.count ; i++) {
        GFKDTopNodes *topNodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
        [title addObject:topNodes.cateName];
        [controllers addObject:[[NewsBarViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[topNodes.cateId intValue] isSpecial:0]];
        
//        if (i == 0) {
//            newsId = [topNodes.cateId intValue];
//        }else if(i == 1){
//            specialId = [topNodes.cateId intValue];
//        }else if(i == 2){
//            combineId = [topNodes.cateId intValue];
//        }
    }
    
    
//    recommendViewCtl = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeHomeNews cateId:0  isSpecial:0];
//    newsViewCtl = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:newsId isSpecial:0];
//    specialViewCtl = [[NewsViewController alloc] initWithNewsListType:NewsListTypeSpecial cateId:specialId isSpecial:1];
//    combineViewCtl = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:combineId isSpecial:0];
    
//    SwipableViewController *newsSVC = [[SwipableViewController alloc] initWithTitle:@""
//                                                                       andSubTitles:title
//                                                                     andControllers:@[recommendViewCtl, newsViewCtl, specialViewCtl,combineViewCtl]
//                                                                        underTabbar:NO];
//        SwipableViewController *newsSVC = [[SwipableViewController alloc] initWithTitle:@""
//                                                                           andSubTitles:title
//                                                                         andControllers:controllers
//                                                                            underTabbar:NO];
    _newsVc = [[SwipableViewController alloc] initWithTitle:@""
                                                                       andSubTitles:title
                                                                     andControllers:controllers
                                                                        underTabbar:NO];


    UINavigationController *nav = [self addNavigationItemForViewController:_newsVc];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
   
    //newsSVC.childViewControllers
   // [self.view addSubview:[self addNavigationItemForViewController:newsSVC].view];
}

- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    UIImage *logoImage = [UIImage imageNamed:@"gfkd_logo"];
    CGFloat imageW = logoImage.size.width*36.0/logoImage.size.height;
    CGFloat imageH = 36;
    CGFloat x = kNBR_SCREEN_W/2.0 - imageW/2.0;
    CGFloat y = 0;
    UIView *titleView = [[UIView alloc] init];
    [titleView setFrame:CGRectMake(x, y, imageW, imageH)];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,imageW,imageH)];
    [logoImageView setImage:logoImage];
    [titleView addSubview:logoImageView];
    
    viewController.navigationItem.titleView = titleView;
    
    
    viewController.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_sidebar"]
                                                                                        style:UIBarButtonItemStylePlain
                                                                                       target:self action:@selector(onClickMenuButton)];
    

//    viewController.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"top_navigation_square"]
//                                                                                        style:UIBarButtonItemStylePlain
//                                                                                       target:self action:@selector(rightItemClick)];
    
    
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                     target:self
                                                                                                     action:@selector(pushSearchViewController)];
    
    
    
    return navigationController;
}

- (void)onClickMenuButton
{
    [self.sideMenuViewController presentLeftMenuViewController];
    //点击进入侧滑页时 刷新一下消息数目
    SideMenuViewController *sideMenuVC =  (SideMenuViewController *)((RESideMenu *)(self.view.window.rootViewController)).leftMenuViewController;
    //[sideMenuVC getBadgeNum];
    if (sideMenuVC.hasAuditInfo != 0) {
        [sideMenuVC getisAuditpermiss];
    }
}


#pragma mark - 处理左右navigationItem点击事件

- (void)pushSearchViewController
{
   // [(UINavigationController *)self.selectedViewController pushViewController:[SearchViewController new] animated:YES];

   // SearchArticleViewController *VC = [[SearchArticleViewController alloc] init];
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    UIViewController * VC = nav.childViewControllers[0];
    
    [VC.navigationController pushViewController:[SearchArticleViewController new] animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)pushMsgShow:(NSNotification *)notification
{
    NSLog(@"pushMsgShow--NewsBarViewController");
    
    //调用NewsVIewController中的pushMsgShow
    NewsBarViewController * newsBarVc = (NewsBarViewController *)[_newsVc.viewPager.controllers objectAtIndex:_newsVc.viewPager.currentIndex];
    [newsBarVc.newsVC pushMsgShow:notification];
    
}


@end
