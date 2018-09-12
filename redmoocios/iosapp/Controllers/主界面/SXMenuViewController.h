//
//  SXMenuViewController.h
//  iosapp
//
//  Created by redmooc on 16/10/31.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarView.h"
#import "HorizonalTableViewController.h"
//#import "XHYScrollingNavBarViewController.h"

@interface SXMenuViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *controllers;

/** 标题栏 */
@property (nonatomic, strong) UIScrollView *smallScrollView;

/** 下面的内容栏 */
@property (nonatomic, strong) UIScrollView *bigScrollView;

@property (nonatomic, strong) NSMutableArray *titleName;
@property (nonatomic, assign) BOOL underTabbar;

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers underTabbar:(BOOL)underTabbar;
- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers;

- (void) loadControllerVC;

@end
