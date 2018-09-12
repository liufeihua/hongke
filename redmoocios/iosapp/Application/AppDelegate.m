//
//  AppDelegate.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-13.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "AppDelegate.h"
#import "OSCThread.h"
#import "Config.h"
#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCAPI.h"
//#import "OSCUser.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"

#import <Ono.h>
#import <AFOnoResponseSerializer.h>

#import "LoginViewController.h"

#import "IQKeyboardManager.h"
#import "LeadViewController.h"
#import "MobClick.h"

#import "UIImageView+WebCache.h"
#import "LaunchScreenViewController.h"
#import <MBProgressHUD.h>
#import "Utils.h"

#import "PushNewsMsg.h"
#import "PushWebLinkMsg.h"
#import "NewsDetailBarViewController.h"

#import "RootViewController.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件

#import <AVFoundation/AVFoundation.h>

#import "XHLaunchAd.h"

#import <UMSocial.h>
#import <UMengSocial/UMSocialQQHandler.h>
#import <UMengSocial/UMSocialWechatHandler.h>
#import <UMengSocial/UMSocialSinaHandler.h>


@interface AppDelegate () <UIApplicationDelegate,UIScrollViewDelegate,UIAlertViewDelegate,LeadViewControllerDelegate>
{
    BOOL isOut;
    NSDictionary *Pushdic;
    BMKMapManager* _mapManager;
}

@end

@implementation AppDelegate
//@synthesize lunchView;


- (void) showLoginViewController
{
    //登录
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    //[self.navigationController pushViewController:loginVC animated:YES];
    
    
    UINavigationController *nNavVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = nNavVC;
    [self.window makeKeyAndVisible];
}

- (void) showMainViewController
{
    UIStoryboard *mainBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
    self.window.rootViewController = [mainBoard instantiateInitialViewController];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _inNightMode = [Config getMode];
    
    //[NBSAppAgent startWithAppID:@"2142ec9589c2480f952feab9ed19a535"];
    
    [MobClick startWithAppkey:@"5698bd72e0f55a6d460029b8" reportPolicy:BATCH channelId:@""];//友盟统计
    

    /************ 友盟分享组件 **************/
    
    [UMSocialData setAppKey:@"5698bd72e0f55a6d460029b8"];
    [UMSocialWechatHandler setWXAppId:@"wxb39c75bbe652f600" appSecret:@"ea5354d875b38ab4a361501dbbce35e7" url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setQQWithAppId:@"1105162041" appKey:@"ilJeBN7G6LuBuM3E" url:@"http://www.umeng.com/social"];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    
    /************ 第三方登录设置 *************/
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"835174694"];
    
    
    [self loadCookies];
    
    //百度定位
    //请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"fcOgddMXu5nsVr8F1fIU8MdCSoUQpzKj"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    
    /************ 控件外观设置 **************/
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setTintColor:kNBR_ProjectColor]; //0xE03F3A
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:kNBR_ProjectColor} forState:UIControlStateSelected];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationbarColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor titleBarColor]];
    
    [UISearchBar appearance].tintColor = kNBR_ProjectColor;
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setCornerRadius:14.0];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setAlpha:0.6];
    
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xDCDCDC];
    pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    
    [[UITextField appearance] setTintColor:[UIColor nameColor]];
    [[UITextView appearance]  setTintColor:[UIColor nameColor]];
    
    
//    UIMenuController *menuController = [UIMenuController sharedMenuController];
//    
//    [menuController setMenuVisible:YES animated:YES];
//    [menuController setMenuItems:@[
//                                   [[UIMenuItem alloc] initWithTitle:@"复制" action:NSSelectorFromString(@"copyText:")],
//                                   [[UIMenuItem alloc] initWithTitle:@"删除" action:NSSelectorFromString(@"deleteObject:")]
//                                   ]];
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

    //后台播放音频设置
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = NO;
    keyboardManager.shouldResignOnTouchOutside = YES;
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES;
    keyboardManager.enableAutoToolbar = NO;
    
    isOut = NO;
    
    //推送消息
    NSDictionary* pushInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (pushInfo)
    {
        Pushdic = [pushInfo objectForKey:@"aps"];
    }
    
    [XHLaunchAd showWithAdFrame:[UIScreen mainScreen].bounds setAdImage:^(XHLaunchAd *launchAd) {
        
        //未检测到广告数据,启动页停留时间,不设置默认为3,(设置4即表示:启动页显示了4s,还未检测到广告数据,就自动进入window根控制器)
        launchAd.noDataDuration = 3;
        //获取广告数据
        [self requestImageData:^(NSString *imgUrl, NSInteger duration, NSString *openUrl) {
            
            /**
             *  2.设置广告数据
             */
            [launchAd setImageUrl:imgUrl duration:duration skipType:SkipTypeTimeText options:XHWebImageDefault completed:^(UIImage *image, NSURL *url) {
                
                //异步加载图片完成回调(若需根据图片尺寸,刷新广告frame,可在这里操作)
                //launchAd.adFrame = ...;
                
            } click:^{
                
                //广告点击事件
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
                
            }];
            
        }];
        
    } showFinish:^{
        //广告展示完成回调,设置window根控制器
        if ([[Config getToken] isEqualToString:@""]) {
            [self anonymousLogin];
            //[self showLoginViewController];  //2016-11-25去除登录页面
        }else{
            [self showMainViewController];
        }
    }];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) anonymousLogin {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager POST:[NSString stringWithFormat:@"%@%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_GETANONYMOUSTOKEN]
       parameters:@{
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  return;
              }
              NSDictionary *data = responseObject[@"result"][@"data"];
              NSString *token = responseObject[@"result"][@"token"];
              [Utils reNewUserWithDict:data token:token];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
          }
     ];
    
}

/**
 *  模拟:向服务器请求广告数据
 *
 *  @param imageData 回调imageUrl,及停留时间,跳转链接
 */
-(void)requestImageData:(void(^)(NSString *imgUrl,NSInteger duration,NSString *openUrl))imageData{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *parameters;
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
            NSLog(@"first launch第一次程序启动");
            parameters = @{@"code":@"first_picture",@"dType":@"2",@"version":version};
            //parameters = @{@"code":@"first_picture",@"dType":@"",@"version":@""};
        }else {
            NSLog(@"second launch再次程序启动");
            parameters = @{@"code":@"picture",@"dType":@"2",@"version":version};
            //parameters = @{@"code":@"picture",@"dType":@"",@"version":@""};
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        [manager GET:[NSString stringWithFormat:@"%@%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_LAUNCH]
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                 NSString *errorMessage = responseObject[@"reason"];
                 NSArray *objectArray = responseObject[@"result"][@"guideAd"];
                 for (NSDictionary *objectDict in objectArray) {
                     NSString *imgUrl = objectDict[@"image"];
                     if(imageData)
                     {
                         imageData(imgUrl,3,nil);
                         break;
                     }
                 }
                 
                 _floatAD = [[GFKDHomeAd alloc] initWithDict:responseObject[@"result"][@"floatAd"]];
                 _uiConfig = [[GFKDUIConfig alloc] initWithDict:responseObject[@"result"][@"uiConfig"]];
                
                 if (errorCode == 1) {
                     NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                     [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                     return;
                 }
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                 HUD.labelText = @"网络异常，操作失败";
                 
                 [HUD hide:YES afterDelay:1];
             }
         ];
    });
}



- (void)loadCookies
{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"sessionCookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //每次醒来都需要去判断是否得到device token
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(registerForRemoteNotificationToGetToken) userInfo:nil repeats:NO];
    //hide the badge
    application.applicationIconBadgeNumber = 0;
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url]             ||
           [WXApi handleOpenURL:url delegate:_loginDelegate]  ||
           [TencentOAuth HandleOpenURL:url]                   ||
           [WeiboSDK handleOpenURL:url delegate:_loginDelegate];
    
//    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [UMSocialSnsService handleOpenURL:url]             ||
           [WXApi handleOpenURL:url delegate:_loginDelegate]  ||
           [TencentOAuth HandleOpenURL:url]                   ||
           [WeiboSDK handleOpenURL:url delegate:_loginDelegate];
    
//    return [UMSocialSnsService handleOpenURL:url];
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    // IOS 7 Support Required
    Pushdic = [userInfo objectForKey:@"aps"];
    if (application.applicationState == UIApplicationStateActive) {
        NSString *alertStr = [Pushdic objectForKey:@"alert"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送" message:alertStr delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"确定", nil];
        alert.tag = 110;
        [alert show];
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSHMSGSHOW" object:[Pushdic objectForKey:@"message"]];
        application.applicationIconBadgeNumber = [[userInfo objectForKey:@"badge"] intValue];
    }
    NSLog(@"userInfo == %@",userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
//    
//    NSDictionary *dic = [[userInfo objectForKey:@"aps"]objectForKey:@"message"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSHMSGSHOW" object:dic];
//}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
     NSString *token  = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""] ;
   
    NSLog(@"My deviceToken is:%@", token);
    //将deviceToken保存起来
    [Config saveDeviceToken:token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    
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
       // NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 110) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            return;
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PUSHMSGSHOW" object:[Pushdic objectForKey:@"message"]];
        }
    }
    
}


- (void)introDidFinish {

    if (Pushdic) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"推送" message:[Pushdic objectForKey:@"alert"] delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"确定", nil];
        alert.tag = 110;
        [alert show];
    }
    
}


@end
