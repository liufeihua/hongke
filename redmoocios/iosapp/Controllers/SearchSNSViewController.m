//
//  SearchSNSViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/23.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "SearchSNSViewController.h"
#import "AppDelegate.h"
#import "CommentCell.h"
#import "Config.h"
#import "UIColor+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import <MBProgressHUD.h>
#import "OSCAPI.h"
#import "Utils.h"
#import "GFKDSNSlog.h"
//#import "UserDetailsViewController.h"
#import "NewsDetailBarViewController.h"
#import "NewsViewController.h"

static NSString *kCommentCellID = @"CommentCell";

@interface SearchSNSViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;


@end


@implementation SearchSNSViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        __weak SearchSNSViewController *weakSelf = self;
        NSString *token = [Config getToken];
       
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_SNSLOG,(unsigned long)page,GFKDAPI_PAGESIZE,token];
            
            
        };
        
        self.tableWillReload = ^(NSUInteger responseObjectsCount) {
            
            responseObjectsCount < GFKD_PAGESIZE? (weakSelf.lastCell.status = LastCellStatusFinished) :
            (weakSelf.lastCell.status = LastCellStatusMore);//}
        };
        
        self.objClass = [GFKDSNSlog class];
        
        self.needAutoRefresh = YES;
        self.refreshInterval = 21600;
        self.kLastRefreshTime = [NSString stringWithFormat:@"NewsRefreshInterval-searchSNS"];
    }
    return self;
}

- (void) searchList {
    __weak SearchSNSViewController *weakSelf = self;
    NSString *token = [Config getToken];
    self.HttpType = objsHttpTypePOST;
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_SNSLOG];
    };
    self.generateParameters = ^id (NSUInteger page){
        return @{
            @"pageNumber":@(page),
            @"pageSize":@(10),
            @"token":token,
            @"name":weakSelf.searchBar.text
            };
    };
    self.tableWillReload = ^(NSUInteger responseObjectsCount) {
        
        responseObjectsCount < GFKD_PAGESIZE? (weakSelf.lastCell.status = LastCellStatusFinished) :
        (weakSelf.lastCell.status = LastCellStatusMore);//}
    };
    
    self.objClass = [GFKDSNSlog class];
    
    self.needAutoRefresh = NO;
    self.refreshInterval = 21600;
    self.kLastRefreshTime = [NSString stringWithFormat:@"NewsRefreshInterval-searchSNS"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar = [UISearchBar new];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"请输入关键字";
    ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = [Config getMode];
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        _searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
        _searchBar.barTintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    
    self.navigationItem.titleView = _searchBar;
   
    
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:kCommentCellID];
}

- (NSArray *)parseDICT:(NSDictionary *)dict
{
    return dict[@"result"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBar.text.length == 0) {return;}
    
    [searchBar resignFirstResponder];
    
    [self searchList];
  
    [self refresh];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - tableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    CommentCell *cell = [CommentCell new];
    GFKDSNSlog *SNSlog = self.objects[row];
    
//    [self setBlockForCommentCell:cell];
    //[cell setContentWithComment:comment];
    
    NSString *strType;
    switch ([SNSlog.type intValue]) {
        case 1:
            strType = @"评论了";
            break;
        case 2:
            strType = @"点赞了";
            break;
        case 3:
            strType = @"收藏了";
            break;
        case 4:
            strType = @"关注了用户";
            break;
        case 5:
            strType = @"关注栏目";
            break;
        case 6:
            strType = @""; //登录了
            break;
        default:
            strType = @"";
            break;
    }
    
    [cell.portrait loadPortrait:[NSURL URLWithString:SNSlog.icon]];
    cell.authorLabel.text = [NSString stringWithFormat:@"%@   %@",SNSlog.username,strType];
    cell.timeLabel.attributedText = [Utils attributedTimeStringFormStr:SNSlog.time];
   
    
    
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:SNSlog.title]];
    
    [cell.contentLabel setAttributedText:contentString];
    
    cell.contentLabel.textColor = [UIColor contentTextColor];
    cell.portrait.tag = row;
    cell.authorLabel.tag = row;
    [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDSNSlog *comment = self.objects[indexPath.row];
    
    if (comment.cellHeight) {return comment.cellHeight;}
    
    self.label.font = [UIFont boldSystemFontOfSize:14];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.title]];

    
    self.label.font = [UIFont boldSystemFontOfSize:15];
    [self.label setAttributedText:contentString];
    __block CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;

    
    comment.cellHeight = height + 61;
    
    return comment.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDSNSlog *SNSLog = self.objects[indexPath.row];
    if(([SNSLog.type intValue] ==1) || ([SNSLog.type intValue] ==2) || ([SNSLog.type intValue] ==3)){ //文章
        NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[SNSLog.fid intValue]];
        
        [self.navigationController pushViewController:newsDetailVC animated:YES];
    }else if ([SNSLog.type intValue] ==4) //用户
    {
//        UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:[SNSLog.fid intValue]];
//        [self.navigationController pushViewController:userDetailsVC animated:YES];
    }else if ([SNSLog.type intValue] ==5) //栏目
    {
        NewsViewController *VC = [[NewsViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[SNSLog.fid intValue] isSpecial:0];
        [self.navigationController pushViewController:VC animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - 跳转到用户详情页

- (void)pushDetailsView:(UITapGestureRecognizer *)tapGesture
{
//    GFKDSNSlog *SNSLog = self.objects[tapGesture.view.tag];
//    UserDetailsViewController *userDetailsVC = [[UserDetailsViewController alloc] initWithUserID:[SNSLog.userId intValue]];
//    [self.navigationController pushViewController:userDetailsVC animated:YES];
}


@end
