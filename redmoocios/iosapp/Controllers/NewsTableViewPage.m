//
//  NewsTableViewPage.m
//  iosapp
//
//  Created by redmooc on 16/4/13.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "NewsTableViewPage.h"
#import "MJRefresh.h"
#import "UIScrollView+MJRefresh.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import "NewsCell.h"
#import "GFKDNews.h"
#import "NewsDetailBarViewController.h"
#import "HomeAdCell.h"
#import "NewsImagesViewController.h"
#import "VideoDetailViewController.h"
#import "NewsViewController.h"


@interface NewsTableViewPage ()<HomeAdCellDelegate>
{
    NSIndexPath    *updateIndexPath;
}
@property (nonatomic,strong) NSMutableArray *arrayList;
@property (nonatomic, copy) NSArray *AdvObjectsDict;
@property(nonatomic,assign)BOOL update;


@end

@implementation NewsTableViewPage

- (instancetype)initWithNewsListType:(NewsTableListType)type cateId:(int)cateId isSpecial:(int)isSpecial
{
    self = [super init];
    
    if (self) {
        _cateId = cateId;
        _myNewsListType = type;
        _isSpecial = isSpecial;
        _urlString = @"headline/T1348647853363";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    __weak NewsTableViewPage *weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.update = YES;
    [weakSelf loadData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(welcome) name:@"SXAdvertisementKey" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
}

- (void)welcome
{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"update"];
    [self.tableView.mj_header beginRefreshing];
}
#pragma mark - /************************* 刷新数据 ***************************/
// ------下拉刷新
- (void)loadData
{
    NSString *allUrlstring;
    NSString *token = [Config getToken];
    NSUInteger page = 1;
    if (_myNewsListType == NewsTableListTypeHomeNews) {//推荐
        allUrlstring = [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&attr=recommend",GFKDAPI_HTTPS_PREFIX,GFKDAPI_HOMENEWS_LIST,(unsigned long)page,GFKDAPI_PAGESIZE,token];
    }else if (_myNewsListType == NewsTableListTypeMsg) {//消息中心
        allUrlstring = [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&nodeIds=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_MSG_PAGE,(unsigned long)page,GFKDAPI_PAGESIZE,token,_cateId];
    }else{//其他
        allUrlstring = [NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=%lu&%@&isSpecial=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,_cateId,(unsigned long)page,GFKDAPI_PAGESIZE,_isSpecial,token];
    }
    
    [self loadDataForType:1 withURL:allUrlstring];
}

// ------上拉加载
- (void)loadMoreData
{
    NSString *allUrlstring;
    NSString *token = [Config getToken];
    NSUInteger page = (self.arrayList.count - self.arrayList.count%GFKD_PAGESIZE);
    if (_myNewsListType == NewsTableListTypeHomeNews) {//推荐
        allUrlstring = [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&attr=recommend",GFKDAPI_HTTPS_PREFIX,GFKDAPI_HOMENEWS_LIST,(unsigned long)page,GFKDAPI_PAGESIZE,token];
    }else if (_myNewsListType == NewsTableListTypeMsg) {//消息中心
        allUrlstring = [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&nodeIds=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_MSG_PAGE,(unsigned long)page,GFKDAPI_PAGESIZE,token,_cateId];
    }else{//其他
        allUrlstring = [NSString stringWithFormat:@"%@%@?cateId=%d&attrType=0&hasPic=0&pageNumber=%lu&%@&isSpecial=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_LIST,_cateId,(unsigned long)page,GFKDAPI_PAGESIZE,_isSpecial,token];
    }
    
    [self loadDataForType:2 withURL:allUrlstring];
    
}

//// ------下拉刷新
//- (void)loadData
//{
//    // http://c.m.163.com//nc/article/headline/T1348647853363/0-30.html
//    NSString *allUrlstring = [NSString stringWithFormat:@"%@/nc/article/%@/0-20.html",@"https://c.m.163.com",self.urlString];
//    [self loadDataForType:1 withURL:allUrlstring];
//}
//
//// ------上拉加载
//- (void)loadMoreData
//{
//    NSString *allUrlstring = [NSString stringWithFormat:@"%@/nc/article/%@/%ld-20.html",@"https://c.m.163.com",self.urlString,(self.arrayList.count - self.arrayList.count%10)];
//    //    NSString *allUrlstring = [NSString stringWithFormat:@"/nc/article/%@/%ld-20.html",self.urlString,self.arrayList.count];
//    [self loadDataForType:2 withURL:allUrlstring];
//}

// ------公共方法
- (void)loadDataForType:(int)type withURL:(NSString *)allUrlstring
{
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
              [self setDict:responseObject[@"result"]];
              if ([responseObject[@"result"][@"msg_code"] integerValue] == 0) {
                  if (!_isHasAdv) {
                      _AdvObjectsDict = responseObject[@"result"][@"adv"];
                      _isHasAdv = _AdvObjectsDict.count ==0 ? FALSE:TRUE;
                  }
              }
            
              NSArray *arrayM = responseObject[@"result"][@"data"];
              
              if (type == 1) {
                  self.arrayList = [arrayM mutableCopy];
                  [self.tableView.mj_header endRefreshing];
                  [self.tableView reloadData];
              }else if(type == 2){
                  [self.arrayList addObjectsFromArray:arrayM];
                  
                  [self.tableView.mj_footer endRefreshing];
                  [self.tableView reloadData];
              }
              
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              MBProgressHUD *HUD = [Utils createHUD];
//              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//              HUD.labelText = @"网络异常，操作失败";
//              
//              [HUD hide:YES afterDelay:1];
              
          }
     ];
    
}// ------想把这里改成block来着

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isHasAdv?2:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            NSInteger rows = _isHasAdv?1:self.arrayList.count;
            return rows;
        }
            break;
            
        case 1:
        {
            return _isHasAdv?self.arrayList.count:0;
        }
            break;
            
        default:
        {
            return 0;
        }
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ((_isHasAdv && indexPath.section == 1) || (!_isHasAdv)) {

        GFKDNews *news = [[GFKDNews alloc] initWithDict:self.arrayList[indexPath.row]];
        NSString *ID = [NewsCell idForRow:news];
        
        NewsCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:ID bundle:nil] forCellReuseIdentifier:ID];
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
        }
        
//        UINib *nib = [UINib nibWithNibName:ID bundle:nil];
//        [tableView registerNib:nib forCellReuseIdentifier:ID ];
//
//        NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        cell.NewsModel = news;
        cell.indexPathRow = (int)indexPath.row;
        cell.indexPathSection = (int)indexPath.section;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return cell;
    }else{
        static NSString *CellIdentifier = @"homeAdCell";
        HomeAdCell *AdCell = (HomeAdCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
        if(AdCell == nil)
        {
            AdCell = [[HomeAdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        AdCell.delegate = self;
        
        if (self.dict != nil) {
            [AdCell getAds:_AdvObjectsDict];
        }
        
        
        return AdCell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_isHasAdv && indexPath.section == 1) || (!_isHasAdv)) {
        GFKDNews *news = [[GFKDNews alloc] initWithDict:self.arrayList[indexPath.row]];
        
        return [NewsCell heightForRow:news];
    }else{
        return 220*kNBR_SCREEN_W/470;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    updateIndexPath = indexPath;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     GFKDNews *news = [[GFKDNews alloc] initWithDict:self.arrayList[indexPath.row]];
    
    if (([news.isSpecial intValue] == 1) && ([news.isToDetail intValue] != 1)) {
        
        NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[news.specialId intValue] isSpecial:1];
        specalViewController.title = news.specialName;
        [self.navigationController pushViewController:specalViewController animated:YES];
        
    }else{
        if ([news.hasImages intValue] == 1) {
            NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
            vc.newsID = [news.articleId intValue];
            [self.navigationController pushViewController:vc animated:YES];
            self.navigationController.navigationBarHidden = YES;
        }else if ([news.hasVideo intValue] == 1) {
            VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            [self.navigationController pushViewController:newsDetailVC animated:YES];
            //[self showVideoController:[news.articleId intValue]];
        }else
        {
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[news.articleId intValue]];
            newsDetailVC.delegate = self;
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }
    }
}


@end
