//
//  SearchArticleResultViewController.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/24.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDObjsViewController.h"
#import "GFKDNews.h"
@protocol SearchArticleResultViewControllerDelegate <NSObject>

@optional
- (void)pushViewController:(GFKDNews*)news;
@end

@interface SearchArticleResultViewController : GFKDObjsViewController

-(instancetype) initWithKeyWord : (NSString *) keyWord;


@property (nonatomic, copy) NSString *keyword;

@property (nonatomic,assign) id<SearchArticleResultViewControllerDelegate> delegate;

@end
