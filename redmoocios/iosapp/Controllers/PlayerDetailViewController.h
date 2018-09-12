//
//  PlayerDetailViewController.h
//  iosapp
//
//  Created by redmooc on 16/3/22.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDetailBarViewController.h"
#import "GFKDNewsDetail.h"
#import "GFKDNewsComment.h"

@interface PlayerDetailViewController : UIViewController

@property (nonatomic, weak) VideoDetailBarViewController *bottomBarVC;

@property (nonatomic, strong) NSMutableArray *commmentOjbs;

@property (nonatomic, strong) GFKDNewsDetail *newsDetailObj;

@property (nonatomic, strong) LastCell *lastCell;
@property (nonatomic, assign) NSUInteger page;

- (instancetype)initWithNewsID:(int)newsID;

@property (nonatomic, copy) void (^didCommentSelected)(GFKDNewsComment *comment);
@property (nonatomic, copy) void (^didScroll)();

@property (weak, nonatomic) IBOutlet UIView *VideoView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UILabel *label_author;
@property (weak, nonatomic) IBOutlet UIWebView *webView_header;
@property (weak, nonatomic) IBOutlet UILabel *label_dates;
@property (weak, nonatomic) IBOutlet UILabel *label_browers;

@property (weak, nonatomic) IBOutlet UIView *view_content;


@end
