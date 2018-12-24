//
//  ZGViewController.m
//  iosapp
//
//  Created by redmooc on 16/10/26.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "ZGViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "SDCycleScrollView.h"
#import "HeadTableViewCell.h"
#import "NewShowViewCell.h"
#import "GFKDHomeAd.h"
#import "GFKDDiscover.h"
#import "CYWebViewController.h"
#import "NewsDetailBarViewController.h"
#import "NewsViewController.h"
#import "NewsImagesViewController.h"
#import "TakesViewController.h"

@interface ZGViewController ()<UITableViewDelegate,UITableViewDataSource,SDCycleScrollViewDelegate,NewShowViewCellDelegate>
{
    UITableView *_tableView;
    SDCycleScrollView *_headView;
    
    HeadTableViewCell *_CellHeadView;
    
    NSMutableArray *_DataArray;
    NSMutableArray *_AdArray;
    NSMutableArray *_imageArray;
    NSMutableArray *_titleArray;
}


@end

@implementation ZGViewController

-(void)initTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H) style:UITableViewStyleGrouped];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.tableHeaderView=_headView;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
}

-(void)initHeadView
{
    _headView=[SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 160*KWidth_Scale) imageURLStringsGroup:_imageArray];
    //_headView.titlesGroup=_titleArray;
    _headView.placeholderImage=[UIImage imageNamed:@"item_default"];
    _headView.delegate=self;
    _headView.pageControlStyle=SDCycleScrollViewPageContolStyleClassic;
    _headView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    _headView.titleLabelTextFont=[UIFont systemFontOfSize:14];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _DataArray=[NSMutableArray array];
    _AdArray=[NSMutableArray array];
    _imageArray = [NSMutableArray array];
    _titleArray = [NSMutableArray array];
    [self initNavigation];
    [self initHeadView];
    [self initTableView];
    
    [self getZGAD];
    [self getZGItem];
    [self setupRefresh];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ZG_imageArray"]!=nil){
        NSMutableArray *ZG_imageArray  = [NSMutableArray arrayWithArray:[user objectForKey:@"ZG_imageArray"]];
        _imageArray = ZG_imageArray;
        _headView.imageURLStringsGroup=ZG_imageArray;
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ZG_titleArray"]!=nil){
        NSMutableArray *ZG_titleArray  = [NSMutableArray arrayWithArray:[user objectForKey:@"ZG_titleArray"]];
        _titleArray = ZG_titleArray;
        _headView.titlesGroup=ZG_titleArray;
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ZG_DataArray"]!=nil){
        _DataArray = (NSMutableArray *)[Utils dictionaryWithJsonString:[user objectForKey:@"ZG_DataArray"]];
        [_tableView reloadData];
    }
}

- (void) setupRefresh{
    _tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadSearchData)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
}

- (void) loadSearchData{
    [self getZGAD];
    [self getZGItem];
}

- (void) initNavigation{
    UIImage *logoImage = [UIImage imageNamed:@"e_zg"];
    CGFloat imageW = logoImage.size.width*36.0/logoImage.size.height;
    CGFloat imageH = 36;
    CGFloat x = kNBR_SCREEN_W/2.0 - imageW/2.0;
    CGFloat y = 0;
    UIView *titleView = [[UIView alloc] init];
    [titleView setFrame:CGRectMake(x, y, imageW, imageH)];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,imageW,imageH)];
    [logoImageView setImage:logoImage];
    [titleView addSubview:logoImageView];
    
    self.navigationItem.titleView = titleView;
}

- (void) getZGAD
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_LISTAD]
       parameters:@{@"token":[Config getToken],
                    @"number":@"throughTrain",
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 0) {
                  [_AdArray removeAllObjects];
                  [_imageArray removeAllObjects];
                  [_titleArray removeAllObjects];
                  //_AdArray = responseObject[@"result"];//直接用 “ = ”赋值,这个对象居然变为不可变了,下一次remove时报错。
                  // 改为用"for"循环重新add到可变数组中，。
                  for (NSDictionary *object in responseObject[@"result"]) {
                      [_AdArray addObject:object];
                  }
                  for (NSDictionary *objectDict in _AdArray) {
                      GFKDHomeAd *adv = [[GFKDHomeAd alloc] initWithDict:objectDict];
                      [_imageArray addObject:adv.imgUrl];
                      [_titleArray addObject:adv.advTitle];
                }
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSMutableArray *ZG_imageArray = [NSMutableArray arrayWithArray:[user objectForKey:@"ZG_imageArray"]];
                if (![_imageArray isEqualToArray:ZG_imageArray]) {
                      [user setObject:_imageArray forKey:@"ZG_imageArray"];
                    _headView.imageURLStringsGroup=_imageArray;
                }
                NSMutableArray *ZG_titleArray = [NSMutableArray arrayWithArray:[user objectForKey:@"ZG_titleArray"]];
                  
                if (![_titleArray isEqualToArray:ZG_titleArray]) {
                      [user setObject:_titleArray forKey:@"ZG_titleArray"];
                    _headView.titlesGroup=_titleArray;
                }
                  
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

- (void) getZGItem
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_DISCOVER]
       parameters:@{@"token":[Config getToken],
                    @"type":@"2",//1：发现；2：政工；3：直通车
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 0) {
                  if (_tableView.mj_header.isRefreshing) {
                      [_tableView.mj_header endRefreshing];
                  }
                  
                  NSString *DataArray = responseObject[@"result"];
                  NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                  NSString *ZG_DataArray = [user objectForKey:@"ZG_DataArray"];
                  if (![DataArray isEqualToString:ZG_DataArray]) {
                      [user setObject:responseObject[@"result"] forKey:@"ZG_DataArray"];
                      [_DataArray removeAllObjects];
                      _DataArray = (NSMutableArray *)[Utils dictionaryWithJsonString:responseObject[@"result"]];
                      [_tableView reloadData];
                  }
              } else {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
          }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _DataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = _DataArray[indexPath.section][@"items"];
    return  90 + (array.count-1)/4 * (90);
    //return 90;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld,%ld",indexPath.section,indexPath.row);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identfire=@"NewShowViewCell";
    NewShowViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identfire];
    if (!cell) {
        
        cell=[[NewShowViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfire];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell setContentView:_DataArray[indexPath.section][@"items"]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _CellHeadView=[[HeadTableViewCell alloc]init];
    _CellHeadView.tag=section;
    _CellHeadView.title.text= _DataArray[section][@"serviceName"];
    return _CellHeadView;
}

#pragma SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    GFKDHomeAd *adv = [[GFKDHomeAd alloc] initWithDict:_AdArray[index]];
    [Utils showLinkAD:adv WithNowVC:self];
}

#pragma NewShowViewCellDelegate
- (void) NewShowViewCellWithModel:(GFKDDiscover *)model{
    [Utils showLinkViewController:model WithNowVC:self];
}
@end
