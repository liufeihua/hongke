//
//  StudySchoolViewController.m
//  iosapp
//
//  Created by redmooc on 2018/10/16.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "StudySchoolViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import <Masonry.h>
#import "TitleView.h"
#import "GFKDTopNodes.h"
#import <MJRefresh.h>
#import "NodeBaseCell.h"
#import "StudyMoreViewController.h"
#import "NewsViewController.h"
#import "HomeAdCell.h"
#import "RadioListViewController.h"
#import "JRSegmentViewController.h"
#import "RAYNewFunctionGuideVC.h"

static NSString *NodeCellIdentifier = @"NodeBaseCell";
#define kNavHeight 64

@interface StudySchoolViewController ()<UITableViewDelegate,UITableViewDataSource,TitleViewDelegate,HomeAdCellDelegate,NodeBaseCellDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isHasAdv;  //是否有图片轮播
@property (nonatomic, copy) NSArray *AdvObjectsDict;
/** 导航条的背景view */
@property (nonatomic, strong) UIView                     *naviView;
/** 返回按钮 */
@property (nonatomic, strong) UIButton                   *backBtn;
/** 导航条的title */
@property (nonatomic, strong) UILabel                    *titleLabel;

@end

@implementation StudySchoolViewController
{
    NSMutableArray *dataArray_node;
    NSString *_number;
    NSNumber *_parentId;
    NSMutableArray*_imageArray;
    BOOL showNav;
    NSMutableArray* _showNodesTag;
    //BOOL showRadioPlay;
}

- (instancetype)initWithNumber:(NSString *)number WithNav:(BOOL) isShowNav{
    self = [super init];
    _number = number;
    showNav = isShowNav;
//    if ([_number isEqualToString: @"audio"]) {
//        showRadioPlay = YES;
//    }else{
//        showRadioPlay = NO;
//    }
    if (self) {
        
    }
    return self;
}

- (instancetype) initWithParentId:(NSNumber *)parentId  WithNav:(BOOL) isShowNav{
    self = [super init];
    _parentId = parentId;
    showNav = isShowNav;
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    dataArray_node = [[NSMutableArray alloc] init];
    _imageArray = [[NSMutableArray alloc] init];
    _showNodesTag = [[NSMutableArray alloc] init];
    [self tableView];
    if (!showNav) {
        [self setUI];
        //初始化导航条上的内容
        [self setUpNavigtionBar];
    }
    [self loadNodeList];
    [self setupRefresh];
    
    [self makeFunctionGuide];
}

- (void)setUI
{
    //隐藏系统的导航条，由于需要自定义的动画，自定义一个view来代替导航条
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //将view的自动添加scroll的内容偏移关闭
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置背景色
    self.view.backgroundColor = [UIColor whiteColor];

    //给顶部的图片view和选择view留出距离
     CGRect tableViewFrame = self.view.frame;
     tableViewFrame.origin.y = 20;
     tableViewFrame.size.height -=20;
     [self.tableView setFrame:tableViewFrame];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)setUpNavigtionBar
{
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
}

- (void) backButtonClick:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!showNav) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!showNav) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupRefresh{
    _tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNodeList)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
}

- (void) loadNodeList
{
    NSDictionary *_parameters;
    if (_number == nil || ([_number isEqualToString:@""])){
        _parameters = @{@"token":[Config getToken],
                        @"parentId":_parentId};
    }else{
        _parameters = @{@"token":[Config getToken],
                        @"number":_number};
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:_parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             if (_tableView.mj_header.isRefreshing) {
                 [_tableView.mj_header endRefreshing];
             }
             
             NSArray *array = responseObject[@"result"][@"data"];
             [dataArray_node removeAllObjects];
             [_showNodesTag removeAllObjects];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
//                 if (i == 0){
//                     nodes.typeId = [NSNumber numberWithInt:10];
//                 }
//                 if (i == 1){
//                     nodes.typeId = [NSNumber numberWithInt:16];
//                 }
//                 if ([nodes.typeId intValue] == 4) {
//                     nodes.showChildNode = [NSNumber numberWithInt:1];
//                 }
                 if ([nodes.linkType intValue] == 6) {
                     nodes.cateId = [NSNumber numberWithInt:[nodes.detailUrl intValue]];
                 }
                 [dataArray_node addObject:nodes];
                 
                 //是否显示子栏目
                 if ([nodes.showChildNode intValue] == 1 && [nodes.terminated intValue] == 0) {
                     //[dataArray_node addObject:[NSNull null]];
                     [dataArray_node addObject:nodes];
                     [self loadChildNodeList:nodes AddArraysByTag:i+1 WithNodeNum:0];
                     
                     [_showNodesTag addObject:[NSNumber numberWithInt:i]];
                 }
                 
                 
             }
             
             _AdvObjectsDict = responseObject[@"result"][@"adv"];
             _isHasAdv = _AdvObjectsDict.count ==0 ? FALSE:TRUE;
//             if (_AdvObjectsDict.count == 1 && ![self.parentViewController isKindOfClass:[JRSegmentViewController class]]) {
//                 showNav = NO;
//                 [self setUI];
//                 //初始化导航条上的内容
//                 [self setUpNavigtionBar];
//                 [self.navigationController setNavigationBarHidden:YES animated:YES];
//             }
             [self.tableView reloadData];
             
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}


- (void) loadChildNodeList:(GFKDTopNodes *)node AddArraysByTag:(int) tag WithNodeNum:(int) num
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"parentId":@([node.cateId intValue])}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             NSArray *array = responseObject[@"result"][@"data"];

             GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[num]];
             [dataArray_node replaceObjectAtIndex:tag withObject:nodes];
             
             NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:tag-1];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             indexSet=[[NSIndexSet alloc]initWithIndex:tag];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}


- (UITableView *) tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"NodeBaseCell"];
        
        // 去掉分割线
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        // 越界不能上下拉
        //_tableView.bounces = NO;
        
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isHasAdv?dataArray_node.count+1:dataArray_node.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFKDTopNodes *node;
    if (_isHasAdv && indexPath.section == 0) {
        static NSString *CellIdentifier = @"homeAdCell";
        HomeAdCell *AdCell = (HomeAdCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
        if(AdCell == nil)
        {
            AdCell = [[HomeAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        AdCell.delegate = self;
        [AdCell getAds:_AdvObjectsDict];
        return AdCell;
        
    }else{
        
        int sectionNum = _isHasAdv ? (int)indexPath.section-1 : (int)indexPath.section;
        node = _isHasAdv ? dataArray_node[indexPath.section-1] : dataArray_node[indexPath.section];
        NSString *ID = [NodeBaseCell idForRow:node];
        
        NSString *CellIdentifier = [NSString stringWithFormat:@"%@%ld%ld", ID,[indexPath section], [indexPath row]];//以indexPath来唯一确定cell  重用机制会导致界面一些问题  重用机制是根据相同的标识符来重用cell的，标识符不同的cell不能彼此重用
        [tableView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellReuseIdentifier:CellIdentifier];
        NodeBaseCell *cell = (NodeBaseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        cell.indexTag = sectionNum;
        //cell.showRadioPlay = showRadioPlay;
        [cell setNode:node];
        [cell setParentVC:self];
        return cell;
    }
    
}
// 配置分组头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_isHasAdv && section == 0) {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    GFKDTopNodes *node = _isHasAdv ? dataArray_node[section-1] : dataArray_node[section];
    if ([node.showTitle intValue]==1){
        NSString *titleName = node.cateName;
        TitleView *moreView = [[TitleView alloc] initWithTitle:titleName hasMore:YES];
        moreView.hotLb.text = @"HOT";
        moreView.tag = _isHasAdv ? section-1 : section;;
        moreView.delegate = self;
        return moreView;
    }else{
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    
}

// 设置头高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_isHasAdv && section == 0) {
        return 0.1f;
    }
    GFKDTopNodes *node = _isHasAdv ? dataArray_node[section-1] : dataArray_node[section];
    if ([node.showTitle intValue]==1){
        return 35;
    }else{
        return 0.1f;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
     return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
}

// 设置尾高
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    for (NSNumber *tag in _showNodesTag) {
        if (section == [tag integerValue]) {
            return 0.0f;
        }
    }
    return 15;
}

// 设置行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isHasAdv && indexPath.section == 0) {
        return 9*kNBR_SCREEN_W/16;
        //return 160*KWidth_Scale;
    }
    GFKDTopNodes *node = _isHasAdv ? dataArray_node[indexPath.section-1] : dataArray_node[indexPath.section];
    return [NodeBaseCell heightForRow:node];
}

- (void) loadChildNodeList:(GFKDTopNodes *)node
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"parentId":@([node.cateId intValue])}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             
             NSArray *array = responseObject[@"result"][@"data"];
             if (array.count == 0) {
                 if ([node.nodeModelId intValue] != 20) {
//                 if (!showRadioPlay){
                     NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[node.cateId intValue] isSpecial:0];
                     newsVC.hidesBottomBarWhenPushed = YES;
                     newsVC.title = node.cateName;
                     [self.navigationController pushViewController:newsVC animated:YES];
                 
                 }else{
                     RadioListViewController *radioVC = [[RadioListViewController alloc] initWithNode:node];
                     radioVC.hidesBottomBarWhenPushed = YES;
                     radioVC.newsVC.title = node.cateName;
                     [self.navigationController pushViewController:radioVC animated:YES];
                 }
             }else{
                 StudyMoreViewController *moreVC = [[StudyMoreViewController alloc] init];
                 moreVC.hidesBottomBarWhenPushed = YES;
                 moreVC.nodeList = array;
                 moreVC.title = node.cateName;
                 [self.navigationController pushViewController:moreVC animated:YES];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

- (void)titleViewDidClick:(NSInteger)tag{
//    GFKDTopNodes *nodes = dataArray_node[tag];
//    if ([nodes.linkType intValue] == 6) {  //栏目链接
//        
//    }else{
//        [self loadChildNodeList:dataArray_node[tag]];
//    }
     [self loadChildNodeList:dataArray_node[tag]];
}

#pragma mark - delegate;
- (void)adClick:(GFKDHomeAd *)adv
{
    NSLog(@"homeAdv___click");
    [Utils showLinkAD:adv WithNowVC:self];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (!showNav) {
        if (offsetY>=kNavHeight)
        {
            offsetY=kNavHeight;
            [UIView animateWithDuration:0.25 animations:^{
                self.naviView.frame = CGRectMake(0, 0, self.naviView.bounds.size.width, kNavHeight);
                self.naviView.alpha = 1;
                self.titleLabel.text = self.title;
            }];
            
        }else
        {
            self.naviView.frame = CGRectMake(0, offsetY, self.naviView.bounds.size.width, -offsetY);
            self.titleLabel.text = @"";
        }
    }
}


- (void)NodeChick:(NSInteger)tag withNode:(GFKDTopNodes *)node{
    [dataArray_node replaceObjectAtIndex:tag+1 withObject:node];
     NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:tag+1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)makeFunctionGuide{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *firstComeInTeacherDetail = @"isFirstEnterHere-4.0";
    //[user setBool:NO forKey:firstComeInTeacherDetail];
    
    if (![user boolForKey:firstComeInTeacherDetail]) {
        [user setBool:YES forKey:firstComeInTeacherDetail];
        [user synchronize];
        [self makeGuideView];
    }
}

- (void)makeGuideView{
    RAYNewFunctionGuideVC *vc = [[RAYNewFunctionGuideVC alloc]init];
    vc.titles = @[
                 // @"要闻、信息港等移到了这了",
                  @"请完善个人信息"];
    
//    float frame1_y = 64 + 9*kNBR_SCREEN_W/16.0 + 20;
//    CGRect frame1 = CGRectMake(20, frame1_y, kNBR_SCREEN_W - 20, (kNBR_SCREEN_W - 100)/4.0 + 30) ;
    CGRect frame2 = CGRectMake(kNBR_SCREEN_W -70, kNBR_SCREEN_H-50, 60, 50);
    
    //@"{{0,  60},{100,80}}
    vc.frames = @[
                 // NSStringFromCGRect(frame1),
                  NSStringFromCGRect(frame2),
                  ];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

@end
