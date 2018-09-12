//
//  LikeStudyViewController.m
//  iosapp
//
//  Created by redmooc on 17/6/7.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "LikeStudyViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "GFKDNews.h"
#import "GFKDTopNodes.h"
#import "OneSpecialCell.h"
#import "TwoVedioCell.h"
//#import "UIButton+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "TitleView.h"
#import <Masonry/Masonry.h>
#import "NewsViewController.h"
#import "SDCycleScrollView.h"

@interface LikeStudyViewController ()<UITableViewDelegate,UITableViewDataSource,TitleViewDelegate,SDCycleScrollViewDelegate>
@property (nonatomic,strong) UITableView *tableView;

@end

static NSString *OneSpecialcellIdentifier = @"OneSpecialCell";
static NSString *TwoVedioCellIdentifier = @"TwoVedioCell";

//static int OneSpecialRow = 4;
//static int TwoVedioRow = 2;

@implementation LikeStudyViewController
{
//    NSMutableArray *dataArray_studyData; //资料库
//    NSMutableArray *dataArray_studyVedio; //视频课程
//    BOOL studyDataLoad,studyVedioLoad;
    CGFloat _hotCellHeight;
    
    NSMutableArray *dataArray_node;
    SDCycleScrollView *_footView;
    NSMutableArray *_AdArray;
    NSMutableArray *_imageArray;
    NSMutableArray *_titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"爱学习";
//    dataArray_studyData = [[NSMutableArray alloc] init];
//    dataArray_studyVedio = [[NSMutableArray alloc] init];
    dataArray_node = [[NSMutableArray alloc] init];
//    studyDataLoad = false;
//    studyVedioLoad = false;
    
    _AdArray=[NSMutableArray array];
    _imageArray = [NSMutableArray array];
    _titleArray = [NSMutableArray array];
    
    [self initFootView];
     [self addSubViewTableView];
    
    [self getZGAD];
    [self loadStutyNode];
    
}

-(void)initFootView
{
    _footView=[SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 160*KWidth_Scale) imagesGroup:_imageArray];
    //_footView.titlesGroup=_titleArray;
    _footView.placeholderImage=[UIImage imageNamed:@"item_default"];
    _footView.delegate=self;
    _footView.pageControlStyle=SDCycleScrollViewPageContolStyleClassic;
    _footView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _footView.titleLabelTextFont=[UIFont systemFontOfSize:14];
    
}

- (void) addSubViewTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[OneSpecialCell class] forCellReuseIdentifier:OneSpecialcellIdentifier];
    [_tableView registerClass:[TwoVedioCell class] forCellReuseIdentifier:TwoVedioCellIdentifier];
    
    // 去掉分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 越界不能上下拉
    _tableView.bounces = NO;
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
    _tableView.tableFooterView = _footView;
}

- (void) getZGAD
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_LISTAD]
       parameters:@{@"token":[Config getToken],
                    @"number":@"axx",
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 0) {
                  [_AdArray removeAllObjects];
                  [_imageArray removeAllObjects];
                  [_titleArray removeAllObjects];
                  _AdArray = responseObject[@"result"];
                  for (NSDictionary *objectDict in _AdArray) {
                      GFKDHomeAd *adv = [[GFKDHomeAd alloc] initWithDict:objectDict];
                      [_imageArray addObject:adv.imgUrl];
                      [_titleArray addObject:adv.advTitle];
                  }
                  _footView.imageURLStringsGroup = _imageArray;
                  _footView.titlesGroup=_titleArray;
              } else {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，/m-listAd.htx 调用失败";
              
              [HUD hide:YES afterDelay:1];
          }];
}

//爱学习栏目
- (void) loadStutyNode
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":@"axx"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             NSArray *array = responseObject[@"result"][@"data"];
             [dataArray_node removeAllObjects];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 //[self loadStudyNewsWithCateId:[nodes.cateId intValue] withCateName:nodes.cateName];
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

//- (void) loadStudyNewsWithCateId:(int)cateId withCateName:(NSString *)cateName{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=1",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,cateId,@"pageSize=4",0,[Config getToken]]
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//             NSString *errorMessage = responseObject[@"reason"];
//             if (errorCode == 1) {
//                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
//                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
//                 
//                 return;
//                 
//             }
//             if ([cateName isEqualToString: @"资料库"]) {
//                 [dataArray_studyData removeAllObjects];
//                 NSArray *array = responseObject[@"result"][@"data"];
//                 for (int i=0; i<array.count; i++) {
//                     GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
//                     [dataArray_studyData addObject:news];
//                 }
//                 studyDataLoad = true;
//             }
//             if ([cateName isEqualToString: @"视频课程"]) {
//                 [dataArray_studyVedio removeAllObjects];
//                 NSArray *array = responseObject[@"result"][@"data"];
//                 for (int i=0; i<array.count; i++) {
//                     GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
//                     [dataArray_studyVedio addObject:news];
//                 }
//                 studyVedioLoad = true;
//             }
//             [self isReloadTableView];
//             
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
//}

//- (void) isReloadTableView{
//    if (studyDataLoad && studyVedioLoad) {
//        [self.tableView reloadData];
//    }
//}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   // return 2;
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray_node.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OneSpecialCell *cell = [tableView dequeueReusableCellWithIdentifier:OneSpecialcellIdentifier];
    _hotCellHeight = cell.cellHeight;
    //cell.delegate = self;
    GFKDTopNodes *node = dataArray_node[indexPath.row];
    [cell.coverImage sd_setImageWithURL:node.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
    // [cell.coverBtn setImageForState:UIControlStateNormal withURL:news_0.image placeholderImage:[UIImage imageNamed:@"item_default"]];
    cell.titleLb.text = node.cateName;
    cell.subTitleLb.text = node.dataDict[@"description"];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GFKDTopNodes *node = dataArray_node[indexPath.row];
    NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[node.cateId intValue] isSpecial:0];
    newsVC.hidesBottomBarWhenPushed = YES;
    newsVC.title = node.cateName;
    [self.navigationController pushViewController:newsVC animated:YES];
}
// 配置分组头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TitleView *moreView = [[TitleView alloc] initWithTitle:@"资料库" hasMore:NO];
    moreView.descriptionLb.text = @"各种学习资料打包下载，在线阅读";
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
    return _hotCellHeight;
}

- (void) titleViewDidClick:(NSInteger)tag{
}

#pragma SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    GFKDHomeAd *adv = [[GFKDHomeAd alloc] initWithDict:_AdArray[index]];
    [Utils showLinkAD:adv WithNowVC:self];
}

@end
