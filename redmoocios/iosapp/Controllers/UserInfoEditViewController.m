//
//  UserInfoEditViewController.m
//  NeighborsApp
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 luwutech. All rights reserved.
//

#import "UserInfoEditViewController.h"
#import "OSCAPI.h"
#import "IQKeyboardManager.h"
#import <MBProgressHUD.h>
#import "Config.h"
#import "Utils.h"

@interface UserInfoEditViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    USERINFO_EDIT_MODE viewControllerMode;
    NSString *userInfoText;
    NSString *userInfoName;
    UITextField *TextFiled;
    BOOL _wasKeyboardManagerEnabled;
}

@end

@implementation UserInfoEditViewController

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
//    [[IQKeyboardManager sharedManager] setEnable:NO];
//}
//
//-(void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
//}

- (id) initWithMode : (USERINFO_EDIT_MODE) _mode Text: (NSString*) _text
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
    {
        viewControllerMode = _mode;
        userInfoText = _text;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    switch (viewControllerMode) {
        case USERINFO_EDIT_MODE_NICKNAME:
        {
            self.title = @"昵称修改";
            userInfoName = @"nickname";
        }
            break;
        case USERINFO_EDIT_MODE_PHONE:
        {
            self.title = @"手机号修改";
            userInfoName = @"birthday";
        }
            break;
        case USERINFO_EDIT_MODE_REALNAME:
        {
            self.title = @"真实姓名修改";
            userInfoName = @"realName";
        }
            break;
        case USERINFO_EDIT_MODE_BANKCARD:
        {
            self.title = @"工商银行储蓄卡卡号";
            userInfoName = @"bankCard";
        }
            break;
        default:
            break;
    }
    UITableView *boundTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H) style:UITableViewStyleGrouped];
    boundTabelView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, boundTabelView.bounds.size.width, 0.01f)];
    boundTabelView.delegate = self;
    boundTabelView.dataSource = self;
    [self.view addSubview:boundTabelView];

    //右上角的发布按钮
    UIBarButtonItem *rightAddItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:
                                     UIBarButtonItemStylePlain target:self action:@selector(rightBarbuttonAction:)];
    [rightAddItem setTitleTextAttributes:@{
                                           NSForegroundColorAttributeName  : UIColorFromRGB(0xFFFFFF),
                                           NSFontAttributeName             : [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:16.0f],
                                           }
                                forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightAddItem;
    
}

- (void) rightBarbuttonAction : (id) sender
{
    if (viewControllerMode == USERINFO_EDIT_MODE_BANKCARD){
        if (!([Utils checkCardNo:TextFiled.text] && [Utils checkGSWithBanknumber:TextFiled.text])) {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.labelText = @"请输入正确的工商银行卡号！";
            [HUD hide:YES afterDelay:1];
            return ;
        }
    }
    [self.delegate showText:TextFiled.text withName:userInfoName];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];

    
    TextFiled = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, kNBR_SCREEN_W-20, 44)];
    TextFiled.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:16.0f];
    TextFiled.textAlignment = NSTextAlignmentLeft;
    TextFiled.text = userInfoText;
    TextFiled.clearButtonMode=UITextFieldViewModeNever;
    TextFiled.textColor = kNBR_ProjectColor_DeepBlack;
    if (viewControllerMode == USERINFO_EDIT_MODE_BANKCARD) {
        TextFiled.textContentType = UITextContentTypeCreditCardNumber;
        TextFiled.placeholder = @"*请勿填写信用卡和公务卡卡号";
    }else if (viewControllerMode == USERINFO_EDIT_MODE_PHONE){
        TextFiled.textContentType = UITextContentTypeTelephoneNumber;
    }else if (viewControllerMode == USERINFO_EDIT_MODE_NICKNAME){
        TextFiled.textContentType = UITextContentTypeNickname;
    }else{
        TextFiled.textContentType = UITextContentTypeName;
    }
    
    [cell.contentView addSubview:TextFiled];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
