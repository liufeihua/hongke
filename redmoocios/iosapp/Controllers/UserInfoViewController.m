//
//  UserInfoViewController.m
//  iosapp
//
//  Created by redmooc on 16/3/23.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "UserInfoViewController.h"
#import <MBProgressHUD.h>
#import "Config.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "UserInfoEditViewController.h"
#import "UpdatePwdViewController.h"
#import "LoginViewController.h"
#import "ImageViewerController.h"

@interface UserInfoViewController ()<UITextFieldDelegate,UserInfoEditViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray     *nomalTitleArr;
    
    NSArray         *FiedArr;
    NSMutableArray     *nomalTextFiedArr;
    UITextField      *activeTextField ;
}

@property (nonatomic, strong) GFKDUser *myInfo;
@property (nonatomic, readonly, assign) int64_t myID;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) MBProgressHUD *HUD;
@end



@implementation UserInfoViewController

- (instancetype)initWithMyInformation:(GFKDUser *)myInfo
{
    self = [super self];
    if (self) {
        self = [self initWithStyle:UITableViewStyleGrouped];
        self.hidesBottomBarWhenPushed = YES;
        
        _myInfo = myInfo;
        _myID = [Config getOwnID];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.bounces = NO;
    self.navigationItem.title = @"个人信息";
    self.view.backgroundColor = [UIColor themeColor];
    
    self.tableView.tableFooterView = [UIView new];

    
    _portrait = [UIImageView new];
    _portrait.frame = CGRectMake(kNBR_SCREEN_W - 60, 80.0f / 2.0f - 50.0f / 2.0f, 50, 50);
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:25];
    [_portrait loadPortrait:[NSURL URLWithString:_myInfo.photo]];
    _portrait.userInteractionEnabled = YES;
    [_portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortrait)]];
   
    nomalTitleArr = @[
                      @[@"头像"],
                      @[@"姓名",@"账号",@"昵称",@"密码"],
                      ];
    
    FiedArr = @[
                @[@""],
                @[
                   _myInfo.realName ?: @"",
                   _myInfo.userName ?: @"",
                   _myInfo.nickname ?: @"",
                   @"******"],
                ];
    
    nomalTextFiedArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < nomalTitleArr.count; i++)
    {
        NSMutableArray *subArr = [[NSMutableArray alloc] init];
        
        for (int j = 0; j < ((NSArray*)nomalTitleArr[i]).count; j++)
        {
            UITextField *subTextFied;
            if ((j==0) || (j == 1)) {
                subTextFied = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, kNBR_SCREEN_W - 50, 44.0f)];
            }else
            {
                subTextFied = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, kNBR_SCREEN_W - 70, 44.0f)];
            }
            subTextFied.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            //[self setDoneStyleTextFile:subTextFied];
            subTextFied.font = [UIFont systemFontOfSize:14.0f];
            subTextFied.delegate = self;
            subTextFied.textColor = kNBR_ProjectColor_MidGray ;//UIColorFromRGB(0xBBBAC1);
            subTextFied.textAlignment = NSTextAlignmentRight;
            subTextFied.userInteractionEnabled = NO;
            subTextFied.text = FiedArr[i][j];
            
            [subArr addObject:subTextFied];
        }
        
        [nomalTextFiedArr addObject:subArr];
    }
    
    [self setLogoutTableViewFootView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return nomalTitleArr.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray*)nomalTitleArr[section]).count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        return 80.0f;
    }
    else
    {
        return 44.0f;
    }
    
    return 0.0f;
}



- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
    cell.layer.masksToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kNBR_SCREEN_W, 44.0f)];
    titleLable.text = nomalTitleArr[indexPath.section][indexPath.row];
    titleLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:14.0f];
    titleLable.textColor = kNBR_ProjectColor_DeepBlack;
    
    
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        titleLable.frame = CGRectMake(10, 0, kNBR_SCREEN_W, 80.0f);
        ((UITextField*)nomalTextFiedArr[0][0]).userInteractionEnabled = NO;
        [cell.contentView addSubview:_portrait];
    }
    
    [cell.contentView addSubview:titleLable];
    
    if ((indexPath.section == 1) && (indexPath.row != 0) && (indexPath.row != 1 )) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    

    [cell.contentView addSubview:nomalTextFiedArr[indexPath.section][indexPath.row]];
 
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        //[self editPortrait];
    }else if (indexPath.section == 1 && indexPath.row == 2) {
        UserInfoEditViewController *nVC = [[UserInfoEditViewController alloc] initWithMode:USERINFO_EDIT_MODE_NICKNAME Text:((UITextField*)nomalTextFiedArr[indexPath.section][indexPath.row]).text];
        nVC.delegate = self;
        [nVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:nVC animated:YES];
        
        activeTextField = (UITextField*)nomalTextFiedArr[indexPath.section][indexPath.row];
        
    }else if (indexPath.section == 1 && indexPath.row == 3) {
        UpdatePwdViewController *nVC = [[UpdatePwdViewController alloc] initWithNibName:nil bundle:nil];
        
        [self.navigationController pushViewController:nVC animated:YES];
        
    }
    
    
}

- (void) setLogoutTableViewFootView
{
    UIView *logoutFootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 100)];
    
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = CGRectMake(15, 10, kNBR_SCREEN_W - 30, 40);
    logoutButton.backgroundColor = kNBR_ProjectColor;
    logoutButton.layer.cornerRadius = 5.0f;
    logoutButton.layer.masksToBounds = YES;
    logoutButton.titleLabel.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:15.0f];
    [logoutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    [logoutFootView addSubview:logoutButton];
    [self.tableView setTableFooterView:logoutFootView];
}

- (void) logout
{
    UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否确认注销当前登录帐号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    logoutAlert.tag = 3;
    [logoutAlert show];
}

- (void)tapPortrait
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"选择操作" message:nil delegate:self
                                              cancelButtonTitle:@"取消" otherButtonTitles:@"更换头像", @"查看大头像", nil];
    alertView.tag = 1;
    
    [alertView show];
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
    _portrait.image = _image;
    NSDictionary *data = responseObject[@"result"];
    NSString *token = [Config getToken];
    
    GFKDUser *user = [[GFKDUser alloc] initWithDict:data];
    [Config saveUser:user token:token];
    _myInfo = user;
    if ([self.delegate respondsToSelector:@selector(update)]) {
        [self.delegate update];
    }
    
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

//这个方法在动画结束和视图隐藏之后调用  和clickedButtonAtIndex有区别
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3) {
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
                     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                     LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                     [self.navigationController pushViewController:loginVC animated:YES];
                     [HUD hide:YES afterDelay:1];
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                     HUD.labelText = @"网络异常，注销失败";
                     
                     [HUD hide:YES afterDelay:1];
                 }
             ];
            
        }
    }
}

- (void) showText:(NSString *)value
{
    [self updateUserInfo:value];
}

- (void) updateUserInfo:(NSString *)value{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_UPDATEUSER];
    
    parameters = @{
                   @"token": [Config getToken],
                   @"nickname": value,
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
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
              HUD.labelText = @"用户信息保存成功";
              [HUD hide:YES afterDelay:1];
              
              NSDictionary *data = responseObject[@"result"];
              NSString *token = [Config getToken];
              GFKDUser *user = [[GFKDUser alloc] initWithDict:data];
              [Config saveUser:user token:token];
              activeTextField.text = value;
              [self.navigationController popViewControllerAnimated:YES];
              
              if ([self.delegate respondsToSelector:@selector(update)]) {
                  [self.delegate update];
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


@end
