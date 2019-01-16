//
//  LikeClassroomViewController.m
//  iosapp
//
//  Created by redmooc on 17/6/8.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "LikeClassroomViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "GFKDNews.h"
#import "GFKDTopNodes.h"
#import "OneSpecialCell.h"
#import "TwoVedioCell.h"
#import "ThreeCell.h"
#import "UIImageView+WebCache.h"
#import "TitleView.h"
#import <Masonry/Masonry.h>
#import "HomeAdCell.h"
#import "NewsViewController.h"
#import "CYWebViewController.h"
#import "NewsImagesViewController.h"
#import "NewsCell.h"
#import "EPUBParser.h"
#import "EPUBReadMainViewController.h"
#import "NewsDetailBarViewController.h"
#import "LSYReadPageViewController.h"
#import "SDCycleScrollView.h"

@interface LikeClassroomViewController ()<UITableViewDelegate,UITableViewDataSource,TitleViewDelegate,HomeAdCellDelegate,ThreeCellDelegate,SDCycleScrollViewDelegate>
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *AdvObjectsDict;
@property (nonatomic, assign) BOOL isHasAdv;

@property (strong, nonatomic) EPUBParser *epubParser; //epub解析器，成员变量或全局

@end

static NSString *ThreeCellIdentifier = @"ThreeCell";
static NSString *TwoVedioCellIdentifier = @"TwoVedioCell";

static int ThreeRow = 1;
//static int TwoVedioRow = 2;

@implementation LikeClassroomViewController
{
    NSMutableArray *dataArray_classroom_top;
    NSMutableArray *dataArray_classroom_vedio;
    int nodeCount,current_loadCount;//子栏目数
    CGFloat _hotCellHeight;
    NSMutableArray *dataArray_head;
    SDCycleScrollView *_headView;
    NSMutableArray *_imageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"爱听课";
    dataArray_classroom_top = [[NSMutableArray alloc] init];
    dataArray_classroom_vedio = [[NSMutableArray alloc] init];
    dataArray_head = [[NSMutableArray alloc] init];
    
    _imageArray = [NSMutableArray array];
    
    current_loadCount = 0;
    [self initHeadView];
    [self addSubViewTableView];
    
    [self loadNodeMsg];
    [self loadClassroomNode];
    
    //前提条件
    _epubParser=[[EPUBParser alloc] init];
}

-(void)initHeadView
{
    _headView=[SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 160*KWidth_Scale) imageURLStringsGroup:_imageArray];
    _headView.placeholderImage=[UIImage imageNamed:@"item_default"];
    _headView.delegate=self;
    _headView.pageControlStyle=SDCycleScrollViewPageContolStyleClassic;
    _headView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _headView.titleLabelTextFont=[UIFont systemFontOfSize:14];
    _headView.autoScroll = NO;
}

- (void) addSubViewTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[ThreeCell class] forCellReuseIdentifier:ThreeCellIdentifier];
    [_tableView registerClass:[TwoVedioCell class] forCellReuseIdentifier:TwoVedioCellIdentifier];
    // 去掉分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 越界不能上下拉
    _tableView.bounces = NO;
    
    _tableView.tableHeaderView = _headView;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
}

- (void) loadNodeMsg{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeByNumber.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":@"atk"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             GFKDTopNodes *node = [[GFKDTopNodes alloc] initWithDict:responseObject[@"result"]];
             [_imageArray addObject:node.smallImage];
             _headView.imageURLStringsGroup = _imageArray;
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}
//爱听课栏目
- (void) loadClassroomNode
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":@"atk"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             _AdvObjectsDict = responseObject[@"result"][@"adv"];
             _isHasAdv = _AdvObjectsDict.count ==0 ? FALSE:TRUE;
             
             [dataArray_classroom_vedio removeAllObjects];
             [dataArray_head removeAllObjects];
             NSArray *array = responseObject[@"result"][@"data"];
             nodeCount = (int)array.count;
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [self loadClassroomNewsWithCateId:[nodes.cateId intValue] withCateName:nodes.cateName];
                 [dataArray_head addObject:nodes];
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

- (void) loadClassroomNewsWithCateId:(int)cateId withCateName:(NSString *)cateName{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager GET:[NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=0&%@&isSpecial=%d&token=%@&showDescendants=1",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,cateId,@"pageSize=4",0,[Config getToken]]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
                 
             }
             
//             if ([cateName isEqualToString: @"精品课程"]) {
//                 [dataArray_classroom_top removeAllObjects];
//                 NSArray *array = responseObject[@"result"][@"data"];
//                 for (int i=0; i<array.count; i++) {
//                     GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
//                     [dataArray_classroom_top addObject:news];
//                 }
//             }else{
                 NSMutableArray *Data = [[NSMutableArray alloc] init];
                 [Data removeAllObjects];
                 NSArray *array = responseObject[@"result"][@"data"];
                 for (int i=0; i<array.count; i++) {
                     GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
                     [Data addObject:news];
                 }
                 [dataArray_classroom_vedio addObject:Data];
//             }
             current_loadCount ++;
             if (current_loadCount == nodeCount) {
                 [self.tableView reloadData];
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


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _isHasAdv?nodeCount+1:nodeCount;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int num=0;
    if (_isHasAdv) {
        num = 1;
        if (section == 0) {
            return 1;
        }
    }
//    if (section == num) {
//        return ThreeRow;
//    }else{
//        return TwoVedioRow;
//    }
    return ThreeRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int num=0;
    if (_isHasAdv) {
        num = 1;
        if (indexPath.section == 0) {
            static NSString *CellIdentifier = @"homeAdCell";
            HomeAdCell *AdCell = (HomeAdCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
            if(AdCell == nil)
            {
                AdCell = [[HomeAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            AdCell.delegate = self;
            [AdCell getAds:_AdvObjectsDict];
            return AdCell;
        }
    }
 
    ThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:ThreeCellIdentifier];
    cell.tag = indexPath.section-num;
    cell.delegate = self;
    _hotCellHeight = cell.cellHeight;
    NSArray *array = dataArray_classroom_vedio[indexPath.section-num];
    if (array.count > 0) {
        GFKDNews *news_0 = array[0];
        [cell.clickBtn0 sd_setImageWithURL:news_0.image placeholderImage:[UIImage imageNamed:@"item_default"]];
        cell.detailLb0.text = news_0.title;
        cell.clickBtn0.tag = 0;
    }
    if (array.count > 1) {
        GFKDNews *news_1 = array[1];
        [cell.clickBtn1 sd_setImageWithURL:news_1.image placeholderImage:[UIImage imageNamed:@"item_default"]];
        cell.detailLb1.text = news_1.title;
        cell.clickBtn1.tag = 1;
    }
    if (array.count > 2) {
        GFKDNews *news_2 = array[2];
        [cell.clickBtn2 sd_setImageWithURL:news_2.image placeholderImage:[UIImage imageNamed:@"item_default"]];
        cell.detailLb2.text = news_2.title;
        cell.clickBtn2.tag = 2;
    }
    return cell;
    
    
//    if (indexPath.section == num) {
//        ThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:ThreeCellIdentifier];
//  //      cell.delegate = self;
//        _hotCellHeight = cell.cellHeight;
//        NSArray *array = dataArray_classroom_vedio[indexPath.section-num];
//        if (array.count > 0) {
//            GFKDNews *news_0 = array[0];
//            [cell.clickBtn0 sd_setImageWithURL:news_0.image placeholderImage:[UIImage imageNamed:@"item_default"]];
//            cell.detailLb0.text = news_0.title;
//        }
//        if (array.count > 1) {
//            GFKDNews *news_1 = array[1];
//            [cell.clickBtn1 sd_setImageWithURL:news_1.image placeholderImage:[UIImage imageNamed:@"item_default"]];
//            cell.detailLb1.text = news_1.title;
//        }
//        if (array.count > 2) {
//            GFKDNews *news_2 = array[2];
//            [cell.clickBtn2 sd_setImageWithURL:news_2.image placeholderImage:[UIImage imageNamed:@"item_default"]];
//            cell.detailLb2.text = news_2.title;
//        }
//        return cell;
//    }else{
//        TwoVedioCell *cell = [tableView dequeueReusableCellWithIdentifier:TwoVedioCellIdentifier];
//        _hotCellHeight = cell.cellHeight;
//        cell.isShowVedioImage = YES;
//        NSArray *array = dataArray_classroom_vedio[indexPath.section-num];
//        if (array.count > 0 + indexPath.row *2) {
//            GFKDNews *news_0 = array[0 + indexPath.row *2];
//            cell.detailLb0.text = news_0.title;
//            [cell.clickBtn0 sd_setImageWithURL:news_0.image placeholderImage:[UIImage imageNamed:@"item_default"]];
//        }
//        if (array.count > 1 + indexPath.row *2) {
//            GFKDNews *news_1 = array[1 + indexPath.row*2];
//            [cell.clickBtn1 sd_setImageWithURL:news_1.image placeholderImage:[UIImage imageNamed:@"item_default"]];
//            cell.detailLb1.text = news_1.title;
//        }
//        return cell;
//    }
}
// 配置分组头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    int num=0;
    if (_isHasAdv) {
        num = 1;
        if (section == 0) {
            return nil;
        }
    }

//    GFKDTopNodes *node = dataArray_head[section - num];
//    
//    TitleView *moreView = [[TitleView alloc] initWithTitle:node.cateName hasMore:YES];
//    moreView.descriptionLb.text = @"在线学习";//node.dataDict[@"description"];
//    // 定义TitleView的tag  可以通过tag知section
//    moreView.tag = section;
//    moreView.delegate = self;
//    return moreView;
    
    NSString *titleName;
    if ([dataArray_classroom_vedio[section] count] > 0) {
        GFKDNews *news = dataArray_classroom_vedio[section][0];
        titleName = news.categroy;
        TitleView *moreView = [[TitleView alloc] initWithTitle:titleName hasMore:YES];
        moreView.descriptionLb.text = @"在线学习";
        moreView.tag = section;
        moreView.delegate = self;
        return moreView;
    }else{
        return nil;
    }
    

}

// 设置头高
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    int num=0;
    if (_isHasAdv) {
        num = 1;
        if (section == 0) {
            return 0;
        }
    }
    return 35;
}

// 设置行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int num=0;
    if (_isHasAdv) {
        num = 1;
        if (indexPath.section == 0) {
//            return 220*kNBR_SCREEN_W/470;
            return 160*KWidth_Scale;
        }
    }
    return _hotCellHeight;
}


#pragma mark TitleViewDelegate
- (void) titleViewDidClick:(NSInteger)tag{
    GFKDNews *news = dataArray_classroom_vedio[tag][0];
    NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[news.cateId intValue] isSpecial:0];
    newsVC.hidesBottomBarWhenPushed = YES;
    newsVC.title = news.categroy;
    [self.navigationController pushViewController:newsVC animated:YES];
}


- (void) ThreeCellImageViewDidChick:(NSInteger)tag cellTag:(NSInteger)cellTag{
    GFKDNews *news = dataArray_classroom_vedio[cellTag][tag];
    
    if (([news.isSpecial intValue] == 1) && ([news.isToDetail intValue] != 1)) {
        
        NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[news.specialId intValue] isSpecial:1];
        specalViewController.hidesBottomBarWhenPushed = YES;
        specalViewController.title = news.specialName;
        [self.navigationController pushViewController:specalViewController animated:YES];
        
    }else{
        if (((NSNull *)news.detailUrl != [NSNull null]) && (![news.detailUrl isEqualToString:@""])) {
            NSString *newUrl = [Utils replaceWithUrl:news.detailUrl];
            
            CYWebViewController *webViewController = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:newUrl]];
            webViewController.hidesBottomBarWhenPushed = YES;
            webViewController.navigationButtonsHidden = YES;
            webViewController.loadingBarTintColor = [UIColor redColor];
            [self.navigationController pushViewController:webViewController animated:YES];
            return;
        }
        if ([news.hasImages intValue] == 1) {
            NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
            vc.hidesBottomBarWhenPushed = YES;
            vc.newsID = [news.articleId intValue];
            vc.parentVC = self;
            [self presentViewController:vc animated:YES completion:nil];
        }else if ([news.hasVideo intValue] == 1 || [news.hasAudio intValue] == 1 ) {
            VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }else if (((NSNull *)news.isReader != [NSNull null]) && ([news.isReader intValue]== 1)){
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* _filePath = [paths objectAtIndex:0];
            //File Url
            NSString* fileUrl = news.file;
            //Encode Url 如果Url 中含有空格，一定要先 Encode
            fileUrl = [fileUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            //创建 Request
            NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
            NSString* fileName = [NSString stringWithFormat:@"sqmple.%@",news.readerSuffix];
            NSString* filePath = [_filePath stringByAppendingPathComponent:fileName];
            //下载进行中的事件
            AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.labelText = @"正在加载";
            [operation setCompletionBlock:^{
                [HUD hide:YES afterDelay:0];
                if ([news.readerSuffix isEqualToString:@"epub"]) {
                    NSMutableDictionary *fileInfo=[NSMutableDictionary dictionary];
                    [fileInfo setObject:filePath forKey:@"fileFullPath"];
                    
                    EPUBReadMainViewController *epubVC=[EPUBReadMainViewController new];
                    epubVC.epubParser=self.epubParser;
                    epubVC.fileInfo=fileInfo;
                    
                    epubVC.epubReadBackBlock=^(NSMutableDictionary *para1){
                        NSLog(@"回调=%@",para1);
                        [self dismissViewControllerAnimated:YES completion:nil];
                        return 1;
                    };
                    [self.navigationController presentViewController:epubVC animated:YES completion:nil];
                    
                }else if ([news.readerSuffix isEqualToString:@"txt"]){
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
                    LSYReadPageViewController *pageView = [[LSYReadPageViewController alloc] init];
                    pageView.resourceURL = fileURL;  //文件位置
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        pageView.model = [LSYReadModel getLocalModelWithURL:fileURL];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentViewController:pageView animated:YES completion:nil];
                        });
                    });
                }
                //NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"细说明朝"withExtension:@"epub"];
            }];
            
            [operation start];
            
        }else{
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }
    }
}


#pragma mark HomeAdCellDelegate
- (void) adClick:(GFKDHomeAd *)adv{
    //
}

#pragma SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
   
}

@end
