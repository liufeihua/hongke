//
//  OSCTabBarController.m
//  iosapp
//
//  Created by chenhaoxiang on 12/15/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "GFKDTabBarController.h"
#import "SwipableViewController.h"
#import "NewsViewController.h"
#import "LoginViewController.h"
#import "Config.h"
#import "Utils.h"
#import "OptionButton.h"
#import "UIView+Util.h"
#import "SearchArticleViewController.h"
#import "UIBarButtonItem+Badge.h"

#import <RESideMenu/RESideMenu.h>

#import <MBProgressHUD.h>
#import "GFKDTopNodes.h"
#import "AppDelegate.h"
#import "NewsBarViewController.h"
#import "SideMenuViewController.h"
//#import "MyBasicInfoViewController.h"
#import "SearchSNSViewController.h"
#import "TakesViewController.h"
#import "CommentListViewController.h"
#import "LeadViewController.h"
#import "TakesTabViewController.h"
#import "SXMainViewController.h"
#import "NewsTableViewPage.h"
#import "NYSegmentedControl.h"
#import "DiscoverViewController.h"
#import "Audio_VisualViewController.h"
#import "XHLaunchAd.h"
#import "MyCenterViewController.h"

#import "NewsSegmentedViewController.h"
#import "JRSegmentViewController.h"
#import "STTabViewController.h"
#import "ZGViewController.h"
#import "ZTCViewController.h"

#import "PushWebLinkMsg.h"
#import "PushNewsMsg.h"
#import "NewsImagesViewController.h"
#import "NewsDetailBarViewController.h"
#import "VideoDetailAuditBarViewController.h"
#import "NewsDetailAuditBarViewController.h"
#import "CYWebViewController.h"
#import "SXMenuViewController.h"

#import "UIView+HAMUtils.h"

#import "StudySchoolViewController.h"

//#import "StudyHomeViewController.h"


@interface GFKDTabBarController () <UITabBarControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,LeadViewControllerDelegate,JRSegmentViewControllerDelegate>
{
    SXMenuViewController *newsMenu;
    TakesTabViewController *takeVC;
    JRSegmentViewController *segmentVC;
    ZTCViewController *ZTC_VC;
    DiscoverViewController *discover;
    MyCenterViewController *myVC;
    NSArray *subButtons;
    NYSegmentedControl *segmentControl;
}

@property (nonatomic, assign) BOOL isPressed;
//@property (nonatomic, strong) TakesViewController *takeView;

@end

@implementation GFKDTabBarController


- (void) loadTOPList
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_TOP_LIST]
      parameters:@{@"token":[Config getToken],
                   @"siteId":@(0),
                   @"type":@(1)
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSLog(@"%@",responseObject);
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             
             NSArray * array = [NSArray arrayWithArray:responseObject[@"result"]];
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             [userDefaults setObject:array forKey:@"nodeDic"];
             
             [self showTopNodes:responseObject[@"result"]];
  
             /*
             NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
             NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[user objectForKey:@"nodeDic"]];
             //[user objectForKey:@"nodeDic"];
             
             
             NSArray * array = responseObject[@"result"];
             
             if (array.count != mutableArray.count){
                 [user setObject:array forKey:@"nodeDic"];
                 [self showTopNodes:responseObject[@"result"]];
                 return;
             }else{
                 for (int i=0;i<array.count;i++){
                     GFKDTopNodes *topNodes1 = [[GFKDTopNodes alloc] initWithDict:array[i]];
                     GFKDTopNodes *topNodes2 = [[GFKDTopNodes alloc] initWithDict:mutableArray[i]];
                     
                     if ([topNodes1 isEqual:topNodes2]) {
                         
                         NSLog(@"BHT isEqualToSet work");
                         
                     }
                 }
             }
             
             if (!([array hash] == [mutableArray hash])){
             //if (![array isEqualToArray:mutableArray]) {  //isEuqalToArray返回结果有时不对 可能与内存地址有关
                 [user setObject:array forKey:@"nodeDic"];
                 [self showTopNodes:responseObject[@"result"]];
             }*/
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
}

-(void) configVC{
    //ZTC_VC = [[ZTCViewController alloc] init];  //直通车
    takeVC =[[TakesTabViewController alloc] init];//圈子
    myVC = [[MyCenterViewController alloc] initWithMyInformation:[Config getMyInfo]]; //个人中心
    discover = [[DiscoverViewController alloc] init]; //发现
    self.delegate=self;
    
    if ((((AppDelegate *)[UIApplication sharedApplication].delegate).uiConfig != nil) && (((AppDelegate *)[UIApplication sharedApplication].delegate).uiConfig.dataDict != nil)) {
        ZGViewController *ZGVC = [[ZGViewController alloc] init];
        self.viewControllers=@[[self addNavigationItemForViewController:segmentVC withRightButtonIndex:0],
                               [self addNavigationItemForViewController:takeVC withRightButtonIndex:1],
                               [self addNavigationItemForViewController:ZGVC withRightButtonIndex:3],
                               [self addNavigationItemForViewController:discover withRightButtonIndex:0],
                               [self addNavigationItemForViewController:myVC withRightButtonIndex:0]];
        
        GFKDUIConfig *uiConfig = ((AppDelegate *)[UIApplication sharedApplication].delegate).uiConfig;
        subButtons = [NSArray arrayWithObjects:[UIButton buttonWithType:UIButtonTypeCustom],[UIButton buttonWithType:UIButtonTypeCustom],[UIButton buttonWithType:UIButtonTypeCustom],[UIButton buttonWithType:UIButtonTypeCustom],[UIButton buttonWithType:UIButtonTypeCustom], nil];
        
        [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
            UIButton *subButton = subButtons[idx];
            //CGSize buttonSize = CGSizeMake(35, 35); //tabbar H=49
            CGFloat imageHeight = 65;
            //CGFloat imageHeight = 35;
            CGFloat buttonWidth = kNBR_SCREEN_W/5.0;
            CGFloat barHeight = self.tabBar.mj_h;
            subButton.frame = CGRectMake(idx*buttonWidth,0, buttonWidth, self.tabBar.mj_h);
            if (imageHeight>barHeight) {
                subButton.imageEdgeInsets = UIEdgeInsetsMake(barHeight-imageHeight, (buttonWidth-imageHeight)/2.0, 0, (buttonWidth-imageHeight)/2.0);
            }else{
                subButton.imageEdgeInsets = UIEdgeInsetsMake((barHeight-imageHeight)/2.0, (buttonWidth-imageHeight)/2.0, (barHeight-imageHeight)/2.0, (buttonWidth-imageHeight)/2.0);
            }
            [subButton setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:uiConfig.bottomItemIcons[idx]]]] forState:UIControlStateNormal];
            [subButton setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:uiConfig.bottomFocusItemIcons[idx]]]] forState:UIControlStateSelected];
            [subButton addTarget:self action:@selector(showTabVC:) forControlEvents:UIControlEventTouchUpInside];
            subButton.tag = idx;
            if (idx == 0){
                [subButton setSelected:YES];
            }else{
                [subButton setSelected:NO];
            }
            [self.tabBar addSubview:subButton];
            [item setEnabled:NO];

        }];
        
        //uiConfig.bottomBgColor;
        //[[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1.0]];
        
        UIImage *bottomBgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:uiConfig.bottomBgImage]]];
        UIGraphicsBeginImageContext(CGSizeMake(self.tabBar.mj_w, self.tabBar.mj_h));
        [bottomBgImage drawInRect:CGRectMake(0, 0, self.tabBar.mj_w, self.tabBar.mj_h)];
        UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [[UITabBar appearance] setBackgroundImage:reSizeImage];
        
    }else{
        self.viewControllers=@[[self addNavigationItemForViewController:segmentVC withRightButtonIndex:0],
                               [self addNavigationItemForViewController:takeVC withRightButtonIndex:1],
                               [UIViewController new],
                               [self addNavigationItemForViewController:discover withRightButtonIndex:0],
                               [self addNavigationItemForViewController:myVC withRightButtonIndex:0]];
//        NSArray *titles = @[@"首页", @"直通车",@"", @"发现", @"我的"];
//        NSArray *images = @[@"tabbar-xw", @"tabbar-ztc",@"", @"tabbar-fx", @"tabbar-my"];
        NSArray *titles = @[@"首页", @"圈子",@"", @"发现", @"我的"];
        NSArray *images = @[@"tabbar-xw", @"tabbar-take",@"", @"tabbar-fx", @"tabbar-my"];
        [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger idx, BOOL *stop) {
            [item setTitle:titles[idx]];
            [item setImage:[UIImage imageNamed:images[idx]]];
            [item setSelectedImage:[UIImage imageNamed:[images[idx] stringByAppendingString:@"-selected"]]];
        }];
        [self.tabBar setBackgroundColor:[UIColor clearColor]];
        //    [self.tabBar.items[2] setImage:[UIImage imageNamed:@"tabbar-ssp-1"]];
        //    [self.tabBar.items[2] setImageInsets:UIEdgeInsetsMake(5 , 0 , -5, 0)];
        //    self.tabBar.items[2] setTitlePositionAdjustment:]
        [self.tabBar.items[2] setEnabled:NO];
        
        [self addCenterButtonWithImage:[UIImage imageNamed:@"tabbar-yzg"]];
    }
}

- (void) showTopNodes:(NSMutableArray *) array
{
    //每次启动时从后台读取栏目信息 导致加载界面白屏一段时间
    NSMutableArray *title = [[NSMutableArray alloc] init];
    [title addObject:@"推荐"];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    [controllers addObject:[[NewsBarViewController alloc]  initWithNewsListType:NewsListTypeHomeNews cateId:0  isSpecial:0]];//推荐controller
    for (int i=0; i<array.count ; i++) {
        GFKDTopNodes *topNodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
        [title addObject:topNodes.cateName];
        if ([topNodes.terminated intValue] == 1){ //没有子栏目了
            [controllers addObject:[[NewsBarViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[topNodes.cateId intValue] isSpecial:0]];
        }else{
            [controllers addObject: [[StudySchoolViewController alloc] initWithParentId:topNodes.cateId WithNav:YES]];
        }
    }
    
        newsMenu = [[SXMenuViewController alloc] initWithTitle:@"" andSubTitles:title andControllers:controllers underTabbar:YES];
        STTabViewController *STVC =[[STTabViewController alloc] init];
    
        //StudyHomeViewController *studyHomeVC = [[StudyHomeViewController alloc] init];
        //takeVC =[[TakesTabViewController alloc] init];
        StudySchoolViewController *studySchoolVC = [[StudySchoolViewController alloc] initWithNumber:@"dsh" WithNav:YES];
    
        segmentVC = [[JRSegmentViewController alloc] init];
        segmentVC.segmentBgColor = kNBR_ProjectColor;
        segmentVC.indicatorViewColor = [UIColor whiteColor];
        segmentVC.titleColor = [UIColor whiteColor];
        segmentVC.delegate = self;
        //[segmentVC setViewControllers:@[newsMenu, STVC, takeVC]];
        //[segmentVC setTitles:@[@"红讯",@"视听", @"圈子"]];
        [segmentVC setViewControllers:@[newsMenu, STVC, studySchoolVC]];
        [segmentVC setTitles:@[@"红讯",@"视听", @"悦读"]];
        
        [self configVC];
    
//    segmentControl = [[NYSegmentedControl alloc] initWithItems:@[@"红讯",@"视听", @"圈子"]];
//    segmentControl.titleTextColor = [UIColor whiteColor];
//    segmentControl.selectedTitleTextColor = kNBR_ProjectColor;
//    segmentControl.selectedTitleFont = [UIFont systemFontOfSize:13.0f];
//    segmentControl.segmentIndicatorBackgroundColor = [UIColor whiteColor];
//    segmentControl.backgroundColor = kNBR_ProjectColor;
//    segmentControl.borderWidth = 0.0f;
//    segmentControl.segmentIndicatorBorderWidth = 0.0f;
//    segmentControl.segmentIndicatorInset = 1.0f;
//    segmentControl.segmentIndicatorBorderColor = self.view.backgroundColor;
//    [segmentControl addTarget:self action:@selector(segmentSelect:) forControlEvents:UIControlEventValueChanged];
//    [segmentControl sizeToFit];
//    self.navigationItem.titleView = segmentControl;
    
}

-(void)showTabVC:(UIButton *)sender{
    int idex = (int)sender.tag;
    self.selectedViewController = self.viewControllers[idex];
    for (int i=0; i<subButtons.count; i++) {
        if (i == idex) {
            ((UIButton *)subButtons[i]).selected = YES;
        }else{
            ((UIButton *)subButtons[i]).selected = NO;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor themeColor];
    
    [self loadTOPList];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"nodeDic"]!=nil){
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[user objectForKey:@"nodeDic"]];

        [self showTopNodes:mutableArray];
    }

}


#pragma mark -JRSegmentViewControllerDelegate
- (void) didSelectedIndex:(NSInteger)index
{
    segmentVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch                                                                                          target:self action:@selector(pushSearchViewController)];
//    switch (index) {
//        case 0:
//        {
//            segmentVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                                                                        target:self
//                                                                                                        action:@selector(pushSearchViewController)];
//        }
//            break;
//        case 1:
//        {
//            segmentVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                                                                        target:self
//                                                                                                        action:@selector(pushSearchViewController)];
//        }
//            break;
//        case 2:
//        {
//            [segmentVC.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_take_1"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickAddMenuButton)]];
//        }
//            break;
//
//        default:
//            break;
//    }
}

#pragma mark -

- (UINavigationController *)addNavigationItemForViewController:(UIViewController *)viewController withRightButtonIndex:(int) buttonIndex;
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    if (buttonIndex == 3) {
        viewController.navigationItem.title = @"E政工";
    }else{
        UIImage *logoImage = [UIImage imageNamed:@"red_mooc_logo"];
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
        
        if (buttonIndex == 1){
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_take_1"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickAddMenuButton)];
        }else{
            viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                                                                                                       target:self
                                                                                                                                                                         action:@selector(pushSearchViewController)];
      }
    }
    
//    if (buttonIndex == 0) {
//        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                                                                         target:self
//                                                                                                         action:@selector(pushSearchViewController)];
//    }else if(buttonIndex == 1){
//        viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_take_1"] style:UIBarButtonItemStylePlain target:self action:@selector(onClickAddMenuButton)];
//    }
    
    return navigationController;
}



#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
//    if (self.selectedIndex <= 1 && self.selectedIndex == [tabBar.items indexOfObject:item]) {
//        SwipableViewController *swipeableVC = (SwipableViewController *)((UINavigationController *)self.selectedViewController).viewControllers[0];
//        GFKDObjsViewController *objsViewController = (GFKDObjsViewController *)swipeableVC.viewPager.childViewControllers[swipeableVC.titleBar.currentIndex];
//        
//        [UIView animateWithDuration:0.1 animations:^{
//            [objsViewController.tableView setContentOffset:CGPointMake(0, -objsViewController.refreshControl.frame.size.height)];
//        } completion:^(BOOL finished) {
//            [objsViewController.tableView.mj_header beginRefreshing];
//        }];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [objsViewController refresh];
//        });
//    }
}

#pragma mark - 处理左右navigationItem点击事件

- (void)onClickMenuButton
{
    GFKDUser *user = [Config getMyInfo];
    if ([user.userType intValue] < 10) {
        [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginViewController];
        return;
    }
    [self.sideMenuViewController presentLeftMenuViewController];
    //点击进入侧滑页时 刷新一下消息数目
    SideMenuViewController *sideMenuVC =  (SideMenuViewController *)((RESideMenu *)(self.view.window.rootViewController)).leftMenuViewController;
    //[sideMenuVC getBadgeNum];
    if (sideMenuVC.hasAuditInfo != 0) {
        [sideMenuVC getisAuditpermiss];
    }
}

- (void)onClickAddMenuButton{
    [takeVC addTake];
    //[_takeView addTake];
}

- (void)pushSearchViewController
{
    SearchArticleViewController *VC = [SearchArticleViewController new];
    VC.hidesBottomBarWhenPushed = YES;
    [(UINavigationController *)self.selectedViewController pushViewController:VC animated:YES];
}


- (void)introDidFinish {
    
//    if (Pushdic) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送" message:[Pushdic objectForKey:@"alert"] delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"确定", nil];
//        alert.tag = 110;
//        [alert show];
//    }
}


//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
//    if ([keyPath isEqualToString:@"selectedItem"]) {
//        if(self.isPressed) {[self buttonPressed];}
//    }
//}


-(void)addCenterButtonWithImage:(UIImage *)buttonImage
{
    _centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGPoint origin = [self.view convertPoint:self.tabBar.center toView:self.tabBar];
    // button 53 * 35    tabbar H= 49
    CGSize buttonSize = CGSizeMake(53, 35);
    //CGSize buttonSize = CGSizeMake(self.tabBar.frame.size.width / 5 - 6, self.tabBar.frame.size.height - 4);
    
    _centerButton.frame = CGRectMake(origin.x - buttonSize.width/2, origin.y - buttonSize.height/2, buttonSize.width, buttonSize.height);
    
    //[_centerButton setCornerRadius:buttonSize.height/2];
    //[_centerButton setBackgroundColor:[UIColor colorWithHex:0xE03F3A]];
    [_centerButton setImage:buttonImage forState:UIControlStateNormal];
    [_centerButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:_centerButton];
}

-(void) buttonPressed:(id)sender{
    ZGViewController *ZGVC = [[ZGViewController alloc] init];
    ZGVC.hidesBottomBarWhenPushed = YES;
    [self addNavigationItemForViewController:ZGVC withRightButtonIndex:3];
    [(UINavigationController *)self.selectedViewController pushViewController:ZGVC animated:YES];
    
//    DiscoverViewController *discover = [[DiscoverViewController alloc] init];
//    discover.hidesBottomBarWhenPushed = YES;
//    [self addNavigationItemForViewController:discover withRightButtonIndex:3];
    
//    [(UINavigationController *)self.selectedViewController pushViewController:discover animated:YES];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushMsgShow:) name:@"PUSHMSGSHOW" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PUSHMSGSHOW" object:nil];
}

- (void)pushMsgShow:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    NSDictionary *dictMsgBody = [self dictionaryWithJsonString:dict[@"msgBody"]];
    //NSNumber *articleId = dictMsgBody[@"articleId"];
    // NSNumber *msgType = dict[@"msgType"];
    NSString *msgType = dict[@"msgType"];
    
    if ([msgType intValue] == 0) {
        PushWebLinkMsg *webLinkMsg = [[PushWebLinkMsg alloc] initWithDict:dictMsgBody];
        
        NSString *newUrl = [Utils replaceWithUrl:webLinkMsg.webUrl];
        CYWebViewController *webViewController = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:newUrl]];
        webViewController.hidesBottomBarWhenPushed = YES;
        webViewController.navigationButtonsHidden = YES;
        webViewController.loadingBarTintColor = [UIColor redColor];
        [(UINavigationController *)self.selectedViewController pushViewController:webViewController animated:YES];
        return;
        
        
    }else if ([msgType intValue] == 1)
    {
        PushNewsMsg *newsMsg = [[PushNewsMsg alloc] initWithDict:dictMsgBody];
        /* showType 为1 类型的下的新闻资讯类型小类型：
         * 消息类型，0 ：普通新闻  1 ：图集，  2   ： 视频
         *
         */
        //NSNumber *showtype = dict[@"showtype"];
        NSString *showtype = dict[@"showtype"];
        if ((NSNull *)showtype == [NSNull null]) {
            return;
        }
        if ([showtype intValue] == 1) {
            NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
            vc.hidesBottomBarWhenPushed = YES;
            vc.newsID = [newsMsg.articleId intValue];
            vc.parentVC = self;
            [self presentViewController:vc animated:YES completion:nil];
            
        }else if ([showtype intValue] == 2) {
            VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[newsMsg.articleId intValue]];
            [(UINavigationController *)self.selectedViewController pushViewController:newsDetailVC animated:YES];
        }else
        {
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[newsMsg.articleId intValue]];
            [(UINavigationController *)self.selectedViewController pushViewController:newsDetailVC animated:YES];
        }
    }else if ([msgType intValue] == 2)
    {
        PushNewsMsg *newsMsg = [[PushNewsMsg alloc] initWithDict:dictMsgBody];
        /* showType 为1 类型的下的新闻资讯类型小类型：
         * 消息类型，0 ：普通新闻  1 ：图集，  2： 视频
         *
         */
        // NSNumber *showtype = dict[@"showtype"];
        NSString *showtype = dict[@"showtype"];
        
        if ([showtype intValue] == 2) {
            VideoDetailAuditBarViewController *newsDetailVC = [[VideoDetailAuditBarViewController alloc] initWithNewsID:[newsMsg.articleId intValue]];
            [(UINavigationController *)self.selectedViewController pushViewController:newsDetailVC animated:YES];
        }else
        {
            NewsDetailAuditBarViewController *newsDetailVC = [[NewsDetailAuditBarViewController alloc] initWithNewsID:[newsMsg.articleId intValue]];
            [(UINavigationController *)self.selectedViewController pushViewController:newsDetailVC animated:YES];
        }
    }
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
