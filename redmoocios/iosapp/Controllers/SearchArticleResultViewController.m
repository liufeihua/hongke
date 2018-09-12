//
//  SearchArticleResultViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/24.
//  Copyright © 2015年 oschina. All rights reserved.
//


#import "Config.h"
#import "NewsCell.h"


#import "SearchArticleViewController.h"
#import "SearchArticleResultViewController.h"

@implementation SearchArticleResultViewController


-(instancetype) initWithKeyWord : (NSString *) keyWord
{
    self = [super init];
    _keyword = keyWord;
    if (self) {
        [self searchList];
    }
    
    return self;
}

- (void) searchList {
    __weak SearchArticleResultViewController *weakSelf = self;
    NSString *token = [Config getToken];
    self.HttpType = objsHttpTypePOST;
    self.generateURL = ^NSString * (NSUInteger page) {
        return [NSString stringWithFormat:@"%@%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_SEARCH];
    };
    self.generateParameters = ^id (NSUInteger page){
        return @{
               @"pageNumber":@(page),
               @"token":token,
               @"pageSize":@(10),
               @"keyWord":weakSelf.keyword
                };
    };
    
    self.tableWillReload = ^(NSUInteger responseObjectsCount) {
        responseObjectsCount < GFKD_PAGESIZE? (weakSelf.lastCell.status = LastCellStatusFinished) :
        (weakSelf.lastCell.status = LastCellStatusMore);//}
    };
    
    self.objClass = [GFKDNews class];
    
    self.needAutoRefresh = NO;
    self.refreshInterval = 21600;
    self.kLastRefreshTime = [NSString stringWithFormat:@"NewsRefreshInterval-searchNews"];
}

- (NSArray *)parseDICT:(NSDictionary *)dict
{
    return dict[@"result"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastCell.emptyMessage = @"找不到和您的查询相符的信息";
}

#pragma mark - tableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDNews *news = self.objects[row];
    NSString *ID = [NewsCell idForRow:news];
    
    UINib *nib = [UINib nibWithNibName:ID bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:ID ];
    NewsCell *cell = (NewsCell *)[tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.NewsModel = news;
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDNews *news = self.objects[indexPath.row];
    return [NewsCell heightForRow:news];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GFKDNews *news = self.objects[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(pushViewController:)]) {
        [self.delegate pushViewController:news];
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
