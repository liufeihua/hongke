//
//  TakesViewController.m
//  iosapp
//
//  Created by redmooc on 16/6/15.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "TakesViewController.h"
#import "Config.h"
#import "GFKDTakes.h"
#import "TakeTableViewCell.h"
#import "XHImageViewer.h"
#import "TakeDetailsWithBottomBarViewController.h"
#import "AddTakeViewController.h"
#import "TimeAlbumTableViewCell.h"
#import "CYWebViewController.h"
#import <MBProgressHUD.h>
#import "UMSocial.h"

@interface TakesViewController ()<TakeTableViewCellDelegate,XHImageViewerDelegate,TakeDetailsWithBottomBarViewControllerDelegate,BMKLocationServiceDelegate,AddTakeViewControllerDelegate,UIActionSheetDelegate>
{
    NSIndexPath    *updateIndexPath;
    GFKDTakes      *now_take;
}
@end

@implementation TakesViewController

- (instancetype)initWithTakesListType:(TakesListType)type withInfoType:(TakesInfoType)infoType{
    self = [super init];
    _myTakesListType = type;
    _myTakesInfoType = infoType;
    
    if (self) {
        __weak TakesViewController *weakSelf = self;
        NSString *token = [Config getToken];
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@&type=%d&infoType=%d",GFKDAPI_HTTPS_PREFIX,GFKDAPI_PAGEREADILYTAKE,(unsigned long)page,GFKDAPI_PAGESIZE,token,type,infoType];
        };
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            responseObjectsCount < GFKD_PAGESIZE? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);//}
        };
       
        self.objClass = [GFKDTakes class];
        
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = [NSString stringWithFormat:@"TakesRefreshInterval-%d", type];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    locService = [[BMKLocationService alloc] init];
    locService.delegate = self;
    locService.desiredAccuracy = kCLLocationAccuracyBest;
    //启动LocationService
    [locService startUserLocationService];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_take_1"] style:UIBarButtonItemStylePlain target:self action:@selector(addTake)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)parseDICT:(NSDictionary *)dict
{
    [self setDict:dict];
    if ([dict[@"result"][@"msg_code"] integerValue] == 0) {
        return dict[@"result"][@"data"];
    }
    return NULL;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDTakes *entity = self.objects[indexPath.row];
    if (_myTakesInfoType == TakesInfoTypeTimeAlbum) {
        //时光相册显示不同
//        static NSString *CellIdentifier = @"TimeAlbumTableViewCell";
//        TimeAlbumTableViewCell *cell = (TimeAlbumTableViewCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
//        if(cell == nil)
//        {
//            cell = [[TimeAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        [cell setDateEntity:entity];
//        return cell;
        
        NSString *ID =  @"TimeAlbumTableViewCell";
        UINib *nib = [UINib nibWithNibName:ID bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:ID ];
        TimeAlbumTableViewCell *cell = (TimeAlbumTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
        [cell setDateEntity:entity];
        return cell;
    }else{
       
        TakeTableViewCell *cell = [[TakeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
        cell.delegate = self;
        cell.isDetailView = NO;
        [cell setLatitude:locService.userLocation.location.coordinate.latitude];
        [cell setLongitude:locService.userLocation.location.coordinate.longitude];
        [cell setDateEntity:entity];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_myTakesInfoType == TakesInfoTypeTimeAlbum) {
        return (kNBR_SCREEN_W-30)/2 + 90;
    }else{
       GFKDTakes *entity = self.objects[indexPath.row];
       return [TakeTableViewCell heightWithEntity:entity isDetail:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    updateIndexPath = indexPath;
    GFKDTakes *entity = self.objects[indexPath.row];
    now_take = entity;
    if (_myTakesInfoType == TakesInfoTypeTimeAlbum) {
        NSInteger photoId = [entity.takeId integerValue];
        NSString *url = [NSString stringWithFormat:@"%@%@?token=%@&id=%ld",GFKDAPI_HTTPS_PREFIX, GFKDAPI_PHOTOVIEW,[Config getToken],photoId];
        CYWebViewController *webViewController = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
        webViewController.hidesBottomBarWhenPushed = YES;
        webViewController.navigationButtonsHidden = YES;
        webViewController.loadingBarTintColor = [UIColor redColor];
        webViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreOperateTake)];
        [self.navigationController pushViewController:webViewController animated:YES];
    }else{
        TakeDetailsWithBottomBarViewController *VC = [[TakeDetailsWithBottomBarViewController alloc] initWithModal:entity];
        VC.delegate = self;
        [self.navigationController pushViewController:VC animated:YES];
    }
}


- (void) moreOperateTake{
    if ([Config getOwnID] == [now_take.userId longLongValue]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享",@"删除", nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    }else{
       [self shareTake];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                //分享
                [self shareTake];
            }
                break;
            case 1:
            {
               //删除
                [self DeleteTake];
            }
                break;
            default:
                break;
        }
        return;
    }
}

-(void) DeleteTake{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_DELREADILYTAKE]
      parameters:@{@"token":[Config getToken],
                   @"id":now_take.takeId,
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             [self.navigationController popViewControllerAnimated:YES];
             [self refresh];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

- (void) shareTake{
    NSString *title = now_take.title;
    NSInteger photoId = [now_take.takeId integerValue];
//    NSString *URL = [NSString stringWithFormat:@"%@%@?token=%@&id=%ld",GFKDAPI_HTTPS_PREFIX, GFKDAPI_PHOTOVIEW,[Config getToken],photoId];
    NSString *URL = [NSString stringWithFormat:@"%@%@?id=%ld",GFKDAPI_HTTPS_PREFIX, GFKDAPI_PHOTOVIEW,photoId];
    
    // 微信相关设置
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = URL;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = URL;
    [UMSocialData defaultData].extConfig.title = title;
    
    // 手机QQ相关设置
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = title;
    [UMSocialData defaultData].extConfig.qqData.url = URL;
    
    // 新浪微博相关设置
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:URL];
    NSData * imageData;
    if (now_take.images.count>0) {
        imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:now_take.images[0]]];
    }
    // 复制链接
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5698bd72e0f55a6d460029b8"
                                      shareText:[NSString stringWithFormat:@"《%@》，分享来自 %@", title, URL]
                                     shareImage: [UIImage imageWithData:imageData]
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:nil];
}

- (void) takeTableViewCell : (TakeTableViewCell*) _cell tapSubImageViews : (UIImageView*) tapView allSubImageViews : (NSMutableArray *) _allSubImageviews
{
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    imageViewer.delegate = self;
    [imageViewer showWithImageViews:_allSubImageviews selectedView:tapView];
}


- (void)imageViewer:(XHImageViewer *)imageViewer  willDismissWithSelectedView:(UIImageView*)selectedView
{
    
    return ;
}




#pragma delegate TakeDetailsWithBottomBarViewController
-(void) GiveCommentCount:(int)_commentCount withZanCount:(int)_zanCount isDel:(bool)_isDel{
    if (updateIndexPath != nil) {
        GFKDTakes *take = self.objects[updateIndexPath.row];
        take.comments = [NSNumber numberWithInt:_commentCount];
        take.diggs = [NSNumber numberWithInt:_zanCount];;
        NSArray *indexArray=[NSArray arrayWithObject:updateIndexPath];
        [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationAutomatic];   // 更新一行数据
    }
    if (_isDel) {
        [self.objects removeObjectAtIndex:updateIndexPath.row];
        NSArray *indexArray=[NSArray arrayWithObject:updateIndexPath];
        [self.tableView deleteRowsAtIndexPaths: indexArray withRowAnimation:
         UITableViewRowAnimationFade];   //删除一行数据
    }
}

//非详情页  没有点赞图标
- (void) takeTableViewCellWithZanCount:(int)zanCount{
    //_zanCount = zanCount;
}


- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //    NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
}

- (void) addTake{
    //if (_myTakesInfoType == TakesInfoTypeTake)
    AddTakeViewController *VC = [[AddTakeViewController alloc] initWithInfoType:_myTakesInfoType];
    VC.hidesBottomBarWhenPushed = YES;
    VC.delegate = self;
    [self.navigationController pushViewController:VC animated:NO];
}

#pragma delegate AddTakeViewController
- (void) GiveisAdd:(bool)_isAdd{
    if (_isAdd) {
        [self refresh];
    }
}


@end
