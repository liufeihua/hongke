//
//  UpdatePwdViewController.m
//  NeighborsApp
//
//  Created by Martin.Ren on 15/5/11.
//  Copyright (c) 2015年 Martin.Ren. All rights reserved.
//

#import "UpdatePwdViewController.h"
#import "OSCAPI.h"
#import "IQKeyboardManager.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "Config.h"
#import "LoginViewController.h"

@interface UpdatePwdViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView         *boundTabelView;
    
    NSArray             *titlesArr;
    NSMutableArray      *textFiledArray;
}

@end

@implementation UpdatePwdViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    self.hidesBottomBarWhenPushed = YES;
    // Do any additional setup after loading the view.
    boundTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H) style:UITableViewStyleGrouped];
    boundTabelView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boundTabelView.bounds.size.width, 0.01f)];
    boundTabelView.delegate = self;
    boundTabelView.dataSource = self;
    [self.view addSubview:boundTabelView];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 60)];
    
    UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commitButton.frame = CGRectMake(15, 10, kNBR_SCREEN_W - 30, 40);
    commitButton.backgroundColor = kNBR_ProjectColor;
    commitButton.layer.cornerRadius = 5.0f;
    commitButton.layer.masksToBounds = YES;
    commitButton.titleLabel.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:16.0f];
    [commitButton setTitle:@"确认修改" forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(updatePwdRequest) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:commitButton];
    boundTabelView.tableFooterView = footView;
    
    
    titlesArr = @[
                  @"旧密码",
                  @"新密码",
                  @"确认密码",
                  ];
    
    textFiledArray = [[NSMutableArray alloc] init];

    for (NSString *subTitle in titlesArr)
    {
        UITextField *subTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, kNBR_SCREEN_W - 20, 40.0f)];
        subTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        //[self setDoneStyleTextFile:subTextFiled];
        subTextFiled.font = [UIFont systemFontOfSize:16.0f];
        subTextFiled.placeholder = [NSString stringWithFormat:@"请输入%@", subTitle];
        subTextFiled.textAlignment = NSTextAlignmentRight;
        subTextFiled.secureTextEntry = YES;
        
        [textFiledArray addObject:subTextFiled];
    }
}

- (void) updatePwdRequest
{
    for (int i = 0; i < titlesArr.count; i++)
    {
        if ( ((UITextField*)textFiledArray[i]).text.length <= 0 )
        {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.labelText = [NSString stringWithFormat:@"请输入%@", titlesArr[i]];
            [HUD hide:YES afterDelay:1];
            return ;
        }
    }

    if ( ![((UITextField*)textFiledArray[1]).text isEqualToString:((UITextField*)textFiledArray[2]).text] )
    {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.labelText = @"两次输入的密码不一致，请重新输入";
        [HUD hide:YES afterDelay:1];
        return ;
    }
    
    
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"正在修改密码";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_CHANGEPASSWORD];
    
    parameters = @{
                   @"token": [Config getToken],
                   @"password": ((UITextField*)textFiledArray[0]).text,
                   @"rawPassword":((UITextField*)textFiledArray[1]).text,
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
              
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
              HUD.labelText = @"密码修改成功";
              [HUD hide:YES afterDelay:1];
              UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
              LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
              [self.navigationController pushViewController:loginVC animated:YES];
              
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

//- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return .1f;
//}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titlesArr.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kNBR_SCREEN_W, 44.0f)];
    titleLable.text = titlesArr[indexPath.row];
    titleLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:16.0f];
    titleLable.textColor = kNBR_ProjectColor_DeepBlack;

    [cell.contentView addSubview:titleLable];
    [cell.contentView addSubview:textFiledArray[indexPath.row]];
    
    return cell;
}

@end
