//
//  RadioListViewController.h
//  iosapp
//
//  Created by redmooc on 2018/12/5.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "HRNavigationController.h"
#import <UIKit/UIKit.h>
#import "NewsViewController.h"
#import "GFKDTopNodes.h"

@interface RadioListViewController : HRNavigationController

@property (nonatomic, strong) NewsViewController *newsVC;

@property (nonatomic, strong) GFKDTopNodes *nodeMode;

- (instancetype) initWithNode:(GFKDTopNodes *)nodes;

- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial;

@end
