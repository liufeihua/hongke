//
//  NewsBarViewController.h
//  iosapp
//
//  Created by redmooc on 16/3/1.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsViewController.h"

@interface NewsBarViewController : UIViewController

@property (nonatomic, strong) NewsViewController *newsVC;
- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial;

@end
