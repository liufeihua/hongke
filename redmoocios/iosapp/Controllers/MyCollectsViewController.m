//
//  MyCollectsViewController.m
//  iosapp
//
//  Created by redmooc on 16/3/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "MyCollectsViewController.h"
#import "Config.h"
#import "GFKDMyCollect.h"
#import "NewsDetailBarViewController.h"
#import "NewsImagesViewController.h"
#import "VideoDetailBarViewController.h"
#import "TakeDetailsWithBottomBarViewController.h"


static NSString* kMyCollectCellID = @"myCollectCell";

@interface MyCollectsViewController ()

@end

@implementation MyCollectsViewController

-(instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        self.generateURL = ^NSString * (NSUInteger page) {
            
            return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_COLLECTLIST,(long)page,@"pageSize=15",[Config getToken]];
        };
        self.objClass = [GFKDMyCollect class];
        self.needAutoRefresh = NO;
    }
    
    return self;
}

- (NSArray *)parseDICT:(NSDictionary *)dict
{
    return dict[@"result"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.lastCell.emptyMessage = @"暂无收藏";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMyCollectCellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDMyCollect *collect = self.objects[row];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMyCollectCellID forIndexPath:indexPath];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: kMyCollectCellID];// 2
//    }
    
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //改为以下的方法
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath]; //根据indexPath准确地取出一行，而不是从cell重用队列中取出
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

    //UILabel *title = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, kNBR_SCREEN_W-20, 40)];
    title.font = [UIFont systemFontOfSize:14];
    title.numberOfLines = 1;
    title.textColor = kNBR_ProjectColor_DeepBlack;
    title.text = collect.title;
    [cell.contentView addSubview:title];
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDMyCollect *collect = self.objects[row];
    
    if (((NSNull *)collect.nodeCode != [NSNull null]) && [collect.nodeCode isEqualToString:@"readilyTake"]) {
        TakeDetailsWithBottomBarViewController *VC = [[TakeDetailsWithBottomBarViewController alloc] initWithTakeID:[collect.articleId intValue]];
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        if ([collect.hasImages intValue] == 1) {
            NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
            vc.newsID = [collect.articleId intValue];
            vc.hidesBottomBarWhenPushed = YES;
            vc.parentVC = self;
            [self presentViewController:vc animated:YES completion:nil];
        }else if ([collect.hasVideo intValue] == 1) {
            VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[collect.articleId intValue]];
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }else
        {
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[collect.articleId intValue]];
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }
    }
    
//    NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[collect.articleId intValue]];
//    [self.navigationController pushViewController:newsDetailVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end
