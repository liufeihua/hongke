//
//  AppDelegate.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-13.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WXApi.h"

#import "GFKDHomeAd.h"
#import "GFKDUIConfig.h"

//@class LoginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) id <WeiboSDKDelegate, WXApiDelegate> loginDelegate;
@property (nonatomic, assign) BOOL inNightMode;


@property (nonatomic, strong) GFKDHomeAd *floatAD;
@property (nonatomic, strong) GFKDUIConfig *uiConfig;

- (void) showLoginViewController;
- (void) showMainViewController;




@end

