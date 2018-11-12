//
//  TemplateChooseViewController.m
//  iosapp
//
//  Created by redmooc on 2018/11/9.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "TemplateChooseViewController.h"
#import "ZWCollectionViewFlowLayout.h"
#import "TemplateViewCell.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "OSCAPI.h"
#import <MJRefresh.h>
#import "GFKDAd.h"

//相对iphone6 屏幕比
#define KWidth_Scale    [UIScreen mainScreen].bounds.size.width/375.0f

@interface TemplateChooseViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,ZWwaterFlowDelegate>
{
    UICollectionView *_collectionView;
    ZWCollectionViewFlowLayout *_flowLayout;//自定义layout
    NSMutableArray *_dataArray;
}

@end

static NSString *cellIdentifier = @"TemplateViewCell";

@implementation TemplateChooseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"模板选择";
    self.view.backgroundColor=[UIColor whiteColor];
    [self initCollectionView];
    
    [self setupRefresh];
    _dataArray = [[NSMutableArray alloc] init];
    [self loadTemplate];
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
    [self loadTemplate];
}

- (void) loadTemplate
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX,GFKDAPI_LAUNCH]
      parameters:@{@"token":[Config getToken],
                   @"code":@"timePhotoAlbum"}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             [_dataArray removeAllObjects];
             NSArray *array = responseObject[@"result"];
             for (int i=0; i<array.count; i++) {
                 GFKDAd *ad = [[GFKDAd alloc] initWithDict:array[i]];
                 [_dataArray addObject:ad];
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
    _flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _flowLayout.colCount = 3;
    _flowLayout.degelate = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout: _flowLayout];
    //注册显示的cell的类型
    
    UINib *cellNib=[UINib nibWithNibName:@"TemplateViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    
    [_collectionView setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height)];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    //_collectionView.backgroundColor=RGBA(200, 200, 200, 0.25);
    _collectionView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //重用cell
    TemplateViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.model=_dataArray[indexPath.item];
    
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"你点击了 %ld--%ld",(long)indexPath.section,indexPath.item);

}


#pragma mark ZWwaterFlowDelegate
- (CGFloat)ZWwaterFlow:(ZWCollectionViewFlowLayout *)waterFlow heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPach
{
   // return 150;//200*KWidth_Scale;
  //  return (kNBR_SCREEN_W - 60)/2.0+40;
    return (kNBR_SCREEN_W - 80)/3.0+40;
}

@end
