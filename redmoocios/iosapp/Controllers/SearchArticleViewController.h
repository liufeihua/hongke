//
//  SearchArticleViewController.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/24.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchArticleResultViewController.h"

@interface SearchArticleViewController : UIViewController

- (instancetype)init;
@property (nonatomic, strong) SearchArticleResultViewController *resultVC;

@end
