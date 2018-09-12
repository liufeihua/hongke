//
//  MessageCenterViewController.m
//  iosapp
//
//  Created by redmooc on 16/12/5.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "MessageCenterViewController.h"
#import "Config.h"
#import "GFKDMessage.h"
#import "MessageDetailTableViewController.h"
static  NSString *messageCell = @"messageCell";

@interface MessageCenterViewController ()

@end

@implementation MessageCenterViewController

-(instancetype)init{
    
    self = [super init];
    
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_MESSAGEPAGE,(long)page,GFKDAPI_PAGESIZE,[Config getToken]];
        };
        self.objClass = [GFKDMessage class];
        self.needAutoRefresh = NO;
    }
    
    return self;
}

- (NSArray *)parseDICT:(NSDictionary *)dict
{
    return dict[@"result"][@"data"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    UINib *nib = [UINib nibWithNibName:@"MyCommentCell" bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:kMyCommentCellID ];
    self.lastCell.emptyMessage = @"暂无消息";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDMessage *message = self.objects[row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCell];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 8.0f, kNBR_SCREEN_W-20.0f, 20.0f)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [titleLabel setTextColor:kNBR_ProjectColor_DeepGray];
    [titleLabel setText:message.title];
    [titleLabel setNumberOfLines:0];
    [cell addSubview:titleLabel];
    
    UILabel *timelabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y+titleLabel.frame.size.height+5.0f, kNBR_SCREEN_W-90, 20.0f)];
    [timelabel setBackgroundColor:[UIColor clearColor]];
    [timelabel setFont:[UIFont systemFontOfSize:16.0f]];
    [timelabel setTextColor:kNBR_ProjectColor_MidGray];
    [timelabel setText:message.createDate];
    [cell.contentView addSubview:timelabel];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDMessage *message = self.objects[row];
    MessageDetailTableViewController *detailVC = [[MessageDetailTableViewController alloc] initWitHMessage:message];
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
