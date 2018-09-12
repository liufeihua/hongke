//
//  PlayerDetailViewController.m
//  iosapp
//
//  Created by redmooc on 16/3/22.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "PlayerDetailViewController.h"
#import "CommentsBottomBarViewController.h"
#import <MBProgressHUD.h>
#import "Config.h"
#import "UIBarButtonItem+Badge.h"
//#import "LSPlayerView.h"
#import "WMPlayer.h"
#import "CommentCell.h"
#import "ReplyCommentCell.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"


@interface PlayerDetailViewController ()<WMPlayerDelegate,UIWebViewDelegate>
{
    WMPlayer *wmPlayer;
    CGRect playerFrame;
    UIImageView *conver;
    NSString *webHeaderHtml;
}

@property (nonatomic, readonly, assign) int   newsID;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation PlayerDetailViewController

- (instancetype)initWithNewsID:(int)newsID
{
    self = [super init];
    
    if (self) {
        _page = 1;
        _newsID = newsID;
        self.commmentOjbs = [NSMutableArray new];
        //注册播放完成通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:@"fullScreenBtnClickNotice" object:nil];
    }
    
    return self;
    
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    //旋转屏幕通知
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onDeviceOrientationChange)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil
//     ];
//}

-(void)viewEnterForeground
{
    if ([_newsDetailObj.hasAudio intValue] == 1)
    {
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 35;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = FLT_MAX;
        [conver.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.webView_header.delegate = self;
    self.webView_header.scrollView.bounces = NO;
    self.webView_header.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView_header.scrollView.scrollEnabled = NO;
    [self.webView_header sizeToFit];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?articleId=%d&token=%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_DETAIL,_newsID,[Config getToken]]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             //NSLog(@"%@",responseObject[@"result"]);
             _newsDetailObj = [[GFKDNewsDetail alloc] initWithDict:responseObject[@"result"]];
             
             _bottomBarVC.isStarred = [_newsDetailObj.collected intValue] == 1?YES:NO;
             _bottomBarVC.isZan = [_newsDetailObj.digged intValue] == 1?YES:NO;
             _bottomBarVC.zanNum = [_newsDetailObj.diggs intValue];
             
             playerFrame = self.VideoView.frame;
             
             wmPlayer = [[WMPlayer alloc]init];
             wmPlayer.delegate = self;
             if ([_newsDetailObj.hasVideo intValue] == 1) {
                 wmPlayer.URLString = _newsDetailObj.video;
             }
             if ([_newsDetailObj.hasAudio intValue] == 1) {
                 wmPlayer.URLString = _newsDetailObj.audio;
             }
             
             //wmPlayer.titleLabel.text = self.title;
             wmPlayer.closeBtn.hidden = YES;
             
             [self.view addSubview:wmPlayer];
             [wmPlayer play];
             
             [wmPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.top.equalTo(self.view).with.offset(0);
                 make.left.equalTo(self.view).with.offset(0);
                 make.right.equalTo(self.view).with.offset(0);
                 make.height.equalTo(@(playerFrame.size.height));
             }];
             
             
             if ([_newsDetailObj.hasAudio intValue] == 1) {
                 conver = [[UIImageView alloc] initWithFrame:CGRectMake(playerFrame.size.width/2-150/2, playerFrame.size.height/2-150/2, 150, 150)];
                 conver.layer.masksToBounds = YES;
                 conver.layer.cornerRadius = conver.frame.size.height / 2.0;
                 conver.layer.borderWidth = 5.0;
                 conver.layer.borderColor = [UIColor lightGrayColor].CGColor;
                 
                 [conver sd_setImageWithURL:[NSURL URLWithString:_newsDetailObj.image] placeholderImage:[UIImage imageNamed:@"item_default"]];
                 [wmPlayer addSubview:conver];
                 //图片旋转
                 conver.transform = CGAffineTransformRotate(conver.transform, M_PI / 1440);
                 
                 CABasicAnimation* rotationAnimation;
                 rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                 rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
                 rotationAnimation.duration = 35;
                 rotationAnimation.cumulative = YES;
                 rotationAnimation.repeatCount = FLT_MAX;
                 [conver.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
                 
             }
             
             
             self.label_title.text = _newsDetailObj.title;
            
             if (((NSNull *)_newsDetailObj.header != [NSNull null]) && _newsDetailObj.header != nil) {
                 // webHeaderHtml = [NSString stringWithFormat:@"%@<br/>%@",_newsDetailObj.header,_newsDetailObj.header];
                 webHeaderHtml = _newsDetailObj.header;
             }else{
                 webHeaderHtml = [NSString stringWithFormat:@"   发布者:%@",_newsDetailObj.author];
                 [self.webView_header loadHTMLString:[NSString stringWithFormat:@"   发布者:%@",_newsDetailObj.author] baseURL:nil];
             }
             [self.webView_header loadHTMLString:webHeaderHtml baseURL:nil];

             [self.label_browers setAttributedText:[Utils attributedBrowersCount:[_newsDetailObj.browsers intValue] WithFontSize:14]];
             [self.label_dates setAttributedText:[Utils attributedDateStr:_newsDetailObj.dates]];
             
             _bottomBarVC.operationBar.isStarred = _bottomBarVC.isStarred;
             _bottomBarVC.operationBar.isZan = _bottomBarVC.isZan;
             _bottomBarVC.operationBar.zanNum = _bottomBarVC.zanNum;
             
             _bottomBarVC.zanNumButton = _bottomBarVC.operationBar.items[10];
             _bottomBarVC.zanNumButton.shouldHideBadgeAtZero = YES;
             _bottomBarVC.zanNumButton.badgeValue = [NSString stringWithFormat:@"%d", _bottomBarVC.zanNum];
             _bottomBarVC.zanNumButton.badgePadding = 1;
             _bottomBarVC.zanNumButton.badgeBGColor = [UIColor colorWithHex:0xE25955];//0xDE9223
             
             if ([_newsDetailObj.infoLevel intValue] == 3) {
                 _bottomBarVC.operationBar.items = [_bottomBarVC.operationBar.items subarrayWithRange:NSMakeRange(0, 14)];
             }else{
                 _bottomBarVC.operationBar.items = [_bottomBarVC.operationBar.items subarrayWithRange:NSMakeRange(0, 12)];
             }
             UIBarButtonItem *browsersCountButton = _bottomBarVC.operationBar.items[4];
             browsersCountButton.shouldHideBadgeAtZero = YES;
             browsersCountButton.badgeValue = [NSString stringWithFormat:@"%@", _newsDetailObj.comments];
             browsersCountButton.badgePadding = 1;
             browsersCountButton.badgeBGColor = [UIColor colorWithHex:0xE25955];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
    [self getCommentWithURL:[NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&articleId=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_COMMENT,_page,GFKDAPI_PAGESIZE,_newsID,[Config getToken]]];
    
    _lastCell = [[LastCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [_lastCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMoreCommentData)]];
    self.tableView.tableFooterView = _lastCell;
    _lastCell.emptyMessage = @"暂无评论";
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewEnterForeground) name:NSNotificationCenter_appWillEnterForeground object:nil];
}

- (void) getCommentWithURL:(NSString *)allUrlstring{
    //self.view.backgroundColor = [UIColor themeColor];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager GET:allUrlstring
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             NSArray *objectsDICT = responseObject[@"result"];
             for (NSDictionary *objectDict in objectsDICT) {
                 GFKDNewsComment *obj = [[GFKDNewsComment alloc] initWithDict:objectDict];
                 [_commmentOjbs addObject:obj];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (_page == 1 && objectsDICT.count == 0) {
                     _lastCell.status = LastCellStatusEmpty;
                 } else if (objectsDICT.count == 0 || (_page == 1 && objectsDICT.count < GFKD_PAGESIZE)) {
                     _lastCell.status = LastCellStatusFinished;
                 } else {
                     _lastCell.status = LastCellStatusMore;
                 }
                 
                 [self.tableView reloadData];
             });
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

- (void) loadMoreCommentData{
    if (!_lastCell.shouldResponseToTouch) {return;}
    
    _lastCell.status = LastCellStatusLoading;
    
    [self getCommentWithURL:[NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&articleId=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_COMMENT,++_page,GFKDAPI_PAGESIZE,_newsID,[Config getToken]]];
}

- (void)fetchCommentList
{
    //添加评论区
    CommentsBottomBarViewController  *commentsBVC = [[CommentsBottomBarViewController alloc]initWithCommentType:0 andObjectID:_newsID];
    [self.bottomBarVC.navigationController pushViewController:commentsBVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)releaseWMPlayer
{
    //堵塞主线程
    //    [wmPlayer.player.currentItem cancelPendingSeeks];
    //    [wmPlayer.player.currentItem.asset cancelLoading];
    [wmPlayer pause];
    [wmPlayer removeFromSuperview];
    [wmPlayer.playerLayer removeFromSuperlayer];
    [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    wmPlayer.player = nil;
    wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [wmPlayer.autoDismissTimer invalidate];
    wmPlayer.autoDismissTimer = nil;
    wmPlayer.playOrPauseBtn = nil;
    wmPlayer.playerLayer = nil;
    wmPlayer = nil;
}

- (void)dealloc
{
    [self releaseWMPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"DetailViewController deallco");
}

///播放器事件  已隐藏
//-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
//    if (wmplayer.isFullscreen) {
//        
//        //强制翻转屏幕，Home键在下边。
//        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
//        //刷新
//        [UIViewController attemptRotationToDeviceOrientation];
//        
//        [wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.view).with.offset(0);
//            make.left.equalTo(self.view).with.offset(0);
//            make.right.equalTo(self.view).with.offset(0);
//            make.height.equalTo(@(playerFrame.size.height));
//        }];
//        wmPlayer.isFullscreen = NO;
//        //self.enablePanGesture = YES;
//    }else{
//        [self releaseWMPlayer];
//        if (self.presentingViewController) {
//            [self dismissViewControllerAnimated:YES completion:^{
//                
//            }];
//        }else{
//            [self.navigationController popViewControllerAnimated:YES];
//            
//        }
//    }
//}
///播放暂停
-(void)wmplayer:(WMPlayer *)wmplayer clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    NSLog(@"clickedPlayOrPauseButton");
}
///全屏按钮
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (wmPlayer.isFullscreen==YES) {//全屏
        //强制翻转屏幕，Home键在下边。
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [self toOrientation:UIInterfaceOrientationPortrait];
        wmPlayer.isFullscreen = NO;
        //self.enablePanGesture = YES;
        
    }else{//非全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        [self toOrientation:UIInterfaceOrientationLandscapeRight];
        wmPlayer.isFullscreen = YES;
        //self.enablePanGesture = NO;
    }
}
///单击播放器
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    
}
///双击播放器
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}
///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    //    NSLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
}
//操作栏隐藏或者显示都会调用此方法
-(void)wmplayer:(WMPlayer *)wmplayer isHiddenTopAndBottomView:(BOOL)isHidden{
    //isHiddenStatusBar = isHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    if (wmPlayer==nil||wmPlayer.superview==nil){
        return;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
            wmPlayer.isFullscreen = NO;
           // self.enablePanGesture = NO;
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self toOrientation:UIInterfaceOrientationPortrait];
            wmPlayer.isFullscreen = NO;
            //self.enablePanGesture = YES;
            
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
            wmPlayer.isFullscreen = YES;
            //self.enablePanGesture = NO;
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
            wmPlayer.isFullscreen = YES;
            //self.enablePanGesture = NO;
        }
            break;
        default:
            break;
    }
}

//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    wmPlayer.transform = CGAffineTransformIdentity;
    [wmPlayer removeFromSuperview];
    if (orientation ==UIInterfaceOrientationPortrait) {//
        [self.view addSubview:wmPlayer];
        [wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(0);
            make.left.equalTo(self.view).with.offset(0);
            make.right.equalTo(self.view).with.offset(0);
            make.height.equalTo(@(playerFrame.size.height));
        }];
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        
    }else{
        [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
        if (orientation==UIInterfaceOrientationLandscapeLeft) {
            wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
        }else if(orientation==UIInterfaceOrientationLandscapeRight){
            wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
        [wmPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@([UIScreen mainScreen].bounds.size.height));
            make.height.equalTo(@([UIScreen mainScreen].bounds.size.width));
            //make.center.equalTo(self.view);
            make.center.equalTo(wmPlayer.superview);
        }];
//        wmPlayer.frame = CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H);
//        wmPlayer.playerLayer.frame =  CGRectMake(0,0, kNBR_SCREEN_H,kNBR_SCREEN_W);
        
       
        wmPlayer.isFullscreen = YES;
        wmPlayer.fullScreenBtn.selected = YES;
        [wmPlayer bringSubviewToFront:wmPlayer.bottomView];
       
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //获取设备旋转方向的通知,即使关闭了自动旋转,一样可以监测到设备的旋转方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewDidDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [super viewDidAppear:animated];
}


//-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
//    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
//    [wmPlayer removeFromSuperview];
//    wmPlayer.transform = CGAffineTransformIdentity;
//    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
//        wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
//    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
//        wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
//    }
//    wmPlayer.frame = CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H);
//    wmPlayer.playerLayer.frame =  CGRectMake(0,0, kNBR_SCREEN_H,kNBR_SCREEN_W);
//
//    [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(40);
//        make.top.mas_equalTo(kNBR_SCREEN_W-40);
//        make.width.mas_equalTo(kNBR_SCREEN_H);
//    }];
//
//    [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(wmPlayer).with.offset((-kNBR_SCREEN_H/2));
//        make.height.mas_equalTo(30);
//        make.width.mas_equalTo(30);
//        make.top.equalTo(wmPlayer).with.offset(5);
//
//    }];
//    [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
//    wmPlayer.isFullscreen = YES;
//    wmPlayer.fullScreenBtn.selected = YES;
//    [wmPlayer bringSubviewToFront:wmPlayer.bottomView];
//
//}
//-(void)toNormal{
//    [wmPlayer removeFromSuperview];
//    [UIView animateWithDuration:0.5f animations:^{
//        wmPlayer.transform = CGAffineTransformIdentity;
//        wmPlayer.frame =CGRectMake(playerFrame.origin.x, playerFrame.origin.y, playerFrame.size.width, playerFrame.size.height);
//        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
//        [self.view addSubview:wmPlayer];
//        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(wmPlayer).with.offset(0);
//            make.right.equalTo(wmPlayer).with.offset(0);
//            make.height.mas_equalTo(40);
//            make.bottom.equalTo(wmPlayer).with.offset(0);
//        }];
//        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(wmPlayer).with.offset(5);
//            make.height.mas_equalTo(30);
//            make.width.mas_equalTo(30);
//            make.top.equalTo(wmPlayer).with.offset(5);
//        }];
//
//    }completion:^(BOOL finished) {
//        wmPlayer.isFullscreen = NO;
//        wmPlayer.fullScreenBtn.selected = NO;
//        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
//
//    }];
//}
//-(void)fullScreenBtnClick:(NSNotification *)notice{
//    UIButton *fullScreenBtn = (UIButton *)[notice object];
//    if (fullScreenBtn.isSelected) {//全屏显示
//        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
//    }else{
//        [self toNormal];
//    }
//}
///**
// *  旋转屏幕通知
// */
//- (void)onDeviceOrientationChange{
//    if (wmPlayer==nil||wmPlayer.superview==nil){
//        return;
//    }
//
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
//    switch (interfaceOrientation) {
//        case UIInterfaceOrientationPortraitUpsideDown:{
//            NSLog(@"第3个旋转方向---电池栏在下");
//        }
//            break;
//        case UIInterfaceOrientationPortrait:{
//            NSLog(@"第0个旋转方向---电池栏在上");
//            if (wmPlayer.isFullscreen) {
//                [self toNormal];
//            }
//        }
//            break;
//        case UIInterfaceOrientationLandscapeLeft:{
//            NSLog(@"第2个旋转方向---电池栏在左");
//            if (wmPlayer.isFullscreen == NO) {
//                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
//            }
//        }
//            break;
//        case UIInterfaceOrientationLandscapeRight:{
//            NSLog(@"第1个旋转方向---电池栏在右");
//            if (wmPlayer.isFullscreen == NO) {
//                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_bottomBarVC != nil) {
        return 30;
    }else{
        return 0.1f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_bottomBarVC != nil) {
        UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 30)];
        sectionHeaderView.backgroundColor = kNBR_ProjectColor_BackGroundGray;
        sectionHeaderView.layer.borderColor = kNBR_ProjectColor_LineLightGray.CGColor;
        sectionHeaderView.layer.borderWidth = 0.5f;
        
        UILabel *sectionHeaderLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kNBR_SCREEN_W - 30, 30)];
        sectionHeaderLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:14.0f];
        sectionHeaderLable.textColor = [UIColor tagColor];
        
        [sectionHeaderView addSubview:sectionHeaderLable];
        sectionHeaderLable.text = @"评论";
        
//        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNBR_SCREEN_W - 100, 0, 85, 30)];
//        textLabel.textColor = [UIColor nameColor];
//        
//        textLabel.textAlignment = NSTextAlignmentRight;
//        textLabel.font = [UIFont boldSystemFontOfSize:14];
//        [sectionHeaderView addSubview:textLabel];
//        if (self.commmentOjbs.count > 0) {
//            [sectionHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchCommentList)]];
//            textLabel.text = @"更多";
//        }else
//        {
//            sectionHeaderLable.text = @"暂无评论";
//            textLabel.text = @"";
//        }
        
        return sectionHeaderView;
    }else{
        return nil;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.commmentOjbs.count > 0)
    {
        GFKDNewsComment *comment = self.commmentOjbs[indexPath.row];
        
        if (comment.cellHeight) {return comment.cellHeight;}
        
        if ([comment.ftype  isEqual: @"Info"]) {
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.text]];
            
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.font = [UIFont boldSystemFontOfSize:15];
            [label setAttributedText:contentString];
            __block CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
            
            comment.cellHeight = height + 61;
        }else  if ([comment.ftype  isEqual: @"Comment"])
        {
            NSString * contStr = [NSString stringWithFormat:@"%@ 回复 %@: %@",comment.creator,comment.fromUser,comment.text];
            NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:contStr]];
            
            UILabel *label = [UILabel new];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.font = [UIFont boldSystemFontOfSize:15];
            [label setAttributedText:contentString];
            __block CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
            
            comment.cellHeight = height + 10;
        }
        return comment.cellHeight;
    }else{
        return  0.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.commmentOjbs.count > 0)
    {
        NSInteger row = indexPath.row;
        GFKDNewsComment *comments = self.commmentOjbs[row];
        if ([comments.ftype  isEqual: @"Info"]) {
            
            CommentCell *cell = [CommentCell new];
            [self setBlockForCommentCell:cell];
            [cell setContentWithComment:comments];
            cell.contentLabel.textColor = [UIColor contentTextColor];
            cell.portrait.tag = row; cell.authorLabel.tag = row;
            //            [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
            
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
            return cell;
        }else  if ([comments.ftype  isEqual: @"Comment"]) {
            ReplyCommentCell *cell = [ReplyCommentCell new];
            
            [cell setContentWithComment:comments];
            //cell.contentLabel.textColor = [UIColor contentTextColor];
            cell.authorLabel.tag = row;
            //            [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
            
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
            return cell;
        }
        
    }
    return nil;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDNewsComment *comment = self.commmentOjbs[indexPath.row];
    
    if (self.didCommentSelected) {
        self.didCommentSelected(comment);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commmentOjbs.count;
}


- (void)setBlockForCommentCell:(CommentCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            return YES;
        }
        
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        //删除评论
    };
}

#pragma WMPlayerDelegate
- (void) isPlay:(BOOL)isplay{
    if (isplay) {
        //旋转
        [self resumeLayer:conver.layer];
    }else{
        //暂停
        [self pauseLayer:conver.layer];
    }
}

//继续
- (void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}
//暂停
- (void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

/********UIWebViewDelegate*/
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //原height 36;
    CGFloat oldHeight = self.webView_header.frame.size.height;
    CGFloat webHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.clientHeight"] floatValue] - 6;

    [self.webView_header setFrame:CGRectMake(self.webView_header.frame.origin.x, self.webView_header.frame.origin.y, self.webView_header.frame.size.width, webHeight)];
    
    [self.view_content setFrame:CGRectMake(self.view_content.frame.origin.x, self.webView_header.frame.origin.y+webHeight, self.view_content.frame.size.width, self.view_content.frame.size.height)];
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, self.view_content.frame.origin.y+self.view_content.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height-webHeight+oldHeight)];
}
@end
