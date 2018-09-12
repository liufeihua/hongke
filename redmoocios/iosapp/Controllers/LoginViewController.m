//
//  LoginViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 11/4/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "LoginViewController.h"
//#import "UserDetailsViewController.h"
#import "OSCAPI.h"
//#import "OSCUser.h"
#import "Utils.h"
#import "Config.h"
#import "OSCThread.h"
#import "UIImage+FontAwesome.h"
#import "AppDelegate.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "WXApi.h"

#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import <RESideMenu.h>
#import "IQKeyboardManager.h"

#import "GFKDUser.h"

#import "RSAEncryptor.h"
//#import "JKAlertDialog.h"


static NSString * const kShowAccountOperation = @"ShowAccountOperation";


@interface LoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *accountField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIView *textParent;
@property (weak, nonatomic) IBOutlet UIView *userParent;

@property (weak, nonatomic) IBOutlet UIButton *anonymousBtn;
- (IBAction)anonymousChick:(id)sender;
@property (nonatomic, strong) MBProgressHUD *hud;


@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpSubviews];
    
    [_textParent setBorderWidth:2 andColor:UIColorFromRGB(0x910F1B)];
    [_userParent setBorderWidth:2 andColor:UIColorFromRGB(0x910F1B)];
    _anonymousBtn.layer.borderColor = UIColorFromRGB(0x910F1B).CGColor;
    
    NSArray *accountAndPassword = [Config getOwnAccountAndPassword];
    _accountField.text = accountAndPassword? accountAndPassword[0] : @"";
    _passwordField.text = accountAndPassword? accountAndPassword[1] : @"";
    
    RACSignal *valid = [RACSignal combineLatest:@[_accountField.rac_textSignal, _passwordField.rac_textSignal]
                                         reduce:^(NSString *account, NSString *password) {
                                             return @(account.length > 0 && password.length > 0);
                                         }];
    RAC(_loginButton, enabled) = valid;
    RAC(_loginButton, alpha) = [valid map:^(NSNumber *b) {
        return b.boolValue ? @1: @0.4;
    }];
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.loginDelegate = self;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(method:)];
    _label_notes.userInteractionEnabled=YES;
    [_label_notes addGestureRecognizer:tapRecognizer];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:@"账号管理"];
    NSRange contentRange = {0, [content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    
    _label_notes.attributedText = content;
    
    NSMutableAttributedString *showStr = [[NSMutableAttributedString alloc] initWithString:@"1.请使用个人民网统一认证账号（即军网邮箱账号）登录，初始密码为个人身份证后六位（末尾X大写）;\n2.如您需要修改密码，请点击"];
    
    NSMutableAttributedString * str2 = [[NSMutableAttributedString alloc] initWithString:@"账号管理;"];
    [str2 addAttribute: NSLinkAttributeName value: @"http://user.nudt.edu.cn" range: NSMakeRange(0, str2.length)];
    
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:@"\n3.如果需要修改密码，请持证件到信息中心一、三号院服务大厅进行密码重置。\n4.投稿及内容举报，请拨打574882；账号问题咨询，请拨打573000；技术问题咨询，请拨打573008。"];
    
    //                  [showStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,showStr.length)];
    //                  [showStr addAttribute: NSLinkAttributeName value: @"http://id.nudt.edu.cn" range: NSMakeRange(0, showStr.length)];
    
    [showStr appendAttributedString: str2];
    [showStr appendAttributedString: str3];
    _label_shows.numberOfLines = 0;
    _label_shows.lineBreakMode = NSLineBreakByWordWrapping;
    _label_shows.attributedText = showStr;
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self.view setFrame:CGRectMake(0, 0,kNBR_SCREEN_W, kNBR_SCREEN_H+50)];
    __block CGFloat height = [_label_shows sizeThatFits:CGSizeMake(kNBR_SCREEN_W - 66, MAXFLOAT)].height + 20;
    [_img_shows setFrame:CGRectMake(_img_shows.frame.origin.x, _img_shows.frame.origin.y, _img_shows.frame.size.width, height )];
    
    [_content_view setFrame:CGRectMake(_content_view.frame.origin.x, _content_view.frame.origin.y, _content_view.frame.size.width, kNBR_SCREEN_H + 30)];
}

//实现点击方法，实现响应的函数

- (void)method:(UITapGestureRecognizer *)gesture
{
    NSString* path=[NSString stringWithFormat:@"http://user.nudt.edu.cn"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path]];
    
//    //3.展开、回缩的效果
//    //使用UIView的动画可以实现。touch事件里判断是否点到label，如果点到动画改变label的尺寸。
//    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^
//     {
//         label.frame = CGRectMake(<UILabel以当前字体显示全部时所需尺寸>);
//         label.lineBreakMode = UILineBreakModeClip;
//     } completion:^(BOOL finished) {}];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_hud hide:YES];
}



#pragma mark - about subviews

- (void)setUpSubviews
{
    _accountField.delegate = self;
    _passwordField.delegate = self;
    
    
//    [_accountField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [_passwordField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    
//    
//    //添加手势，点击屏幕其他区域关闭键盘的操作
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
//    gesture.numberOfTapsRequired = 1;
//    gesture.delegate = self;
//    [self.view addGestureRecognizer:gesture];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![_accountField isFirstResponder] && ![_passwordField isFirstResponder]) {
        return NO;
    }
    return YES;
}


#pragma mark - 键盘操作

//- (void)hidenKeyboard
//{
//    [_accountField resignFirstResponder];
//    [_passwordField resignFirstResponder];
//}
//
//- (void)returnOnKeyboard:(UITextField *)sender
//{
//    if (sender == _accountField) {
//        [_passwordField becomeFirstResponder];
//    } else if (sender == _passwordField) {
//        [self hidenKeyboard];
//        if (_loginButton.enabled) {
//            [self login];
//        }
//    }
//}
//
////开始编辑输入框的时候，软键盘出现，执行此事件
//-(void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    CGRect frame = _textParent.frame;
//    CGRect textFrame = textField.frame;
//    int offset = frame.origin.y+textFrame.origin.y + 32 - (self.view.frame.size.height - 216.0 - 50);//键盘高度216  多加50
//    
//    NSTimeInterval animationDuration = 0.30f;
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    
//    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
//    if(offset > 0)
//        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
//    
//    [UIView commitAnimations];
//}
//
////输入框编辑完成以后，将视图恢复到原始状态
//-(void)textFieldDidEndEditing:(UITextField *)textField
//{
//    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//}


- (IBAction)login
{
    _loginButton.enabled = NO;
    _hud = [Utils createHUD];
    _hud.labelText = @"正在登录";
    _hud.userInteractionEnabled = NO;
    
    //NSString *account;
    RSAEncryptor *rsa = [[RSAEncryptor alloc] init];
    
    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der"];
    [rsa loadPublicKeyFromFile:publicKeyPath];
    
    NSString *accountString = [rsa rsaEncryptString:_accountField.text];
    NSString *passwordString = [rsa rsaEncryptString:_passwordField.text];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSDictionary *dict = @{@"username": accountString, @"password" : passwordString};
    NSString *str = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_LOGIN_VALIDATE];
    
    [manager GET:str
       parameters:dict
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              _loginButton.enabled = YES;
              NSLog(@"login%@",responseObject);
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              if (errorCode == 1) {
                  NSString *errorMessage = responseObject[@"reason"];
                  
                  _hud.mode = MBProgressHUDModeCustomView;
                  _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                 _hud.detailsLabelText = [NSString stringWithFormat:@"错误：%@", errorMessage];
                 [_hud hide:YES afterDelay:2];
                  
                  return;
              }
              [Config saveOwnAccount:_accountField.text andPassword:_passwordField.text];
              NSDictionary *data = responseObject[@"result"][@"data"];
              NSString *token = responseObject[@"result"][@"token"];
              [Utils reNewUserWithDict:data token:token];
              
              //改善token给后台  方便连接APNS
              [self pushAPNS:token];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              _loginButton.enabled = YES;
              _hud.mode = MBProgressHUDModeCustomView;
              _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              _hud.labelText = [@(operation.response.statusCode) stringValue];
              _hud.detailsLabelText = error.userInfo[NSLocalizedDescriptionKey];
              
              [_hud hide:YES afterDelay:1];
          }
     ];
}


/*** 不知为何有时退出应用后，cookie不保存，所以这里手动保存cookie ***/

//- (void)saveCookies
//{
//    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject: cookiesData forKey: @"sessionCookies"];
//    [defaults synchronize];
//    
//}
//
//
///* add by lfh 2015-11-2 保存用户信息*/
//- (void) reNewUserWithDict:(NSDictionary *)dict token:(NSString *)token
//{
//    GFKDUser *user = [[GFKDUser alloc] initWithDict:dict];
//    [Config saveUser:user token:token];
//    [self saveCookies];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
//     [((AppDelegate*)[UIApplication sharedApplication].delegate) showMainViewController];
//}


- (void) pushAPNS:(NSString *)token
{
     NSDictionary *dict = @{@"siteId": @"1", @"token" : token,@"iostoken" :[Config getDeviceToken]};
     NSString *str = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_SEND_DEVICETOKEN];
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
     
     [manager GET:str parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
     NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
        if (errorCode == 1) {
            NSString *errorMessage = responseObject[@"reason"];
            NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
           [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
           return;
        }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
                  HUD.labelText = [@(operation.response.statusCode) stringValue];
                  HUD.detailsLabelText = error.userInfo[NSLocalizedDescriptionKey];
     
                  [HUD hide:YES afterDelay:1];
     }
     ];
}

- (IBAction)anonymousChick:(id)sender {
    _anonymousBtn.enabled = NO;
    _hud = [Utils createHUD];
    _hud.labelText = @"正在登录";
    _hud.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager POST:[NSString stringWithFormat:@"%@%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_GETANONYMOUSTOKEN]
       parameters:@{
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              _anonymousBtn.enabled = YES;
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  return;
              }
              NSDictionary *data = responseObject[@"result"][@"data"];
              NSString *token = responseObject[@"result"][@"token"];
              [Utils reNewUserWithDict:data token:token];
              //改善token给后台  方便连接APNS
              //[self pushAPNS:token];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              _anonymousBtn.enabled = YES;
              _hud.mode = MBProgressHUDModeCustomView;
              _hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              _hud.labelText = [@(operation.response.statusCode) stringValue];
              _hud.detailsLabelText = error.userInfo[NSLocalizedDescriptionKey];
              
              [_hud hide:YES afterDelay:1];
          }
     ];
    
}
@end
