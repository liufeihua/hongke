//
//  TakeDetailsWithBottomBarViewController.m
//  iosapp
//
//  Created by redmooc on 16/6/16.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "TakeDetailsWithBottomBarViewController.h"
#import "TakeDetailsViewController.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "Config.h"
#import "FeedbackPage.h"

@interface TakeDetailsWithBottomBarViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) TakeDetailsViewController *takeDetailsVC;
@property (nonatomic, assign) int64_t objectID;
@property (nonatomic, strong) GFKDTakes *take;

@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) int64_t replyID;
@property (nonatomic, assign) int64_t replyUID;

@property (nonatomic, assign) BOOL isDel;

@end

@implementation TakeDetailsWithBottomBarViewController


- (instancetype)initWithTakeID:(int64_t)takeID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _objectID = takeID;
        _isDel = NO;
        
        _takeDetailsVC = [[TakeDetailsViewController alloc] initWithTakeID:takeID];
        [self addChildViewController:_takeDetailsVC];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void) moreOperate{
    if ([Config getOwnID] == [_take.userId longLongValue]){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
        actionSheet.tag = 2;
        [actionSheet showInView:self.view];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:nil, nil];
        actionSheet.tag = 1;
        [actionSheet showInView:self.view];
    
    }
}


- (instancetype)initWithModal:(GFKDTakes *)take{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _take = take;
        _objectID = [take.dataDict[@"id"] integerValue];
        _takeDetailsVC = [[TakeDetailsViewController alloc] initWithModal:take];
        [self addChildViewController:_takeDetailsVC];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void)setUpBlock
{
    __weak TakeDetailsWithBottomBarViewController *weakSelf = self;
    
    _takeDetailsVC.didCommentSelected = ^(GFKDNewsComment *comment) {
        if (weakSelf.replyID == [comment.commentId intValue]) {
            weakSelf.replyID = 0;
            weakSelf.replyUID = 0;
            [weakSelf.editingBar.editView setPlaceholder:@"说点什么"];
        } else {
            weakSelf.replyID = [comment.commentId intValue];
            weakSelf.replyUID = [comment.fid intValue];
            if ([Config getOwnID] == [comment.creatorid longLongValue]){//如果是自己的评论  可删除
                UIActionSheet *commentActionSheet = [[UIActionSheet alloc] initWithTitle:@"对该评论进行操作" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
                commentActionSheet.tag = 111;
                [commentActionSheet showInView:weakSelf.view];
            }else{
                weakSelf.editingBar.editView.placeholder = [NSString stringWithFormat:@"回复%@：", comment.creator];
               [weakSelf.editingBar.editView becomeFirstResponder];
            }
        }
    };
    
    _takeDetailsVC.didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
        [weakSelf hideEmojiPageView];
    };
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 111)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                [self deleteComment];
            }
                break;
                
            default:
                break;
        }
        return;
    }
    if (actionSheet.tag == 1)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                [self.navigationController pushViewController:[FeedbackPage new] animated:YES];
            }
                break;
                
            default:
                break;
        }
        return;
    }
    if (actionSheet.tag == 2)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                [self shouldDeleteTake];
            }
                break;
                
            default:
                break;
        }
        return;
    }
}


//删除自己发布的评论
-(void) deleteComment{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_DELETECOMMENT]
      parameters:@{@"token":[Config getToken],
                   @"id":@(_replyID),
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             [_takeDetailsVC.tableView setContentOffset:CGPointZero animated:NO];
             [_takeDetailsVC refresh];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
    
    self.title = @"详情";
    
//    if ([Config getOwnID] == [_take.userId longLongValue]){
//        UIBarButtonItem *rightDelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_del"] style:UIBarButtonItemStylePlain target:self action:@selector(shouldDeleteTake)];
//        self.navigationItem.rightBarButtonItem = rightDelItem;
//    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_more"] style:UIBarButtonItemStylePlain target:self action:@selector(moreOperate)];

}

//删除随手拍
-(void) shouldDeleteTake{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_DELREADILYTAKE]
      parameters:@{@"token":[Config getToken],
                   @"id":@(_objectID),
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             [self.navigationController popViewControllerAnimated:YES];
             _isDel = YES;
//             if ([self.delegate respondsToSelector:@selector(GiveCommentCount:withZanCount:isDel:)]) {
//                 [self.delegate GiveCommentCount:_takeDetailsVC.commentCount withZanCount:_takeDetailsVC.zanCount isDel:YES];
//             }
             
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
}

- (void)setLayout
{
    [self.view addSubview:_takeDetailsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"tableView": _takeDetailsVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[tableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}


- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_SENDCOMMENT];
    
    parameters = @{
                   @"articleId": @(_replyID==0?_objectID:_replyID),  //评论或者文章的主键
                   @"token": [Config getToken],
                   @"text": [Utils convertRichTextToRawText:self.editingBar.editView],
                   @"fId":@(_objectID), //文章主键
                   @"type":@(_replyID==0?1:2),  //1:对文章评论，2：对评论的评论
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
              
              self.editingBar.editView.text = @"";
              [self updateInputBarHeight];
              
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
              HUD.labelText = responseObject[@"reason"];//@"评论发表成功";
              [HUD hide:YES afterDelay:1];
              [_takeDetailsVC.tableView setContentOffset:CGPointZero animated:NO];
              [_takeDetailsVC refresh];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
          }
     ];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(GiveCommentCount:withZanCount:isDel:)]) {
        [self.delegate GiveCommentCount:_takeDetailsVC.commentCount withZanCount:_takeDetailsVC.zanCount isDel:_isDel];
    }
    
}


@end
