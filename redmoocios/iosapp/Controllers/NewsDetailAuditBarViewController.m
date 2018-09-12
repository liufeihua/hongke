//
//  NewsDetailAuditBarViewController.m
//  iosapp
//
//  Created by redmooc on 16/5/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "NewsDetailAuditBarViewController.h"
#import "NewsDetailViewController.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "AuditLogViewController.h"
#import "SideMenuViewController.h"
#import "RESideMenu.h"

#import "PlayerDetailViewController.h"
#import "NewsImagesViewController.h"
#import "CYWebViewController.h"

@interface NewsDetailAuditBarViewController ()

//@property (nonatomic, strong) NewsDetailViewController *newsDetailsVC;
//@property (nonatomic, strong) PlayerDetailViewController *playerDetailsVC;
//@property (nonatomic, strong) NewsImagesViewController *imagesDetailVC;

@property (nonatomic, strong) UIViewController *detailVC;

@end

@implementation NewsDetailAuditBarViewController

- (instancetype)initWithNews:(GFKDNews*)news WithType:(int)type
{
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title     = @"内容详情";
        super.type = type;
        super.news = news;
        super.newsID = [news.articleId intValue];
        
        if (((NSNull *)news.detailUrl != [NSNull null]) && (![news.detailUrl isEqualToString:@""])) {
            NSString *newUrl = [Utils replaceWithUrl:news.detailUrl];
            _detailVC = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:newUrl]];
        }else if ([news.hasImages intValue] == 1) {
            _detailVC = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
            ((NewsImagesViewController *)_detailVC).newsID = [news.articleId intValue];
        }else if ([news.hasVideo intValue] == 1 || [news.hasAudio intValue] == 1 ) {
            _detailVC = [[PlayerDetailViewController alloc] initWithNewsID:[news.articleId intValue]];
        }else
        {
            _detailVC = [[NewsDetailViewController alloc] initWithNewsID:[news.articleId intValue]];
        }
    }
    
    return self;
}

- (instancetype)initWithNewsID:(int)newsID{
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title     = @"内容详情";
        super.newsID = newsID;
        _detailVC = [[NewsDetailViewController alloc] initWithNewsID:newsID];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLayout];
   // [self setBlockForButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewDidDisappear:(BOOL)animated
//{
//    if ([self.delegate respondsToSelector:@selector(UpdateIndex)]) {
//        [self.delegate UpdateIndex];
//    }
//}

- (void)setLayout
{
    [self.view addSubview:_detailVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"detailsView": _detailVC.view, @"editingBar": self.viewBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailsView]|" options:0 metrics:nil views:views]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}

//- (void)setBlockForButton
//{
//    __weak NewsDetailAuditBarViewController *weakSelf = self;
//    
//    /********* 审核通过或拒绝 **********/
//    self.chickAuditInfoPass = ^ {
//        [weakSelf AuditInfoIsToEnd];
//       // [weakSelf AuditInfoPassOrRefuse:1 withopinion:@""];
//        
//    };
//    self.chickAuditInfoRefuse = ^ {
//        //弹出框输入理由
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入" message:nil preferredStyle:UIAlertControllerStyleAlert];
//        //增加确定按钮；
//        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            //获取第1个输入框；
//            UITextField *opinionTextField = alertController.textFields.firstObject;
//            //NSLog(@"拒绝理由 = %@",opinionTextField.text);
//            [weakSelf AuditInfoPassOrRefuse:0 withopinion:opinionTextField.text];
//        }]];
//        //增加取消按钮；
//        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//        
//        //定义第一个输入框；
//        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//            textField.placeholder = @"请输入拒绝理由";
//        }];
//        [weakSelf presentViewController:alertController animated:true completion:nil];
//        
//    };
//    
//    self.chickAuditInfoShowProcess = ^ {
//        [weakSelf AuditInfoShowProcess];
//    };
//}
//
//- (void) AuditInfoPassOrRefuse:(int) status withopinion:(NSString*) opinion{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    
//    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_AUDITINFO]
//      parameters:@{@"token":[Config getToken],
//                   @"infoId":@(_newsID),
//                   @"status":@(status),
//                   @"opinion":opinion,
//                   }
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//             NSString *errorMessage = responseObject[@"reason"];
//             
//             if (errorCode == 1) {
//                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
//                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
//                 return;
//             }
//             SideMenuViewController *sideMenuVC =  (SideMenuViewController *)((RESideMenu *)(self.view.window.rootViewController)).leftMenuViewController;
//             sideMenuVC.AuditInfoBadge -- ;
//             [sideMenuVC reload];
//             
//             if ([self.delegate respondsToSelector:@selector(UpdateIndex)]) {
//                 [self.delegate UpdateIndex];
//             }
//             
//             [self.navigationController popViewControllerAnimated:YES];
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             MBProgressHUD *HUD = [Utils createHUD];
//             HUD.mode = MBProgressHUDModeCustomView;
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//             HUD.labelText = @"网络异常，操作失败";
//             
//             [HUD hide:YES afterDelay:1];
//         }
//     ];
//}
//
//- (void) AuditInfoShowProcess{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    
//    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_AUDITLOG]
//      parameters:@{@"token":[Config getToken],
//                   @"infoId":@(_newsID)
//                   }
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//             NSString *errorMessage = responseObject[@"reason"];
//             
//             if (errorCode == 1) {
//                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
//                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
//                 return;
//             }
//             AuditLogViewController *auditLogVC = [[AuditLogViewController alloc] init];
//             auditLogVC.boundDataSource = responseObject[@"result"];
//             [self.navigationController pushViewController:auditLogVC animated:YES];
//             
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             MBProgressHUD *HUD = [Utils createHUD];
//             HUD.mode = MBProgressHUDModeCustomView;
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//             HUD.labelText = @"网络异常，操作失败";
//             
//             [HUD hide:YES afterDelay:1];
//         }
//     ];
//}
//
////是否有终审权限
//- (void) AuditInfoIsToEnd{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    
//    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_ISTOEND]
//      parameters:@{@"token":[Config getToken],
//                   @"articleId":@(_newsID)
//                   }
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//             NSString *errorMessage = responseObject[@"reason"];
//             
//             if (errorCode == 1) {
//                 _isToEnd = 0;
//                 if ([self.infoLevel intValue] == 2) {
//                     
//                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"此文章为校外用户可见，确定要送审？" message:nil preferredStyle:UIAlertControllerStyleAlert];
//                     [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                         [self AuditInfoPassOrRefuse:1 withopinion:@""];
//                     }]];
//                     [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//                     [self presentViewController:alertController animated:true completion:nil];
//                 }else{
//                     [self AuditInfoPassOrRefuse:1 withopinion:@""];
//                 }
//             }
//             if (errorCode == 0) {
//                 _isToEnd = 1;
//                 NSString *title = ([self.infoLevel intValue] == 2)?@"[校外用户]请选择发稿或送审" :@"请选择发稿或送审" ;
//                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
//                 
//                 [alertController addAction:[UIAlertAction actionWithTitle:@"发稿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                     [self AuditInfoToEnd];
//                 }]];
//                 
//                 [alertController addAction:[UIAlertAction actionWithTitle:@"送审" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                     [self AuditInfoPassOrRefuse:1 withopinion:@""];
//                 }]];
//                 [self presentViewController:alertController animated:true completion:nil];
//                 
//             }
//             
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             MBProgressHUD *HUD = [Utils createHUD];
//             HUD.mode = MBProgressHUDModeCustomView;
//             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//             HUD.labelText = @"网络异常，操作失败";
//             
//             [HUD hide:YES afterDelay:1];
//         }
//     ];
//}
//
////发稿
//- (void) AuditInfoToEnd{
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
//    
//    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_TOEND]
//       parameters:@{@"token":[Config getToken],
//                    @"articleId":@(_newsID)
//                    }
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
//              NSString *errorMessage = responseObject[@"reason"];
//              
//              if (errorCode == 1) {
//                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
//                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
//                  return;
//              }
//              SideMenuViewController *sideMenuVC =  (SideMenuViewController *)((RESideMenu *)(self.view.window.rootViewController)).leftMenuViewController;
//              sideMenuVC.AuditInfoBadge -- ;
//              [sideMenuVC reload];
//              
//              if ([self.delegate respondsToSelector:@selector(UpdateIndex)]) {
//                  [self.delegate UpdateIndex];
//              }
//              
//              [self.navigationController popViewControllerAnimated:YES];
//              
//          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              MBProgressHUD *HUD = [Utils createHUD];
//              HUD.mode = MBProgressHUDModeCustomView;
//              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
//              HUD.labelText = @"网络异常，操作失败";
//              
//              [HUD hide:YES afterDelay:1];
//          }
//     ];
//}

@end
