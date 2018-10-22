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

static NSString *NodeCellIdentifier = @"NodeBaseCell";

@interface StudySchoolViewController ()<UITableViewDelegate,UITableViewDataSource,TitleViewDelegate>

@property (nonatomic,strong) UITableView *tableView;


@end

@implementation StudySchoolViewController
{
    NSMutableArray *dataArray_node;
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":@"dsh"}
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
                 if (i==0) {
                     nodes.showType = [NSNumber numberWithInt:1];;
                 }
                 if (i==1) {
                     nodes.showType = [NSNumber numberWithInt:0];;
                 }
                 if (i==2) {
                     nodes.showType = [NSNumber numberWithInt:2];;
                 }
                 [dataArray_node addObject:nodes];
             }
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
    return dataArray_node.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 1) {
//        return towSmallRow;
//    }else{
//        return 1;
//    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFKDTopNodes *node = dataArray_node[indexPath.section];
//    node.showType = [NSNumber numberWithInt:0];
    NSString *ID = [NodeBaseCell idForRow:node];
    UINib *nib = [UINib nibWithNibName:ID bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:ID ];
    NodeBaseCell *cell = (NodeBaseCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    [cell setNode:node];
    [cell setParentVC:self];
    return cell;    
}
// 配置分组头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GFKDTopNodes *node = dataArray_node[section];
    NSString *titleName = node.cateName;
    TitleView *moreView = [[TitleView alloc] initWithTitle:titleName hasMore:YES];
    moreView.hotLb.text = @"HOT";
    moreView.tag = section;
    moreView.delegate = self;
    return moreView;
}

- (void) loadChildNodeList:(GFKDTopNodes *)node
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":node.number}
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
    //更多
}

// 设置头高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

// 设置行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GFKDTopNodes *node = dataArray_node[indexPath.section];
    return [NodeBaseCell heightForRow:node];
}

@end
