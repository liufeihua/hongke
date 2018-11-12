//
//  StudyHomeViewController.m
//  iosapp
//
//  Created by redmooc on 17/6/6.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "StudyHomeViewController.h"
#import <Masonry.h>
#import "FourBookCell.h"
#import "TwoSmallCell.h"
#import "ThreeCell.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import "GFKDTopNodes.h"
#import "GFKDNews.h"
#import <MBProgressHUD.h>
#import "UIImageView+WebCache.h"
#import "TitleView.h"
#import "CYWebViewController.h"
#import "NewsDetailBarViewController.h"
#import "NewsImagesViewController.h"
#import "VideoDetailViewController.h"
#import "EPUBParser.h"
#import "EPUBReadMainViewController.h"
#import "LSYReadPageViewController.h"

#import "LikeStudyViewController.h"
#import "LikeBookViewController.h"
#import "LikeClassroomViewController.h"

#import "NewsViewController.h"

@interface StudyHomeViewController ()<UITableViewDelegate,UITableViewDataSource,FourBookCellDelegate,TitleViewDelegate,ThreeCellDelegate,TwoSmallCellDelegate>

@property (nonatomic,strong) UITableView *tableView;

@end

static NSString *FourBookcellIdentifier = @"FourBookCell";
static NSString *TwoSmallCellIdentifier = @"TwoSmallCell";
static NSString *ThreeCellIdentifier = @"ThreeCell";

static int towSmallRow = 2;

@implementation StudyHomeViewController
{
    NSMutableArray *dataArray_study; //爱学习
    CGFloat _hotCellHeight;
    NSMutableArray *dataArray_book;  //爱读书
    NSMutableArray *dataArray_classroom;  //爱听课
    BOOL studyLoad,bookLoad,classroomLoad;
}

- (void) viewDidLoad{
    [super viewDidLoad];
    studyLoad = false;
    bookLoad = false;
    classroomLoad = false;
    dataArray_study = [[NSMutableArray alloc] init];
    dataArray_book = [[NSMutableArray alloc] init];
    dataArray_classroom = [[NSMutableArray alloc] init];
    //[self loadStuty];
    [self loadStudyHot];
    [self loadBookHot];
    [self loadClassroomHot];
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
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [_tableView registerClass:[FourBookCell class] forCellReuseIdentifier:FourBookcellIdentifier];
        [_tableView registerClass:[TwoSmallCell class] forCellReuseIdentifier:TwoSmallCellIdentifier];
        [_tableView registerClass:[ThreeCell class] forCellReuseIdentifier:ThreeCellIdentifier];
        
        // 去掉分割线
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        // 越界不能上下拉
        _tableView.bounces = NO;
        
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
    }
    return _tableView;
}

- (void) loadStudyHot
{
    NSString *studyNumber = @"axx";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":studyNumber}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                
             }
             [dataArray_study removeAllObjects];
             NSArray *array = responseObject[@"result"][@"data"];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [dataArray_study addObject:nodes];
             }
             studyLoad = true;
             [self isReloadTableView];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
    
//    int studyCateId = 334;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=1",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,studyCateId,@"pageSize=4",0,[Config getToken]]
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//             NSString *errorMessage = responseObject[@"reason"];
//             
//             if (errorCode == 1) {
//                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
//                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
//                 
//                 return;
//                 
//             }
//             [dataArray_study removeAllObjects];
//             NSArray *array = responseObject[@"result"][@"data"];
//             for (int i=0; i<array.count; i++) {
//                 GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
//                 [dataArray_study addObject:news];
//             }
//             studyLoad = true;
//             [self isReloadTableView];
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             MBProgressHUD *HUD = [Utils createHUD];
//             HUD.mode = MBProgressHUDModeCustomView;
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//             HUD.labelText = @"网络异常，操作失败";
//             
//             [HUD hide:YES afterDelay:1];
//         }
//     ];
}

- (void) loadBookHot
{
    NSString *bookNumber = @"ads";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":bookNumber}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             [dataArray_book removeAllObjects];
             NSArray *array = responseObject[@"result"][@"data"];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [dataArray_book addObject:nodes];
             }
             bookLoad = true;
             [self isReloadTableView];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
//    int bookCateId = 333;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=1",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,bookCateId,@"pageSize=4",0,[Config getToken]]
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//             NSString *errorMessage = responseObject[@"reason"];
//             
//             if (errorCode == 1) {
//                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
//                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
//                 
//                 return;
//                 
//             }
//             [dataArray_book removeAllObjects];
//             NSArray *array = responseObject[@"result"][@"data"];
//             for (int i=0; i<array.count; i++) {
//                 GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
//                 [dataArray_book addObject:news];
//             }
//             bookLoad = true;
//             [self isReloadTableView];
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             MBProgressHUD *HUD = [Utils createHUD];
//             HUD.mode = MBProgressHUDModeCustomView;
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//             HUD.labelText = @"网络异常，操作失败";
//             
//             [HUD hide:YES afterDelay:1];
//         }
//     ];
}

- (void) loadClassroomHot
{
    NSString *classroomNumber = @"atk";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":classroomNumber}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             [dataArray_classroom removeAllObjects];
             NSArray *array = responseObject[@"result"][@"data"];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [dataArray_classroom addObject:nodes];
             }
             classroomLoad = true;
             [self isReloadTableView];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
//    int classroomCateId = 335;
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=1",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,classroomCateId,@"pageSize=4",0,[Config getToken]]
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//             NSString *errorMessage = responseObject[@"reason"];
//             
//             if (errorCode == 1) {
//                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
//                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
//                 
//                 return;
//                 
//             }
//             [dataArray_classroom removeAllObjects];
//             NSArray *array = responseObject[@"result"][@"data"];
//             for (int i=0; i<array.count; i++) {
//                 GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
//                 [dataArray_classroom addObject:news];
//             }
//             classroomLoad = true;
//             [self isReloadTableView];
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             MBProgressHUD *HUD = [Utils createHUD];
//             HUD.mode = MBProgressHUDModeCustomView;
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//             HUD.labelText = @"网络异常，操作失败";
//             
//             [HUD hide:YES afterDelay:1];
//         }
//     ];
}

- (void) isReloadTableView{
    if (studyLoad && bookLoad && classroomLoad) {
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return towSmallRow;
    }else{
       return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FourBookCell *cell = [tableView dequeueReusableCellWithIdentifier:FourBookcellIdentifier];
        _hotCellHeight = cell.cellHeight;
        cell.delegate = self;
        if (dataArray_study.count > 0) {
            GFKDTopNodes *node_0 = dataArray_study[0];
            cell.detailLb0.text = node_0.cateName;
            [cell.clickBtn0 sd_setImageWithURL:node_0.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            // 定Tag值,跳转需要
            cell.clickBtn0.tag = 0;
        }
        
        if (dataArray_study.count> 1) {
            GFKDTopNodes *node_1 = dataArray_study[1];
            cell.detailLb1.text = node_1.cateName;
            [cell.clickBtn1 sd_setImageWithURL:node_1.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            // 定Tag值,跳转需要
            cell.clickBtn1.tag = 1;
        }
        
        if (dataArray_study.count > 2) {
            GFKDTopNodes *node_2 = dataArray_study[2];
            cell.detailLb2.text = node_2.cateName;
            [cell.clickBtn2 sd_setImageWithURL:node_2.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            // 定Tag值,跳转需要
            cell.clickBtn2.tag = 2;
        }
        
        if (dataArray_study.count > 3) {
            GFKDTopNodes *node_3 = dataArray_study[3];
            cell.detailLb3.text = node_3.cateName;
            [cell.clickBtn3 sd_setImageWithURL:node_3.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            // 定Tag值,跳转需要
            cell.clickBtn3.tag = 3;
        }
        return cell;
    }else if (indexPath.section == 1){  //爱读书
        TwoSmallCell *cell = [tableView dequeueReusableCellWithIdentifier:TwoSmallCellIdentifier];
        cell.delegate = self;
        _hotCellHeight = cell.cellHeight;
        if (dataArray_book.count > 0) {
            GFKDTopNodes *node_0 = dataArray_book[0 + indexPath.row*2];
            [cell.button0.icon sd_setImageWithURL:node_0.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            cell.button0.categoryLb.text = node_0.cateName;
            cell.button0.tag = 0 + indexPath.row*2;
        }
        if (dataArray_book.count > 1) {
            GFKDTopNodes *node_1 = dataArray_book[1 + indexPath.row*2];
            [cell.button1.icon sd_setImageWithURL:node_1.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            cell.button1.categoryLb.text = node_1.cateName;
            cell.button1.tag = 1 + indexPath.row*2;
        }
        if (indexPath.row != towSmallRow-1) {  //最后一行数据不显示分割线
            [cell.partitionView setHidden:NO];
        }
        return cell;
    }else{ //爱听课
        ThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:ThreeCellIdentifier];
        cell.delegate = self;
        _hotCellHeight = cell.cellHeight;
        if (dataArray_classroom.count > 0) {
            GFKDTopNodes *node_0 = dataArray_classroom[0];
            [cell.clickBtn0 sd_setImageWithURL:node_0.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            cell.detailLb0.text = node_0.cateName;
            cell.clickBtn0.tag = 0;
        }
        if (dataArray_classroom.count > 1) {
            GFKDTopNodes *node_1 = dataArray_classroom[1];
            [cell.clickBtn1 sd_setImageWithURL:node_1.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            cell.detailLb1.text = node_1.cateName;
            cell.clickBtn1.tag = 1;
        }
        if (dataArray_classroom.count > 2) {
            GFKDTopNodes *node_2 = dataArray_classroom[2];
            [cell.clickBtn2 sd_setImageWithURL:node_2.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
            cell.detailLb2.text = node_2.cateName;
            cell.clickBtn2.tag = 2;
        }
        return cell;
    }
    
}
// 配置分组头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleName;
    if (section == 0) {
        titleName = @"爱学习";
    }else if (section == 1) {
        titleName = @"爱读书";
    }else{
        titleName = @"爱听课";
    }
    TitleView *moreView = [[TitleView alloc] initWithTitle:titleName hasMore:YES];
    moreView.hotLb.text = @"HOT";
    moreView.tag = section;
    moreView.delegate = self;
    return moreView;
}

// 设置头高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

// 设置行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return _hotCellHeight*towSmallRow;
    }else{
        return _hotCellHeight;
    }
}

//爱学习  图片点击链接
- (void) imageViewClick:(NSInteger)tag
{
    GFKDTopNodes *node = dataArray_study[tag];
    [self imageViewSkip:node];
}


- (void) ThreeCellImageViewDidChick:(NSInteger)tag cellTag:(NSInteger)cellTag{
    GFKDTopNodes *node = dataArray_classroom[tag];
    [self imageViewSkip:node];
}

- (void) TwoSmallButtonDidChick:(NSInteger)tag{
    GFKDTopNodes *node = dataArray_book[tag];
    [self imageViewSkip:node];
}

- (void) imageViewSkip :(GFKDTopNodes *)nodes
{
    
    NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[nodes.cateId intValue] isSpecial:0];
    newsVC.hidesBottomBarWhenPushed = YES;
    newsVC.title = nodes.cateName;
    [self.navigationController pushViewController:newsVC animated:YES];
}

//点击更多
- (void) titleViewDidClick:(NSInteger)tag
{
    if (tag == 0) {//爱学习
        LikeStudyViewController *likeStudyVC = [[LikeStudyViewController alloc] init];
        likeStudyVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:likeStudyVC animated:YES];
        return;
    }
    if (tag == 1) {//爱读书
        LikeBookViewController *likeBookVC = [[LikeBookViewController alloc] init];
        likeBookVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:likeBookVC animated:YES];
        return;
    }
    if (tag == 2) {//爱听课
        LikeClassroomViewController *likeClassroomVC = [[LikeClassroomViewController alloc] init];
        likeClassroomVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:likeClassroomVC animated:YES];
        return;
    }
}


@end
