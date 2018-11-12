//
//  SettingsPage.m
//  iosapp
//
//  Created by chenhaoxiang on 3/5/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "SettingsPage.h"
#import "Utils.h"
#import "Config.h"
#import "AboutPage.h"
#import "OSLicensePage.h"
#import "FeedbackPage.h"

#import <RESideMenu.h>
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <SDImageCache.h>

@interface SettingsPage () <UIAlertViewDelegate>

@end

@implementation SettingsPage

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor themeColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.tableView.separatorColor = [UIColor separatorColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 1;
        case 1: return 2;
    
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    NSArray *titles = @[
                        @[@"清除缓存"],
                        @[@"意见反馈", @"关于我们"],
                        ];
    cell.textLabel.text = titles[indexPath.section][indexPath.row];
    cell.backgroundColor = [UIColor cellsColor];
    cell.textLabel.textColor = [UIColor titleColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section, row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定要清除缓存的图片和文件？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];

        }
    } else if (section == 1) {
        if (row == 0) {
            [self.navigationController pushViewController:[FeedbackPage new] animated:YES];
        } else if (row == 1) {
            [self.navigationController pushViewController:[AboutPage new] animated:YES];
        }
    } 
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    } else {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[SDImageCache sharedImageCache] clearMemory];
       // [[SDImageCache sharedImageCache] clearDisk];
    }
}





@end
