//
//  SXMainViewController.h
//  iosapp
//
//  Created by redmooc on 16/6/30.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarView.h"
#import "HorizonalTableViewController.h"

@interface SXMainViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *controllers;

/** 标题栏 */
@property (nonatomic, strong) UIScrollView *smallScrollView;

/** 下面的内容栏 */
@property (nonatomic, strong) UIScrollView *bigScrollView;

@property (nonatomic, strong) NSMutableArray *titleName;
@property (nonatomic, assign) BOOL underTabbar;

@property (nonatomic, strong) NSMutableArray *columSelectedArray;

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers  andNodes:(NSArray *)nodes underTabbar:(BOOL)underTabbar;
- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers andNodes:(NSArray *)nodes;

- (void) viewRefesh;

@end
