//
//  MyBasicInfoViewController.m
//  iosapp
//
//  Created by 李萍 on 15/2/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "MyBasicInfoViewController.h"

//#import "OSCUser.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
//#import "OSCMyInfo.h"
#import "Config.h"
#import "Utils.h"
//#import "HomepageViewController.h"
#import "ImageViewerController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

#import "GFKDUser.h"

#import "AppDelegate.h"


#import "UserInfoViewController.h"
#import "MyCommentsViewController.h"
#import "MyCollectsViewController.h"
#import "GFKDPoints.h"

#import "PointsRuleViewController.h"
#import "UIView+Frame.h"
#import "TakesViewController.h"
#import "AboutPage.h"
#import <SDImageCache.h>
#import "FeedbackPage.h"
#import "UIView+TopTag.h"

@interface MyBasicInfoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate,UITextFieldDelegate,UserInfoViewControllerDelegate>
{
    NSArray     *nomalTitleArr;
    
    NSArray         *FiedArr;
    NSMutableArray     *nomalTextFiedArr;
    UITextField      *activeTextField ;
    UserInfoViewController *nVcUserInfo ;
    int unreadCommentCount;
}

@property (nonatomic, strong) GFKDUser *myInfo;
@property (nonatomic, readonly, assign) int64_t myID;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *gradeLabel;
@property (nonatomic, strong) UILabel *pointsLabel;

@property (nonatomic, strong) UIImageView *space;
@property (nonatomic, strong) UIImageView *my_points;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation MyBasicInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myID = [Config getOwnID];
    }
    
    return self;
}

- (instancetype)initWithMyInformation:(GFKDUser *)myInfo
{
    self = [super self];
    if (self) {
        _myInfo = myInfo;
        _myID = [Config getOwnID];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
    self.navigationItem.title = @"我的";
    self.view.backgroundColor = [UIColor themeColor];
    self.tableView.tableFooterView = [UIView new];
    
    nomalTitleArr = @[
                      @[
                          @{@"Title" : @"我的评论",
                                       @"Icon"  : @"me03"},
                          @{@"Title" : @"我的收藏",
                                       @"Icon"  : @"me02"},
                          @{@"Title" : @"我的随手拍",
                            @"Icon"  : @"tabbar_compose_photo"},
                          @{@"Title" : @"我的跳蚤市场",
                            @"Icon"  : @"me01"},
                          @{@"Title" : @"积分等级",
                            @"Icon"  : @"jifendengji"},

                        ],
                      @[
                          @{@"Title" : @"清除缓存",
                            @"Icon"  : @"cache_icon"},
                          @{@"Title" : @"意见反馈",
                            @"Icon"  : @"meyijian"},
                          @{@"Title" : @"关于我们",
                            @"Icon"  : @"guanyuwomen_icon"},
                        ]
                     ];
    
    [self getPointsInfo];
    [self getCommentUnRead];
}


-(void) getCommentUnRead{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_COMMENTS_UNREAD];
    
    parameters = @{
                   @"token": [Config getToken],
                   };
    
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  
                  return;
                  
              }
              unreadCommentCount = [responseObject[@"result"] intValue];
              if (unreadCommentCount > 0) {
                  NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                  [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_HUD hide:YES];
}

-(void) clearCommentUnRead{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_COMMENTS_CLEAR];
    
    parameters = @{
                   @"token": [Config getToken],
                   };
    
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  
                  return;
                  
              }
              unreadCommentCount = 0;
              NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
              [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
              
          }
     ];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0){
    float contentW = kNBR_SCREEN_W;
    float contentH = 196.0f / 640.0f * contentW;
    float headH = contentH;

    UIImageView *header = [UIImageView new];
    header.frame = CGRectMake(0, 0, contentW, headH);
    header.clipsToBounds = YES;
    header.userInteractionEnabled = YES;
    header.contentMode = UIViewContentModeScaleAspectFill;
    header.image = [UIImage imageNamed:@"wode_bg"];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, header.image.size.width, header.image.size.height)];
    view.backgroundColor = [UIColor infosBackViewColor];
    [header addSubview:view];
    
    _portrait = [UIImageView new];
    _portrait.frame = CGRectMake(kNBR_SCREEN_W / 5.0f - 50.0f / 2.0f, contentH / 2.0f - 50.0f / 2.0f, 50, 50);
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:25];
    [_portrait loadPortrait:[NSURL URLWithString:_myInfo.photo]];
    _portrait.userInteractionEnabled = YES;
    //[_portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortrait)]];
    [header addSubview:_portrait];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_portrait.frame.origin.x + CGRectGetHeight(_portrait.frame) + 10,
                                                              contentH / 2.0f - 20,
                                                              kNBR_SCREEN_W - _portrait.frame.origin.x - CGRectGetHeight(_portrait.frame) - 10,
                                                              20)];
    _nameLabel.font = [UIFont boldSystemFontOfSize:18];
    _nameLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    _nameLabel.text = [_myInfo.nickname  isEqual: @""]?_myInfo.userName:_myInfo.nickname;
    [header addSubview:_nameLabel];
    
    UIImageView *userInfo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userInfo"]];
    userInfo.frame = CGRectMake(kNBR_SCREEN_W - 50 , contentH / 2.0f - 35.0f / 2.0f, 21, 35);
    userInfo.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *ViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoUserInfoViewController)];
    [userInfo addGestureRecognizer:ViewGesture];
    [header addSubview:userInfo];
    
    UIImageView *my_grade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_grade"]];
    my_grade.frame = CGRectMake(_portrait.frame.origin.x + CGRectGetHeight(_portrait.frame) + 10,
                                 contentH / 2.0f + 7,
                                 16,
                                 16);
    [header addSubview:my_grade];
    
    _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(my_grade.frame.origin.x + CGRectGetHeight(my_grade.frame) + 5,
                                                             contentH / 2.0f + 5,
                                                             kNBR_SCREEN_W - _portrait.frame.origin.x - CGRectGetHeight(_portrait.frame) - 10,
                                                             20)];
    _gradeLabel.font = [UIFont systemFontOfSize:12];
    _gradeLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    //_gradeLabel.text = @"学渣";//_myInfo.levelName;
    [header addSubview:_gradeLabel];
    
    _space = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"space"]];
    _space.frame = CGRectMake(_gradeLabel.frame.origin.x + CGRectGetHeight(_gradeLabel.frame) + 10,
                                contentH / 2.0f + 7,
                                16,
                                16);
    [header addSubview:_space];
    
    _my_points = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_points"]];
    _my_points.frame = CGRectMake(_gradeLabel.frame.origin.x + CGRectGetHeight(_gradeLabel.frame) + 30,
                                contentH / 2.0f + 9,
                                12,
                                12);
    [header addSubview:_my_points];
    
    _pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(_my_points.frame.origin.x + CGRectGetHeight(_my_points.frame) + 5,
                                                              contentH / 2.0f + 5,
                                                              kNBR_SCREEN_W - _portrait.frame.origin.x - CGRectGetHeight(_portrait.frame) - 10,
                                                              20)];
    _pointsLabel.font = [UIFont systemFontOfSize:12];
    _pointsLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    //_pointsLabel.text = @"1200";//_myInfo.levelName;
    [header addSubview:_pointsLabel];
    
    return header;
    }else{
        return nil;
    }

}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        float contentW = kNBR_SCREEN_W;
        float contentH = 196.0f / 640.0f * contentW;
        float headH = contentH;
        return headH;
    }
    else
    {
        return 10.0f;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return nomalTitleArr.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray*)nomalTitleArr[section]).count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSDictionary *cellDict = nomalTitleArr[indexPath.section][indexPath.row];
    
    UIImage *iconImg = [UIImage imageNamed:cellDict[@"Icon"]];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 40.0f / 2.0f - 24 / 2.0f, 24, 24)];
    iconImageView.image = iconImg;
    
    UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.frame.origin.x + iconImageView.frame.size.width + 10.0f, 0, kNBR_SCREEN_W - iconImageView.frame.size.width + 10 * 2, 40.0f)];
    titileLabel.text = cellDict[@"Title"];
    titileLabel.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:14.0f];
    titileLabel.textColor = kNBR_ProjectColor_DeepBlack;
    
    //[NSString stringWithFormat:@"%d",unreadCommentCount]
    if (indexPath.section == 0 && indexPath.row == 0 && unreadCommentCount!= 0) {
        UIView *tagView = [UIView CreateTopTagNumberView:[NSString stringWithFormat:@"%d",unreadCommentCount]];
        tagView.frame = CGRectMake(kNBR_SCREEN_W - 50, 40.0f / 2.0f - 15 / 2.0f, 15.0f, 15.0f);
        [cell.contentView addSubview:tagView];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSAttributedString *cacheSize =  [Utils attributedRecycle:[self getCacheSize]];
        
        UILabel *cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNBR_SCREEN_W- 165, 0, 150, 40.0f)];
        cacheLabel.textColor = [UIColor grayColor];
        cacheLabel.textAlignment = NSTextAlignmentRight;
        [cacheLabel setAttributedText:cacheSize];
        [cell.contentView addSubview:cacheLabel];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell.contentView addSubview:iconImageView];
    [cell.contentView addSubview:titileLabel];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        if (unreadCommentCount > 0) {[self clearCommentUnRead];}
        MyCommentsViewController *myCommentsVC = [[MyCommentsViewController alloc] init];
        myCommentsVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myCommentsVC animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
       MyCollectsViewController *VC = [[MyCollectsViewController alloc]  init];
       VC.title = @"我的收藏";
       VC.hidesBottomBarWhenPushed = YES;
       [self.navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        TakesViewController *VC = [[TakesViewController alloc] initWithTakesListType:TakesListTypeMy withInfoType:TakesInfoTypeTake];
        VC.title = @"我的随手拍";
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 3) {
        TakesViewController *VC = [[TakesViewController alloc] initWithTakesListType:TakesListTypeMy withInfoType:TakesInfoTypeMarket];
        VC.title = @"我的跳蚤市场";
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.section == 0 && indexPath.row == 4) {
        PointsRuleViewController *VC = [[PointsRuleViewController alloc]  init];
        VC.title = @"积分规则";
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self clearCache];
        [self getCacheSize];
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        FeedbackPage *feedback = [FeedbackPage new];
        feedback.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:feedback animated:YES];
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        AboutPage *about = [AboutPage new];
        about.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:about animated:YES];
    }
    
}



- (void) gotoUserInfoViewController
{
    nVcUserInfo = [[UserInfoViewController alloc] initWithMyInformation:_myInfo];
    nVcUserInfo.hidesBottomBarWhenPushed = YES;
    nVcUserInfo.delegate = self;
    [self.navigationController pushViewController:nVcUserInfo animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

//    if (nVcUserInfo.isUpdateUser) {
//        _portrait.imageURL = [NSURL URLWithString:[AppSessionMrg shareInstance].userEntity.avatar];
//        
//    }
}

/*
 *读取积分信息
 */
-(void)getPointsInfo{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_MYPOINTS];
    
    parameters = @{
                   @"token": [Config getToken],
                   };
    
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  return;
              }
              GFKDPoints *points = [[GFKDPoints alloc] initWithDict:responseObject[@"result"]];
              
              
              _gradeLabel.text = points.levelName;
              _pointsLabel.text = [NSString stringWithFormat:@"%.0f", [points.points floatValue]];
              NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
              float width = [points.levelName boundingRectWithSize:CGSizeMake(_gradeLabel.width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.width;
              
              _space.x = _gradeLabel.frame.origin.x + width + 5;
              _my_points.x = _gradeLabel.frame.origin.x + width + 25;
              _pointsLabel.x = _my_points.frame.origin.x + _my_points.height + 5;
   
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
              
          }
     ];
}

- (void) update{
    _myInfo = [Config getMyInfo];
    [_portrait loadPortrait:[NSURL URLWithString:_myInfo.photo]];
    _nameLabel.text = [_myInfo.nickname  isEqual: @""]?_myInfo.userName:_myInfo.nickname;
}


#pragma mark - 计算缓存大小
- (NSString *)getCacheSize
{
   //定义变量存储总的缓存大小
    long long sumSize = 0;
     //01.获取当前图片缓存路径
     NSString *cacheFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    //02.创建文件管理对象
    NSFileManager *filemanager = [NSFileManager defaultManager];
    //获取当前缓存路径下的所有子路径
    NSArray *subPaths = [filemanager subpathsOfDirectoryAtPath:cacheFilePath error:nil];
         //遍历所有子文件
    for (NSString *subPath in subPaths) {
            //1）.拼接完整路径
        NSString *filePath = [cacheFilePath stringByAppendingFormat:@"/%@",subPath];
             //2）.计算文件的大小
        long long fileSize = [[filemanager attributesOfItemAtPath:filePath error:nil]fileSize];
             //3）.加载到文件的大小
         sumSize += fileSize;
    }
    if (sumSize < 1000000) {
        return [NSString stringWithFormat:@"%.2f KB", sumSize/1024.0];
    }else{
       float size_m = sumSize/(1024.0*1024.0);
       return [NSString stringWithFormat:@"%.2f MB",size_m];
    }
    
}

- (void)clearCache{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *cacheFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    [fileManager removeItemAtPath:cacheFilePath error:nil];
    //[[SDImageCache sharedImageCache] cleanDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //NSFileManager *fileManager=[NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path]) {
//        NSArray *childerFiles=[fileManager subpathsAtPath:path];
//        for (NSString *fileName in childerFiles) {
//            //如有需要，加入条件，过滤掉不想删除的文件
//            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
//            [fileManager removeItemAtPath:absolutePath error:nil];
//        }
//    }
//    [[SDImageCache sharedImageCache] cleanDisk];
}


@end
