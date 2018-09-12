//
//  TakeDetailsViewController.m
//  iosapp
//
//  Created by redmooc on 16/6/16.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "TakeDetailsViewController.h"
#import "GFKDTakes.h"
#import <MBProgressHUD.h>
#import "TakeTableViewCell.h"
#import "XHImageViewer.h"
#import "Config.h"

@interface TakeDetailsViewController ()<TakeTableViewCellDelegate,XHImageViewerDelegate>


@property (nonatomic, strong) GFKDTakes *take;
@property (nonatomic, assign) int64_t takeID;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation TakeDetailsViewController

- (instancetype)initWithTakeID:(int64_t)takeID{
    self = [super initWithCommentType:CommentTypeTake andObjectID:takeID];
    
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _takeID = takeID;
        _take = nil;
        [self getTakeDetails];
    }
    
    return self;
}


- (instancetype)initWithModal:(GFKDTakes*)take{
     _takeID = [take.dataDict[@"id"] integerValue];
    self = [super initWithCommentType:CommentTypeTake andObjectID:_takeID];
    
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _take = take;
        _zanCount = [_take.diggs intValue];
        _commentCount = [_take.comments intValue];
    }
    
    return self;
}

- (void)viewDidLoad {
    self.needRefreshAnimation = NO;
    [super viewDidLoad];
    
}

- (void)getTakeDetails
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_GETREADILYTAKE]
       parameters:@{@"token":[Config getToken],
                    @"id":@(_takeID)
                    }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 0) {
                 _take = [[GFKDTakes alloc] initWithDict:responseObject[@"result"]];
                 _zanCount = [_take.diggs intValue];
                 _commentCount = [_take.comments intValue];
                 [self.tableView reloadData];
             } else {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[_HUD hide:YES];
    [super viewWillDisappear:animated];
}


#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_take == nil) {
        return 0;
    }else{
       return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0? 0 : 30;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return nil;
//    } else {
//        NSString *title;
//        if (self.allCount) {
//            title = [NSString stringWithFormat:@"%d 条评论", self.allCount];
//        } else {
//            title = @"没有评论";
//        }
//        return title;
//    }
//}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 30)];
        sectionHeaderView.backgroundColor = kNBR_ProjectColor_BackGroundGray;
        sectionHeaderView.layer.borderColor = kNBR_ProjectColor_LineLightGray.CGColor;
        sectionHeaderView.layer.borderWidth = 0.5f;
        
        UILabel *sectionHeaderLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kNBR_SCREEN_W - 30, 30)];
        sectionHeaderLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:14.0f];
        sectionHeaderLable.textColor = [UIColor tagColor];
        
        [sectionHeaderView addSubview:sectionHeaderLable];
        NSString *title;
        if (_commentCount) {
            title = [NSString stringWithFormat:@"%d条评论", _commentCount];
        } else {
            title = @"评论";
        }
        sectionHeaderLable.text = title;
        
        return sectionHeaderView;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_take == nil) {
            return 0.0;
        }else{
            return [TakeTableViewCell heightWithEntity:_take isDetail:YES];
        }
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        TakeTableViewCell *cell = [[TakeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
        cell.delegate = self;
        cell.isDetailView = YES;
        [cell setDateEntity:_take];
        [cell.avterImageView enableAvatarModeWithUserInfoDict:[_take.userId intValue] pushedView:self];
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section != 0;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return indexPath.section != 0;
}

- (void) takeTableViewCell : (TakeTableViewCell*) _cell tapSubImageViews : (UIImageView*) tapView allSubImageViews : (NSMutableArray *) _allSubImageviews
{
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    imageViewer.delegate = self;
    [imageViewer showWithImageViews:_allSubImageviews selectedView:tapView];
}

- (void)imageViewer:(XHImageViewer *)imageViewer  willDismissWithSelectedView:(UIImageView*)selectedView
{
    return ;
}

- (void) takeTableViewCellWithZanCount:(int)zanCount{
    _zanCount = zanCount;
}

@end
