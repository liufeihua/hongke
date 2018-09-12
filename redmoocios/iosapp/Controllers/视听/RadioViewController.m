//
//  RadioTableViewController.m
//  iosapp
//
//  Created by redmooc on 16/8/16.
//  Copyright © 2016年 redmooc. All rights reserved.
//
#define RGBA(r,g,b,a)      [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]

#import "RadioViewController.h"
#import "ZWCollectionViewFlowLayout.h"
#import "FourCollectionCell.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "OSCAPI.h"
#import "NewsViewController.h"
//相对iphone6 屏幕比
#define KWidth_Scale    [UIScreen mainScreen].bounds.size.width/375.0f

@interface RadioViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,ZWwaterFlowDelegate>
{
    UICollectionView *_collectionView;
    ZWCollectionViewFlowLayout *_flowLayout;//自定义layout
    NSMutableArray *_dataArray;
    float _boundsHeight;
    NSString *_number;
}

@end

static NSString *cellIdentifier = @"RadioViewCell";

@implementation RadioViewController

- (instancetype)initWithFrameHeight:(float)frameHeight withNumber:(NSString *)number{
    self = [super init];
    if (self) {
        _boundsHeight = frameHeight;
        _number = number;
    }
    return self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor grayColor];
    [self initCollectionView];
    
    [self setupRefresh];
    _dataArray = [[NSMutableArray alloc] init];
    [self loadRadio];
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
    [self loadRadio];
}

- (void) loadRadio
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@/m-nodeList.htx", GFKDAPI_HTTPS_PREFIX]
      parameters:@{@"token":[Config getToken],
                   @"number":_number}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             [_dataArray removeAllObjects];
             NSArray *array = responseObject[@"result"][@"data"];
             for (int i=0; i<array.count; i++) {
                 GFKDTopNodes *nodes = [[GFKDTopNodes alloc] initWithDict:array[i]];
                 [_dataArray addObject:nodes];
             }
             if (_collectionView.mj_header.isRefreshing) {
                 [_collectionView.mj_header endRefreshing];
             }
             [_collectionView reloadData];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initCollectionView
{
    //初始化自定义layout
    _flowLayout = [[ZWCollectionViewFlowLayout alloc] init];
    _flowLayout.colMagrin = 0;
    _flowLayout.rowMagrin = 0;
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _flowLayout.colCount = 2;
    _flowLayout.degelate = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout: _flowLayout];
    //注册显示的cell的类型
    
    UINib *cellNib=[UINib nibWithNibName:@"FourCollectionCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    
    [_collectionView setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, _boundsHeight)];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    //_collectionView.backgroundColor=RGBA(200, 200, 200, 0.25);
    _collectionView.backgroundColor=RGBA(20, 20, 20, 1.0);
    [self.view addSubview:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //重用cell
    FourCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.model=_dataArray[indexPath.item];
    
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"你点击了 %ld--%ld",(long)indexPath.section,indexPath.item);
    GFKDTopNodes *nodes = _dataArray[indexPath.item];
    
    NewsViewController *videoVC=[[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[nodes.cateId intValue] isSpecial:0];
    videoVC.title = nodes.cateName;
    videoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:videoVC animated:YES];
    
}


#pragma mark ZWwaterFlowDelegate
- (CGFloat)ZWwaterFlow:(ZWCollectionViewFlowLayout *)waterFlow heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPach
{
    
    return 200*KWidth_Scale;
}


@end
