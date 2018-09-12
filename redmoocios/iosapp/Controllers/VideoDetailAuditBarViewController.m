//
//  VideoDetailAuditBarViewController.m
//  iosapp
//
//  Created by redmooc on 16/5/18.
//  Copyright © 2016年 redmooc. All rights reserved.
//


#import "VideoDetailAuditBarViewController.h"

#import "PlayerDetailViewController.h"
#import "Config.h"
#import <MBProgressHUD.h>
#import "AuditLogViewController.h"

@interface VideoDetailAuditBarViewController ()

@property (nonatomic, strong) PlayerDetailViewController *detailViewController;

//@property (nonatomic, assign) int newsID;

@end

@implementation VideoDetailAuditBarViewController

- (instancetype)initWithNewsID:(int)newsID
{
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title     = @"内容详情";
        
        super.newsID = newsID;
        _detailViewController = [[PlayerDetailViewController alloc] initWithNewsID:newsID];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLayout];
    //[self setBlockForButton];
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
    [self.view addSubview:_detailViewController.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"detailsView": _detailViewController.view, @"editingBar": self.viewBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailsView]|" options:0 metrics:nil views:views]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}

//- (void)setBlockForButton
//{
//    __weak VideoDetailAuditBarViewController *weakSelf = self;
//    
//    /********* 审核通过或拒绝 **********/
//    self.chickAuditInfoPass = ^ {
//        [weakSelf AuditInfoPassOrRefuse:1 withopinion:@""];
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
//        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
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
//       parameters:@{@"token":[Config getToken],
//                    @"infoId":@(_newsID),
//                    @"status":@(status),
//                    @"opinion":opinion,
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

@end
