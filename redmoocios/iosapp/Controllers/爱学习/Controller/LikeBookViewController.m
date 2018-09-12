//
//  LikeBookViewController.m
//  iosapp
//
//  Created by redmooc on 17/6/8.
//  Copyright © 2017年 redmooc. All rights reserved.
//

#import "LikeBookViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "GFKDNews.h"
#import "GFKDTopNodes.h"
#import "OneSpecialCell.h"
#import "UIImageView+WebCache.h"
#import "TitleView.h"
#import <Masonry/Masonry.h>

#import "NewsViewController.h"
#import "CYWebViewController.h"
#import "NewsImagesViewController.h"
#import "NewsCell.h"
#import "EPUBParser.h"
#import "EPUBReadMainViewController.h"
#import "NewsDetailBarViewController.h"
#import "LSYReadPageViewController.h"

@interface LikeBookViewController ()<UITableViewDataSource,UITableViewDelegate,TitleViewDelegate>
@property (nonatomic,strong) UITableView *tableView;

@property (strong, nonatomic) EPUBParser *epubParser; //epub解析器，成员变量或全局

@end

static NSString *OneSpecialcellIdentifier = @"OneSpecialCell";

static int OneSpecialRow = 4;


@implementation LikeBookViewController
{
    NSMutableArray *dataArray_book;
    int nodeCount,current_loadCount;//子栏目数
    CGFloat _hotCellHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"爱读书";
    dataArray_book = [[NSMutableArray alloc] init];
    current_loadCount = 0;
    [self addSubViewTableView];
    [self loadBookNode];
    
    //前提条件
    _epubParser=[[EPUBParser alloc] init];
}

- (void) addSubViewTableView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[OneSpecialCell class] forCellReuseIdentifier:OneSpecialcellIdentifier];
    
    // 去掉分割线
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 越界不能上下拉
    _tableView.bounces = NO;
    
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 0.01f)];
}

//爱读书栏目
- (void) loadBookNode
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":@"ads"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             NSArray *array = responseObject[@"result"][@"data"];
             nodeCount = (int)array.count;
             [dataArray_book removeAllObjects];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [self loadBookNewsWithCateId:[nodes.cateId intValue] withCateName:nodes.cateName];
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


- (void) loadBookNewsWithCateId:(int)cateId withCateName:(NSString *)cateName{
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
            
             NSMutableArray *bookData = [[NSMutableArray alloc] init];
             [bookData removeAllObjects];
             NSArray *array = responseObject[@"result"][@"data"];
             for (int i=0; i<array.count; i++) {
                 GFKDNews *news = [[GFKDNews alloc] initWithDict:array[i]];
                 [bookData addObject:news];
             }
             [dataArray_book addObject:bookData];
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
    return nodeCount;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArray_book[section] count] >=4 ? OneSpecialRow:[dataArray_book[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OneSpecialCell *cell = [tableView dequeueReusableCellWithIdentifier:OneSpecialcellIdentifier];
    _hotCellHeight = cell.cellHeight;
    //cell.delegate = self;
    GFKDNews *news_0 = dataArray_book[indexPath.section][indexPath.row];
    [cell.coverImage sd_setImageWithURL:news_0.image placeholderImage:[UIImage imageNamed:@"item_default"]];
    cell.titleLb.text = news_0.title;
    cell.subTitleLb.text = news_0.dataDict[@"description"];
    return cell;
}
// 配置分组头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleName;
    GFKDNews *news = dataArray_book[section][0];
    titleName = news.categroy;
    TitleView *moreView = [[TitleView alloc] initWithTitle:titleName hasMore:YES];
    // 定义TitleView的tag  可以通过tag知section
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GFKDNews *news = dataArray_book[indexPath.section][indexPath.row];
    
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
            [self.navigationController pushViewController:vc animated:YES];
            self.navigationController.navigationBarHidden = YES;
        }else if ([news.hasVideo intValue] == 1 || [news.hasAudio intValue] == 1 ) {
            NSString *ID = [NewsCell idForRow:news];
            NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
            [cell closeVedio];
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


- (void) titleViewDidClick:(NSInteger)tag{
    GFKDNews *news = dataArray_book[tag][0];
    NewsViewController *newsVC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[news.cateId intValue] isSpecial:0];
    newsVC.hidesBottomBarWhenPushed = YES;
    newsVC.title = news.categroy;
    [self.navigationController pushViewController:newsVC animated:YES];
    
}


@end
