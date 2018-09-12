//
//  CommentsBottomBarViewController.m
//  iosapp
//
//  Created by ChanAetern on 1/24/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "CommentsBottomBarViewController.h"
#import "CommentsViewController.h"
#import "GFKDNewsComment.h"
#import "Config.h"
#import <MBProgressHUD.h>

#import "OSCAPI.h"

@interface CommentsBottomBarViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) CommentsViewController *commentsVC;
@property (nonatomic, assign) int64_t objectID; //文章ID
@property (nonatomic, assign) int64_t replyID;
@property (nonatomic, assign) int64_t replyUID;
@property (nonatomic, assign) CommentType commentType;

@end

@implementation CommentsBottomBarViewController


- (instancetype)initWithCommentType:(CommentType)commentType andObjectID:(int64_t)objectID
{
    self = [super initWithModeSwitchButton:NO];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title     = @"评论";
        _objectID = objectID;
        _commentType = commentType;
        
        _commentsVC = [[CommentsViewController alloc] initWithCommentType:commentType andObjectID:objectID];
        [self addChildViewController:_commentsVC];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void)setUpBlock
{
        __weak CommentsBottomBarViewController *weakSelf = self;
    
    _commentsVC.didCommentSelected = ^(GFKDNewsComment *comment) {
//         [weakSelf.editingBar.editView setPlaceholder:@"说点什么"];
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
    
    _commentsVC.didScroll = ^ {
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
             [_commentsVC.tableView setContentOffset:CGPointZero animated:NO];
             [_commentsVC refresh];
             
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setLayout
{
    [self.view addSubview:_commentsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"tableView": _commentsVC.view, @"editingBar": self.editingBar};
    
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
              [_commentsVC.tableView setContentOffset:CGPointZero animated:NO];
              [_commentsVC refresh];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
          }
     ];
}





@end
