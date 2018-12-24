//
//  RadioListViewController.m
//  iosapp
//
//  Created by redmooc on 2018/12/5.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "RadioListViewController.h"
#import "FYMainPlayController.h"
#import "FYPlayManager.h"//播放器
#import <MBProgressHUD.h>
#import "UIImageView+WebCache.h"

#define kNavHeight 64
#define kImageBgHeight  kNBR_SCREEN_W*2/7.0

@interface RadioListViewController ()<FYMainPlayControllerDelegate>


@property (nonatomic,strong) UIView  *headView;

/** 导航条的背景view */
@property (nonatomic, strong) UIView                     *naviView;
/** 返回按钮 */
@property (nonatomic, strong) UIButton                   *backBtn;
/** 导航条的title */
@property (nonatomic, strong) UILabel                    *titleLabel;

/** 背景图 */
@property (nonatomic, strong) UIImageView                *bgImageView;

@end

@implementation RadioListViewController


- (instancetype) initWithNode:(GFKDTopNodes *)nodes
{
    self  = [super init];
    if (self) {
        _nodeMode = nodes;
        _newsVC = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[_nodeMode.cateId intValue] isSpecial:0];
        _newsVC.isHasPlay = YES;
        CGRect rect = CGRectMake(0,kImageBgHeight, kNBR_SCREEN_W, kNBR_SCREEN_H-kImageBgHeight);
        [_newsVC.tableView setFrame:rect];
    }
    return self;
}

- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial
{
    self = [super init];
    if (self) {
        _newsVC = [[NewsViewController alloc] initWithNewsListType:type cateId:cateId isSpecial:isSpecial];
        _newsVC.isHasPlay = YES;
        
        CGRect rect = CGRectMake(0,kNBR_SCREEN_W*0.6+20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-kNBR_SCREEN_W*0.6-20);
        [_newsVC.tableView setFrame:rect];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _newsVC.title;
    
    [self addChildViewController:_newsVC];
   // [self.view addSubview:_newsVC.tableView];
    [self.view insertSubview:_newsVC.tableView atIndex:0];

    [self setUI];
    [self setUpNavigtionBar];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void) playButtonDidClick:(BOOL)selected{
//    FYMainPlayController *mainPlay = [[FYMainPlayController alloc]initWithNibName:@"FYMainPlayController" bundle:nil];
//    mainPlay.player = self.player;
//    [self presentViewController: mainPlay animated:YES completion:nil];
    
    NSLog(@"点击事件%li",(long)index);
    if ([[FYPlayManager sharedInstance] playerStatus]) {
        FYMainPlayController *mainPlay = [[FYMainPlayController alloc]initWithNibName:@"FYMainPlayController" bundle:nil];
        mainPlay.delegate = self;
        mainPlay.title = self.title;
        mainPlay.parentVC = self;
        [self presentViewController: mainPlay animated:YES completion:nil];
    }else{
        if ([[FYPlayManager sharedInstance] havePlay]) {
            [self showMiddleHint:@"歌曲加载中"];
        }else
            [self showMiddleHint:@"尚未加载歌曲"];
    }
}

# pragma mark - HUD

- (void)showMiddleHint:(NSString *)hint {
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.labelFont = [UIFont systemFontOfSize:15];
    hud.margin = 10.f;
    hud.yOffset = 0;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)dealloc {
    // 关闭消息中心
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[FYPlayManager sharedInstance] releasePlayer];
    
    NSLog(@"play dealloc");
}


- (void)topLeftButtonDidClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)topRightButtonDidClick {
    NSLog(@"右边按钮点击");
}


- (void)setUI
{
    //隐藏系统的导航条，由于需要自定义的动画，自定义一个view来代替导航条
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //将view的自动添加scroll的内容偏移关闭
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置背景色
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setUpNavigtionBar
{
    self.bgImageView = [[UIImageView alloc] init];
    [self.bgImageView setFrame:CGRectMake(0, 0, kNBR_SCREEN_W, kImageBgHeight)];
    [self.bgImageView sd_setImageWithURL:self.nodeMode.smallImage];
    [self.view addSubview:self.bgImageView];
    
    //初始化山寨导航条
    self.naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, kNavHeight)];
    self.naviView.backgroundColor = kNBR_ProjectColor;
    self.naviView.alpha = 0.0;
    [self.view addSubview:self.naviView];
    
    //添加返回按钮
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backBtn.frame = CGRectMake(5, 30, 25, 25);
    [self.backBtn addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [self.view addSubview:self.backBtn];
    
    //添加导航条上的大文字
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFrame:CGRectMake(30, 32, kNBR_SCREEN_W - 60, 25)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.titleLabel];
    
    self.titleLabel.text = self.nodeMode.cateName;
}


- (void) backButtonClick:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) refreshList{
    [_newsVC.tableView reloadData];
}

@end
