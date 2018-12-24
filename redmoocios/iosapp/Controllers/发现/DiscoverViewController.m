//
//  DiscoverViewController.m
//  iosapp
//
//  Created by redmooc on 16/7/12.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "DiscoverViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "DiscoverReusableView.h"
#import "DiscoverCollectionViewCell.h"
#import "TakesViewController.h"
#import "NewsDetailBarViewController.h"
#import "NewsViewController.h"

#define SPACE 0
static NSString *cellIdentifier = @"discoverCollectionViewCell";
static NSString *discoverHead = @"discoverReusableViewhead";

@interface DiscoverViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong)NSMutableArray *serviceArray;

@end



@implementation DiscoverViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.serviceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:[UIColor themeColor]];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[DiscoverCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[DiscoverReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:discoverHead];
    
    [self getDiscoveItem];
    [self setupRefresh];
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
    [self getDiscoveItem];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getDiscoveItem
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_DISCOVER]
       parameters:@{@"token":[Config getToken],
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 0) {
                 _serviceArray = (NSMutableArray *)[Utils dictionaryWithJsonString:responseObject[@"result"]];
                  
                  if (_collectionView.mj_header.isRefreshing) {
                      [_collectionView.mj_header endRefreshing];
                  }
                  [self createCollectionView];
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

-(void)createCollectionView{
    [self.collectionView reloadData];
}


#pragma mark ----------------- collectionView(datasouce) ---------------------

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _serviceArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //
    NSDictionary *items = _serviceArray[section][@"items"];
    return items.count;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    DiscoverReusableView *reusableView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:discoverHead forIndexPath:indexPath];
        //reusableView.backgroundColor = [UIColor themeColor];
        reusableView.titleLabel.text = _serviceArray[indexPath.section][@"serviceName"];
    }
    return (UICollectionReusableView *)reusableView;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DiscoverCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    GFKDDiscover *grid = [[GFKDDiscover alloc] initWithDict:_serviceArray[indexPath.section][@"items"][indexPath.row]];
    [cell configCell:grid withIndexPath:indexPath];
    
    CGFloat sepSize = .5f;
    UIView *sep = [[UIView alloc] initWithFrame:CGRectZero];
    sep.frame = CGRectMake(0, cell.frame.size.height - sepSize, cell.frame.size.width ,sepSize);
    sep.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    sep.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:sep];
    
    UIView *sepLeft = [[UIView alloc] initWithFrame:CGRectZero];
    if ((indexPath.row + 1)%PerRowGridCount != 0){
        sepLeft.frame = CGRectMake(cell.frame.size.width - sepSize, 0, sepSize, cell.frame.size.height);
    }
    sepLeft.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:sepLeft];
    
    UIView *sepTop = [[UIView alloc] initWithFrame:CGRectZero];
    if (indexPath.row < PerRowGridCount){
        sepTop.frame = CGRectMake(0, 0, cell.frame.size.width, sepSize);
    }
    sepTop.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:sepTop];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GFKDDiscover *grid = [[GFKDDiscover alloc] initWithDict:_serviceArray[indexPath.section][@"items"][indexPath.row]];
    
    [Utils showLinkViewController:grid WithNowVC:self];
     //1、站内栏目 2、站内文章 3、站外文章 4、跳蚤市场 5、举报
}

#pragma mark ----------------- item(样式) ---------------------
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(GridWidth, GridHeight);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(SPACE, SPACE, SPACE, SPACE);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return SPACE;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return SPACE;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(kNBR_SCREEN_W, 40.0);
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return  CGSizeMake(kNBR_SCREEN_W, 0.0);
}

@end
