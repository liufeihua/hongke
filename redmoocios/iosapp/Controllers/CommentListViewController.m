//
//  CommentListViewController.m
//  iosapp
//
//  Created by redmooc on 16/3/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "CommentListViewController.h"
#import "Config.h"
#import "GFKDMyComment.h"
#import "MyCommentCell.h"
#import "NewsDetailBarViewController.h"
#import "NewsViewController.h"
#import "NewsImagesViewController.h"
#import "TakeDetailsWithBottomBarViewController.h"

static NSString *kMyCommentCellID = @"MyCommentCell";

@interface CommentListViewController ()

@end

@implementation CommentListViewController


-(instancetype)initWithType:(int)type{
    
    self = [super init];
    
    if (self) {
        if (type == 0) {
            self.generateURL = ^NSString * (NSUInteger page) {
                return [NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_COMMENTPAGE,(long)page,GFKDAPI_PAGESIZE,[Config getToken]];
            };
        }else{
           self.generateURL = ^NSString * (NSUInteger page) {
            
              return [NSString stringWithFormat:@"%@%@?type=%d&pageNumber=%lu&%@&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_COMMENTLIST,type,(long)page,GFKDAPI_PAGESIZE,[Config getToken]];
            };
        }
        self.objClass = [GFKDMyComment class];
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
    
    //[self.tableView registerClass:[MyCommentCell class] forCellReuseIdentifier:kMyCommentCellID];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *nib = [UINib nibWithNibName:@"MyCommentCell" bundle:nil];
   [self.tableView registerNib:nib forCellReuseIdentifier:kMyCommentCellID ];
    self.lastCell.emptyMessage = @"暂无评论";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDMyComment *comment = self.objects[row];
    
    MyCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:kMyCommentCellID];
    
    if (!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"MyCommentCell" bundle:nil] forCellReuseIdentifier:kMyCommentCellID];
        cell = [tableView dequeueReusableCellWithIdentifier:kMyCommentCellID];
    }
    
//    UINib *nib = [UINib nibWithNibName:@"MyCommentCell" bundle:nil];
//    [tableView registerNib:nib forCellReuseIdentifier:kMyCommentCellID ];
//    MyCommentCell *cell = (MyCommentCell *)[tableView dequeueReusableCellWithIdentifier:kMyCommentCellID forIndexPath:indexPath];
    cell.myCommentModel = comment;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDMyComment *comment = self.objects[row];
    
    return [MyCommentCell heightForRow:comment];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    GFKDMyComment *comment = self.objects[row];
    //随手拍
    if (((NSNull *)comment.nodeCode != [NSNull null]) && [comment.nodeCode isEqualToString:@"readilyTake"]) {
        TakeDetailsWithBottomBarViewController *VC = [[TakeDetailsWithBottomBarViewController alloc] initWithTakeID:[comment.infoId intValue]];
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        if ([comment.hasImages intValue] == 1) {
            NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
            vc.newsID = [comment.infoId intValue];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            self.navigationController.navigationBarHidden = YES;
        }else if ([comment.hasVideo intValue] == 1) {
            VideoDetailBarViewController *newsDetailVC = [[VideoDetailBarViewController alloc] initWithNewsID:[comment.infoId intValue]];
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }else
        {
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[comment.infoId intValue]];
            [self.navigationController pushViewController:newsDetailVC animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


@end
