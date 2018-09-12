//
//  NewsDetailAuditBarViewController.h
//  iosapp
//
//  Created by redmooc on 16/5/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AuditInfoBottomBarViewController.h"
#import "GFKDNews.h"

//@protocol NewsDetailAuditBarViewControllerDelegate <NSObject>
//
//@optional
//
//- (void) UpdateIndex;
//
//@end


@interface NewsDetailAuditBarViewController : AuditInfoBottomBarViewController

- (instancetype)initWithNews:(GFKDNews*)news WithType:(int)type;

- (instancetype)initWithNewsID:(int)newsID;

//@property (nonatomic, assign) GFKDNews *news;
//@property (nonatomic, assign) int type;//1：待审；2：退稿；3：已审核

//@property (nonatomic,assign) id<NewsDetailAuditBarViewControllerDelegate> delegate;

@end
