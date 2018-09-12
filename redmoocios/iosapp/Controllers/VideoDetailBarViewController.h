//
//  VideoDetailBarViewController.h
//  iosapp
//
//  Created by chen yu-jiao on 15/12/4.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "BottomBarViewController.h"
#import "VideoDetailViewController.h"

@protocol VideoDetailBarViewControllerDelegate <NSObject>

@optional

- (void) GiveBrowersCount: (int) _BrowersCount;

@end

@interface VideoDetailBarViewController : BottomBarViewController

@property (nonatomic, copy) void (^didScroll)();

@property (nonatomic, assign) BOOL isStarred;//是否已收藏

@property (nonatomic, assign) BOOL isZan;  //是否已点赞

@property (nonatomic, assign) int zanNum;  //点赞数目

@property (nonatomic, strong) UIBarButtonItem *zanNumButton;

@property (nonatomic,assign) id<VideoDetailBarViewControllerDelegate> delegate;

- (instancetype)initWithNewsID:(int)newsID;

@end
