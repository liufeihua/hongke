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

static NSString *NodeCellIdentifier = @"NodeBaseCell";

@interface StudySchoolViewController ()<UITableViewDelegate,UITableViewDataSource,TitleViewDelegate,HomeAdCellDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isHasAdv;  //是否有图片轮播
@property (nonatomic, copy) NSArray *AdvObjectsDict;

@end

@implementation StudySchoolViewController
{
    NSMutableArray *dataArray_node;
    NSString *_number;
    NSNumber *_parentId;
}

- (instancetype) initWithNumber:(NSString *)number{
    self = [super init];
    _number = number;
    if (self) {
        
    }
    return self;
}

- (instancetype) initWithParentId:(NSNumber *)parentId{
    self = [super init];
    _parentId = parentId;
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray_node = [[NSMutableArray alloc] init];
    [self tableView];
    [self loadNodeList];
    [self setupRefresh];
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
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
//                 if (i == 0){
//                     nodes.typeId = [NSNumber numberWithInt:6];
//                 }
//                 if (i == 1){
//                     nodes.typeId = [NSNumber numberWithInt:5];
//                 }
                 [dataArray_node addObject:nodes];
             }
             
             _AdvObjectsDict = responseObject[@"result"][@"adv"];
             _isHasAdv = _AdvObjectsDict.count ==0 ? FALSE:TRUE;
             
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
        node = _isHasAdv ? dataArray_node[indexPath.section-1] : dataArray_node[indexPath.section];
        NSString *ID = [NodeBaseCell idForRow:node];
        UINib *nib = [UINib nibWithNibName:ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:ID ];
        NodeBaseCell *cell = (NodeBaseCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
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
        moreView.tag = section;
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

// 设置行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isHasAdv && indexPath.section == 0) {
        return 220*kNBR_SCREEN_W/470;
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
                 NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[node.cateId intValue] isSpecial:0];
                 newsVC.hidesBottomBarWhenPushed = YES;
                 newsVC.title = node.cateName;
                 [self.navigationController pushViewController:newsVC animated:YES];
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
    [self loadChildNodeList:dataArray_node[tag]];
}

#pragma mark - delegate;
- (void)adClick:(GFKDHomeAd *)adv
{
    NSLog(@"homeAdv___click");
    [Utils showLinkAD:adv WithNowVC:self];
}

@end
