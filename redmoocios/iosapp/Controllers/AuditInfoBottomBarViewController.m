//
//  AuditInfoBottomBarViewController.m
//  iosapp
//
//  Created by redmooc on 16/5/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AuditInfoBottomBarViewController.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "Config.h"
#import "SideMenuViewController.h"
#import "RESideMenu.h"
#import <MBProgressHUD.h>
#import "AuditLogViewController.h"

@interface AuditInfoBottomBarViewController ()

@end

@implementation AuditInfoBottomBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor themeColor];
    
    _viewBar = [[UIView alloc]initWithFrame:CGRectMake(0, kNBR_SCREEN_H - 50, kNBR_SCREEN_W, 50)];
    [_viewBar setBorderWidth:1 andColor:kNBR_ProjectColor_LineLightGray];
    [self addBottomBar];
    
    if (_type != 3) {
        UIBarButtonItem *rightDelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_del"] style:UIBarButtonItemStylePlain target:self action:@selector(shouldDeleteArticle)];
        self.navigationItem.rightBarButtonItem = rightDelItem;
        
        _passBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _passBtn.tag = 1;
        _passBtn.frame = CGRectMake(15, 5, 29, 40);
        if (([_news.infoLevel intValue] == 2) || ([_news.infoLevel intValue] == 3)) { //校外
            [_passBtn setBackgroundImage:[UIImage imageNamed:@"tongguo_xw2"] forState:UIControlStateNormal];
        }else{
            [_passBtn setBackgroundImage:[UIImage imageNamed:@"tongguo"] forState:UIControlStateNormal];
        }
        [_passBtn addTarget:self action:@selector(chickAuditInfoPass:) forControlEvents:UIControlEventTouchUpInside];
        [_viewBar addSubview:_passBtn];
        
        _refuseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refuseBtn.tag = 0;
        _refuseBtn.frame = CGRectMake(kNBR_SCREEN_W - 55, 5, 29, 40);
        [_refuseBtn setBackgroundImage:[UIImage imageNamed:@"jujue"] forState:UIControlStateNormal];
        [_refuseBtn addTarget:self action:@selector(chickAuditInfoRefuse:) forControlEvents:UIControlEventTouchUpInside];
        [_viewBar addSubview:_refuseBtn];
    }
    
    _showProcessBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _showProcessBtn.frame = CGRectMake(70, 5, kNBR_SCREEN_W - 140, 40);
    _showProcessBtn.backgroundColor = kNBR_ProjectColor;
    _showProcessBtn.layer.cornerRadius = 15.0f;
    _showProcessBtn.layer.masksToBounds = YES;
    [_showProcessBtn setTitle:@"查看审核流程" forState:UIControlStateNormal];
    _showProcessBtn.titleLabel.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:15.0f];
    [_showProcessBtn addTarget:self action:@selector(showProcess:) forControlEvents:UIControlEventTouchUpInside];
    [_viewBar addSubview:_showProcessBtn];
}

- (void)addBottomBar
{
    _viewBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_viewBar];
    
    
    
    _editingBarYConstraint = [NSLayoutConstraint constraintWithItem:self.view    attribute:NSLayoutAttributeBottom   relatedBy:NSLayoutRelationEqual
                                                             toItem:_viewBar  attribute:NSLayoutAttributeBottom   multiplier:1.0 constant:0];
    
    _editingBarHeightConstraint = [NSLayoutConstraint constraintWithItem:_viewBar attribute:NSLayoutAttributeHeight         relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil         attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:50];
    
    [self.view addConstraint:_editingBarYConstraint];
    [self.view addConstraint:_editingBarHeightConstraint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)chickAuditInfoPass:(id)Sender{
//    if (_chickAuditInfoPass) {_chickAuditInfoPass();}
//}
//
//- (void)chickAuditInfoRefuse:(id)Sender{
//    if (_chickAuditInfoRefuse) {_chickAuditInfoRefuse();}
//}
//
//- (void)showProcess:(id)Sender{
//    if (_chickAuditInfoShowProcess) {_chickAuditInfoShowProcess();}
//}

- (void)shouldDeleteArticle{
    UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否删除该文章" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    logoutAlert.tag = 1;
    [logoutAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {return;}
    if(alertView.tag == 1){
        if (buttonIndex == 1)
        {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
            
            [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_DELARTICLE]
              parameters:@{@"token":[Config getToken],
                           @"id":@(self.newsID),
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
                     
                     if ([self.delegate respondsToSelector:@selector(UpdateIndex)]) {
                         [self.delegate UpdateIndex];
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
    }
}


- (void)chickAuditInfoPass:(id)Sender{
    [self AuditInfoIsToEnd];
}

- (void)chickAuditInfoRefuse:(id)Sender{
    //弹出框输入理由
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *opinionTextField = alertController.textFields.firstObject;
        //NSLog(@"拒绝理由 = %@",opinionTextField.text);
        [self AuditInfoPassOrRefuse:0 withopinion:opinionTextField.text];
    }]];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入拒绝理由";
    }];
    [self presentViewController:alertController animated:true completion:nil];
}
//
- (void)showProcess:(id)Sender{
    [self AuditInfoShowProcess];
}


- (void) AuditInfoPassOrRefuse:(int) status withopinion:(NSString*) opinion{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_AUDITINFO]
       parameters:@{@"token":[Config getToken],
                    @"infoId":@(_newsID),
                    @"status":@(status),
                    @"opinion":opinion,
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  return;
              }
              SideMenuViewController *sideMenuVC =  (SideMenuViewController *)((RESideMenu *)(self.view.window.rootViewController)).leftMenuViewController;
              sideMenuVC.AuditInfoBadge -- ;
              [sideMenuVC reload];
              
              if ([self.delegate respondsToSelector:@selector(UpdateIndex)]) {
                 [self.delegate UpdateIndex];
              }
              
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

- (void) AuditInfoShowProcess{
    _showProcessBtn.enabled = NO;
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"加载中";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_AUDITLOG]
      parameters:@{@"token":[Config getToken],
                   @"infoId":@(_newsID)
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             _showProcessBtn.enabled = YES;
             [HUD hide:YES afterDelay:0.1];
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             AuditLogViewController *auditLogVC = [[AuditLogViewController alloc] init];
             auditLogVC.boundDataSource = responseObject[@"result"];
             [self.navigationController pushViewController:auditLogVC animated:YES];
             
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             _showProcessBtn.enabled = YES;
             
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

//是否有终审权限
- (void) AuditInfoIsToEnd{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_ISTOEND]
      parameters:@{@"token":[Config getToken],
                   @"articleId":@(_newsID)
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             //NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {//没有终审权限
                 _isToEnd = 0;
                 if (([_news.infoLevel intValue] == 2) || ([_news.infoLevel intValue] == 3)) {
                     
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"此文章为校外用户可见，确定要通过吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
                     [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                         [self AuditInfoPassOrRefuse:1 withopinion:@""];
                     }]];
                     [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                     [self presentViewController:alertController animated:true completion:nil];
                 }else{
                     [self AuditInfoPassOrRefuse:1 withopinion:@""];
                 }
             }
             if (errorCode == 0) {//有终审权限
                 _isToEnd = 1;
                 NSString *title;
                 if ([_news.infoLevel intValue] == 1) {
                     title = @"发布后:校内可见";
                 }else if ([_news.infoLevel intValue] == 2) {
                     title = @"发布后:校外可见,不可分享";
                 }else if([_news.infoLevel intValue] == 3){
                     title = @"发布后:校外可见,可分享";;
                 }
//                 = (([_news.infoLevel intValue] == 2) || ([_news.infoLevel intValue] == 3))?@"[校外文章]请选择发稿或送审" :@"请选择发稿或送审" ;
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                 
                 [alertController addAction:[UIAlertAction actionWithTitle:@"发稿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     [self AuditInfoToEnd];
                 }]];
                 
                 [alertController addAction:[UIAlertAction actionWithTitle:@"送审" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                     [self AuditInfoPassOrRefuse:1 withopinion:@""];
                 }]];
                 
                 [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                 
                 //3.1修改title文字的显示样式
                 
                 NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc]initWithString:title];
                 
                 //                 [titleAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,5)];
                 
                 [titleAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20]range:NSMakeRange(0,[title length])];
                 
                 [alertController setValue:titleAttribute forKey:@"attributedTitle"];
                 
                 [self presentViewController:alertController animated:true completion:nil];
                 
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

//发稿
- (void) AuditInfoToEnd{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_TOEND]
       parameters:@{@"token":[Config getToken],
                    @"articleId":@(_newsID)
                    }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  return;
              }
              SideMenuViewController *sideMenuVC =  (SideMenuViewController *)((RESideMenu *)(self.view.window.rootViewController)).leftMenuViewController;
              sideMenuVC.AuditInfoBadge -- ;
              [sideMenuVC reload];
              
              //              if ([self.delegate respondsToSelector:@selector(UpdateIndex)]) {
              //                  [self.delegate UpdateIndex];
              //              }
              
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



@end
