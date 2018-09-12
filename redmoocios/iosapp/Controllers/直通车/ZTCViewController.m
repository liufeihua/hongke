//
//  ZTCViewController.m
//  iosapp
//
//  Created by redmooc on 16/10/27.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "ZTCViewController.h"
#import "ZWCollectionViewFlowLayout.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import "ColumnViewCell.h"
#import "GFKDDiscover.h"
#import "NewsViewController.h"
#import "NewsDetailBarViewController.h"
#import "CYWebViewController.h"
#import "TakesViewController.h"

#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

static NSString *cellIdentifier = @"ColumnViewCell";

@interface ZTCViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,ZWwaterFlowDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_dataArray;
    ZWCollectionViewFlowLayout *_flowLayout;//自定义layout
}

@end

@implementation ZTCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [[NSMutableArray alloc] init];

    CGRect rect = [[self view] bounds];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:[UIImage imageNamed:@"ztc_bg_1.jpg"]];
    
    [self.view setBackgroundColor:[UIColor clearColor]];   //(1)
    self.view.opaque = NO; //(2) (1,2)两行不要也行，背景图片也能显示
    [self.view addSubview:imageView];
    
    [self initCollectionView];
    [self getZTCItem];
    [self setupRefresh];
}

- (void) getZTCItem
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_DISCOVER]
       parameters:@{@"token":[Config getToken],
                    @"type":@"3",//1：发现；2：政工；3：直通车
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 0) {
                  _dataArray = (NSMutableArray *)[Utils dictionaryWithJsonString:responseObject[@"result"]];
                  if (_collectionView.mj_header.isRefreshing) {
                      [_collectionView.mj_header endRefreshing];
                  }
                  [_collectionView reloadData];
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

- (void) setupRefresh{
    _collectionView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadSearchData)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
}

- (void) loadSearchData{
    [self getZTCItem];
}

-(void)initCollectionView
{
    //初始化自定义layout
    _flowLayout = [[ZWCollectionViewFlowLayout alloc] init];
    _flowLayout.degelate = self;
    _flowLayout.colCount=3;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kNBR_SCREEN_W, kNBR_SCREEN_H - 64) collectionViewLayout: _flowLayout];
    //注册显示的cell的类型
    
    UINib *cellNib=[UINib nibWithNibName:@"ColumnViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor= RGBA(200, 200, 200, 0.25);
    _collectionView.scrollsToTop = NO;
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    //return _dataArray.count;
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_dataArray.count > 0) {
        NSDictionary *items = _dataArray[section][@"items"];
        return items.count;
    }else{
        return 0;
    }
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     GFKDDiscover *grid = [[GFKDDiscover alloc] initWithDict:_dataArray[indexPath.section][@"items"][indexPath.row]];
    //重用cell
    ColumnViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setContentWith:grid];
    
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

#pragma mark ZWwaterFlowDelegate
- (CGFloat)ZWwaterFlow:(ZWCollectionViewFlowLayout *)waterFlow heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPach
{
    //return kNBR_SCREEN_W/3.0*KWidth_Scale;
    return 120;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDDiscover *grid = [[GFKDDiscover alloc] initWithDict:_dataArray[indexPath.section][@"items"][indexPath.row]];
    [Utils showLinkViewController:grid WithNowVC:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
