//
//  MyCenterViewController.m
//  iosapp
//
//  Created by redmooc on 16/9/7.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "MyCenterViewController.h"
#import "Config.h"
#import "OSCAPI.h"
#import "NTESCommonTableDelegate.h"
#import "NTESCommonTableData.h"
#import "OSCAPI.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import "GFKDPoints.h"
#import "UIView+TopTag.h"
#import "MyCommentsViewController.h"
#import "MyCollectsViewController.h"
#import "TakesViewController.h"
#import "UserInfoEditViewController.h"
#import "UpdatePwdViewController.h"
#import "ImageViewerController.h"
#import "FeedBackPage.h"
#import "AboutPage.h"
#import "PointsRuleViewController.h"
#import <SDImageCache.h>
#import "AppDelegate.h"
#import "WebHtmlViewController.h"
#import "CYWebViewController.h"
#import "RAYNewFunctionGuideVC.h"

@interface MyCenterViewController ()<UserInfoEditViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    int unreadCommentCount;
    GFKDPoints *points;
    UIView *tagView;
}

@property (nonatomic, strong) GFKDUser *myInfo;
@property (nonatomic, readonly, assign) int64_t myID;

@property (nonatomic,strong) NSArray *data;
@property (nonatomic,strong) NTESCommonTableDelegate *delegator;
@property (nonatomic, strong) UIImage *image;

@end

@implementation MyCenterViewController

- (instancetype)initWithMyInformation:(GFKDUser *)myInfo
{
    self = [super self];
    if (self) {
        _myInfo = myInfo;
        _myID = [Config getOwnID];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([_myInfo.userType intValue] < 10) {
        [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginViewController];
        return;
    }
    
    self.view_myComment.userInteractionEnabled = YES;
    UITapGestureRecognizer *commentGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myCommentView)];
    [self.view_myComment addGestureRecognizer:commentGesture];
    
    self.view_myTake.userInteractionEnabled = YES;
    UITapGestureRecognizer *takeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTakeView)];
    [self.view_myTake addGestureRecognizer:takeGesture];
    
    self.view_myStar.userInteractionEnabled = YES;
    UITapGestureRecognizer *starGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myStarView)];
    [self.view_myStar addGestureRecognizer:starGesture];
    
    __weak typeof(self) wself = self;
    self.delegator = [[NTESCommonTableDelegate alloc] initWithTableData:^NSArray *{
        return wself.data;
    }];
    
    self.tableView.delegate   = self.delegator;
    self.tableView.dataSource = self.delegator;
    self.tableView.scrollsToTop = NO;
    [self.view addSubview:self.tableView];
     
    [self buildData];
    [self getCommentUnRead];
    [self getPointsInfo];
    [self setupRefresh];
    
    [self makeFunctionGuide];
    
}

- (void) setupRefresh{
    self.tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header;
    });
}

- (void) loadData{
    _myInfo = [Config getMyInfo];
    [self getCommentUnRead];
    [self getPointsInfo];
}


- (void)refreshData{
    [self buildData];
    [self.tableView reloadData];
}

- (void)buildData{
    BOOL disableRemoteNotification = NO;
    if (IOS8) {
        disableRemoteNotification = [UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone;
    }else{
        disableRemoteNotification = [UIApplication sharedApplication].enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone;
    }
    NSArray *tableData;
    tableData = @[
                  @{
                      HeaderTitle:@"",
                      RowContent :@[
                              @{
                                  Title      :@"真实姓名",
                                  DetailTitle:_myInfo.realName,
                                  CellAction :@"onTouchRealName",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"工商银行储蓄卡卡号",
                                  DetailTitle:_myInfo.bankCard== nil?@"":_myInfo.bankCard,
                                  CellAction :@"onTouchUpdateBankCard",
                                  ShowAccessory : @(YES)
                                  },
                              ],
                      FooterTitle:@"*请用户完善真实姓名、工商银行储蓄卡卡号信息，以便红客稿酬的统计发放。"
                      },
                  @{
                      HeaderTitle:@"",
                      RowContent :@[
                              @{
                                  Title      :@"账号",
                                  DetailTitle:_myInfo.userName,
                                  ShowAccessory : @(NO)
                                  },
                              @{
                                  Title      : @"头像",
                                  ExtraInfo  : _myInfo.photo.length ? _myInfo.photo : [NSNull null],
                                  CellClass  : @"SettingPortraitCell",
                                  RowHeight  : @(80),
                                  CellAction : @"onTouchUpdatePhoto",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"昵称",
                                  DetailTitle:_myInfo.nickname,
                                  CellAction :@"onTouchNickName",
                                  ShowAccessory : @(YES)
                                  },
                              
                              @{
                                  Title      :@"性别",
                                  DetailTitle:[_myInfo.gender  isEqual: @""]?@"":_myInfo.gender,
                                  CellAction :@"onTouchUpdateGender",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"密码",
                                  DetailTitle: @"******",
                                  CellAction :@"onTouchUpdatePassword",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"积分",
                                  CellAction :@"onTouchPoints",
                                  DetailTitle:points==nil?@"":[NSString stringWithFormat:@"%.0f", [points.points floatValue]],
                                  ShowAccessory : @(NO)
                                  },
                              @{
                                  Title      :@"等级",
                                  CellAction :@"onTouchPoints",
                                  ExtraInfo  : points == nil?[NSNull null]:points,
                                  CellClass  : @"pointsRuleCell",
                                  ShowAccessory : @(NO)
                                  },
                              ],
                      FooterTitle:@""
                      },
                  @{
                      HeaderTitle:@"",
                      RowContent :@[
                              @{
                                  Title      :@"意见反馈",
                                  CellAction :@"onTouchFeedBack",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"清理缓存",
                                  DetailTitle:[self getCacheSize],
                                  CellAction :@"onTouchCache",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"积分规则",
                                  CellAction :@"onTouchPoints",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"扫码下载",
                                  CellAction :@"onTouchErWeiMa",
                                  ShowAccessory : @(YES)
                                  },
                              @{
                                  Title      :@"关于我们",
                                  CellAction :@"onTouchAboutMy",
                                  ShowAccessory : @(YES)
                                  },
                              ],
                      FooterTitle:@""
                      },
                  @{
                      HeaderTitle:@"",
                      RowContent :@[
                              @{
                                  Title      :@"注销登录",
                                  CellAction :@"onTouchLogout",
                                  ShowAccessory : @(YES)
                                  },
                              ],
                      FooterTitle:@""
                      },
                  ];
    
    self.data = [NTESCommonTableSection sectionsWithData:tableData];
}


- (void)onTouchUpdatePhoto{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择操作" message:nil delegate:self
                                              cancelButtonTitle:@"取消" otherButtonTitles:@"更换头像", @"查看大头像", nil];
    alertView.tag = 1;
    
    [alertView show];
}
- (void)onTouchNickName{
    UserInfoEditViewController *nVC = [[UserInfoEditViewController alloc] initWithMode:USERINFO_EDIT_MODE_NICKNAME Text:_myInfo.nickname];
    nVC.delegate = self;
    [nVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:nVC animated:YES];
}

- (void)onTouchRealName{
    UserInfoEditViewController *nVC = [[UserInfoEditViewController alloc] initWithMode:USERINFO_EDIT_MODE_REALNAME Text:_myInfo.realName];
    nVC.delegate = self;
    [nVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:nVC animated:YES];
}

- (void)onTouchUpdateBankCard{
    UserInfoEditViewController *nVC = [[UserInfoEditViewController alloc] initWithMode:USERINFO_EDIT_MODE_BANKCARD Text:_myInfo.bankCard];
    nVC.delegate = self;
    [nVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:nVC animated:YES];
}

- (void) showText:(NSString *)value withName:(NSString *)name{
    NSDictionary *parameters = @{
                   @"token": [Config getToken],
                   name: value,
                   };
    [self updateUserInfo:parameters];
}

- (void) updateUserInfo:(NSDictionary *)value{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_UPDATEUSER];
    
    parameters = value;
    
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
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
              HUD.labelText = @"用户信息保存成功";
              [HUD hide:YES afterDelay:2];
              
              NSDictionary *data = responseObject[@"result"];
              NSString *token = [Config getToken];
              GFKDUser *user = [[GFKDUser alloc] initWithDict:data];
              [Config saveUser:user token:token];
              
              _myInfo = [Config getMyInfo];
              [self refreshData];
              
              [self.navigationController popViewControllerAnimated:YES];
              
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
    [self refreshData];
}

- (void)onTouchUpdateGender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        switch (buttonIndex)
        {
            case 0:
            {
               _myInfo.gender = @"男";
                NSDictionary *parameters = @{
                                             @"token": [Config getToken],
                                             @"gender": @"M",
                                             };
                [self updateUserInfo:parameters];
            }
                break;
                
            case 1:
            {
                _myInfo.gender = @"女";
                NSDictionary *parameters = @{
                                             @"token": [Config getToken],
                                             @"gender": @"F",
                                             };
                [self updateUserInfo:parameters];
            }
                break;
                
            default:
                break;
        }
        return;
    }
}


- (void)onTouchPoints{
    PointsRuleViewController *VC = [[PointsRuleViewController alloc]  init];
    VC.title = @"积分规则";
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)onTouchErWeiMa{
    WebHtmlViewController *VC =  [[WebHtmlViewController alloc] initWithTitle:@"扫码下载" WithUrl:HTML_ERWEIMA];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)onTouchUpdatePassword{
    UpdatePwdViewController *nVC = [[UpdatePwdViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:nVC animated:YES];
}

- (void)onTouchFeedBack{
    FeedbackPage *feedback = [FeedbackPage new];
    feedback.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedback animated:YES];
}

- (void) onTouchCache{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    HUD.labelText = @"正在清理";
    [HUD showAnimated:YES whileExecutingBlock:^{
        [self clearCache];
    }];
    [self refreshData];
}
- (void) onTouchAboutMy{
    AboutPage *about = [AboutPage new];
    about.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:about animated:YES];
}

- (void)onTouchLogout{
    UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否确认注销当前登录帐号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    logoutAlert.tag = 3;
    [logoutAlert show];
    
}


- (void) myCommentView{
    if (unreadCommentCount > 0) {[self clearCommentUnRead];}
    MyCommentsViewController *myCommentsVC = [[MyCommentsViewController alloc] init];
    myCommentsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myCommentsVC animated:YES];
}

- (void) myTakeView{
    TakesViewController *VC = [[TakesViewController alloc] initWithTakesListType:TakesListTypeMy withInfoType:TakesInfoTypeTake];
    VC.title = @"我的随手拍";
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void) myStarView{
    MyCollectsViewController *VC = [[MyCollectsViewController alloc]  init];
    VC.title = @"我的收藏";
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
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
                  tagView = [UIView CreateTopTagNumberView:[NSString stringWithFormat:@"%d",unreadCommentCount]];
                  tagView.frame = CGRectMake(self.view_myComment.frame.size.width - 50, 40.0f / 2.0f - 15 / 2.0f, 15.0f, 15.0f);
                  [self.view_myComment addSubview:tagView];
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
              [tagView setHidden:YES];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
              
          }
     ];
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
              points = [[GFKDPoints alloc] initWithDict:responseObject[@"result"]];
              if (self.tableView.mj_header.isRefreshing) {
                  [self.tableView.mj_header endRefreshing];
              }
              [self refreshData];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
              
          }
     ];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {return;}
    
    if (alertView.tag == 1)
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        } else if (buttonIndex == 1){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择图片" message:nil delegate:self
                                                      cancelButtonTitle:@"取消" otherButtonTitles:@"相机", @"相册", nil];
            alertView.tag = 2;
            
            [alertView show];
            
        } else {
            
            NSString *str =  [Utils getMaxImageNameWithName:_myInfo.photo];;
            
            if (str.length == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"尚未设置头像" message:nil delegate:self
                                                          cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                [alertView show];
                return ;
            }
            
            ImageViewerController *imgViewweVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:str]];
            
            [self presentViewController:imgViewweVC animated:YES completion:nil];
        }
        
    } else if(alertView.tag == 3){
        //退出登录
        if (buttonIndex == 1)
        {
            //注销
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.labelText = @"正在注销";
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
            
            NSDictionary *dict = @{@"token": [Config getToken]};
            NSString *str = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_USER_CLEARTOKEN];
            
            [manager GET:str
              parameters:dict
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                     if (errorCode == 1) {
                         [HUD hide:YES];
                         NSString *errorMessage = responseObject[@"reason"];
                         NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                         [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                         return;
                     }
                     [Config reomveToken];
                     [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginViewController];
                     [HUD hide:YES afterDelay:1];
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                     HUD.labelText = @"网络异常，注销失败";
                     
                     [HUD hide:YES afterDelay:1];
                 }
             ];
            
        }
        
    }else  if (buttonIndex == 1) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Device has no camera"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            
            [alertView show];
        } else {
            UIImagePickerController *imagePickerController = [UIImagePickerController new];
            imagePickerController.delegate = self;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.allowsEditing = YES;
            imagePickerController.showsCameraControls = YES;
            imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
            
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        
        
    } else {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)updatePortrait
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"正在上传头像";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_USER_PHOTO] parameters:@{@"token":[Config getToken]}
           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
      if (_image) {
        [formData appendPartWithFileData:[Utils compressImage:_image] name:@"request" fileName:@"img.jpg" mimeType:@"image/jpeg"];
    }
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
    if (errorCode == 1) {
        [HUD hide:YES];
        NSString *errorMessage = responseObject[@"reason"];
        NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
        [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
        
        return;
    }
       //_portrait.image = _image;
       NSDictionary *data = responseObject[@"result"];
       NSString *token = [Config getToken];
    
       GFKDUser *user = [[GFKDUser alloc] initWithDict:data];
       [Config saveUser:user token:token];
       _myInfo = user;
         [self refreshData];
    
    [HUD hide:YES afterDelay:1];
    
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
    HUD.labelText = @"网络异常，头像更换失败";
    
    [HUD hide:YES afterDelay:1];
}];
}

#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self updatePortrait];
    }];
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
   // [[SDImageCache sharedImageCache] cleanDisk];
    [[SDImageCache sharedImageCache] clearMemory];
}


- (void)makeFunctionGuide{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *firstComeInTeacherDetail = @"isFirstEnterHere-3.9.8-2";
   // [user setBool:NO forKey:firstComeInTeacherDetail];
    
    if (![user boolForKey:firstComeInTeacherDetail]) {
        [user setBool:YES forKey:firstComeInTeacherDetail];
        [user synchronize];
        [self makeGuideView];
    }
}

- (void)makeGuideView{
    RAYNewFunctionGuideVC *vc = [[RAYNewFunctionGuideVC alloc]init];
    vc.titles = @[@"请完善真实姓名及工行卡号，方便红客稿酬发放"];
    
    CGRect frame = CGRectMake(10, 100 + 64, kNBR_SCREEN_W-20, 150);
    vc.frames = @[NSStringFromCGRect(frame),
                  ];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

@end
