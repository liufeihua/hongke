//
//  NewsDetailBarViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/5.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "NewsDetailBarViewController.h"
#import "NewsDetailViewController.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "Config.h"
#import "UIBarButtonItem+Badge.h"
#import "CommentsBottomBarViewController.h"
#import "UMSocial.h"
#import "UIView+TYAlertView.h"

#import "FontChooseView.h"

NSString * const kSliderSelect = @"sliderSelect";

@interface NewsDetailBarViewController ()<UIActionSheetDelegate,FXMarkSliderDelegate>

@property (nonatomic, strong) NewsDetailViewController *newsDetailsVC;
@property (nonatomic, assign) int newsID;
@property (nonatomic, assign) int64_t replyID;
@property (nonatomic, assign) int64_t replyUID;

@end

@implementation NewsDetailBarViewController

- (instancetype)initWithNewsID:(int)newsID
{
    self = [super initWithModeSwitchButton:YES];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title     = @"内容详情";
        
        _newsID = newsID;
        _newsDetailsVC = [[NewsDetailViewController alloc] initWithNewsID:newsID];
        _newsDetailsVC.bottomBarVC = self;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *fontScale = [userDefaults objectForKey:kSliderSelect] == nil?@"1":[userDefaults objectForKey:kSliderSelect];
        _newsDetailsVC.font_scale = [fontScale floatValue];
        
        [self setUpBlock];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setLayout];
    self.operationBar.items = [self.operationBar.items subarrayWithRange:NSMakeRange(0, 14)];
    [self.editingBar.modeSwitchButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self setBlockForOperationBar];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_font"] style:UIBarButtonItemStylePlain target:self action:@selector(showFont)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(GiveBrowersCount:)]) {
        [self.delegate GiveBrowersCount:[_newsDetailsVC.newsDetailObj.browsers intValue]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLayout
{
    [self.view addSubview:_newsDetailsVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"detailsView": _newsDetailsVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[detailsView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[detailsView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}


- (void)setBlockForOperationBar
{
    __weak NewsDetailBarViewController *weakSelf = self;
    
    /********* 收藏 **********/
    
    self.operationBar.toggleStar = ^ {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSString *API = weakSelf.isStarred? GFKDAPI_ARTICLE_RECOLLECT: GFKDAPI_ARTICLE_COLLECT;
        [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
           parameters:@{
                        @"token":   [Config getToken],
                        @"articleId": @(weakSelf.newsID)
                        }
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                 NSString *errorMessage = responseObject[@"reason"];
                 
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 0) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.labelText = weakSelf.isStarred? @"取消收藏成功": @"添加收藏成功";
                      weakSelf.isStarred = !weakSelf.isStarred;
                      weakSelf.operationBar.isStarred = weakSelf.isStarred;
                      [HUD hide:YES afterDelay:1];
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
    };
    
    /********* 点赞 **********/
    
    self.operationBar.zan = ^ {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        
        NSString *API = weakSelf.isZan? GFKDAPI_ARTICLE_REDIGG: GFKDAPI_ARTICLE_DIGG;
        [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
          parameters:@{
                       @"token":   [Config getToken],
                       @"articleId": @(weakSelf.newsID)
                       }
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
                 NSString *errorMessage = responseObject[@"reason"];
                 
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 
                 if (errorCode == 0) {
                     HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                     HUD.labelText = weakSelf.isZan? @"取消点赞成功": @"添加点赞成功";
                     weakSelf.zanNumButton.badgeValue = [NSString stringWithFormat:@"%d", weakSelf.isZan?--weakSelf.zanNum:++weakSelf.zanNum];
                     weakSelf.zanNumButton.badgePadding = 1;
                     weakSelf.zanNumButton.badgeBGColor = [UIColor colorWithHex:0xE25955];
                     weakSelf.isZan = !weakSelf.isZan;
                     weakSelf.operationBar.isZan = weakSelf.isZan;
                     [HUD hide:YES afterDelay:1];
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
    };
    /********** 显示回复 ***********/

    self.operationBar.showComments = ^ {
        CommentsBottomBarViewController *commentsBVC = [[CommentsBottomBarViewController alloc] initWithCommentType:0 andObjectID:weakSelf.newsID];
        [weakSelf.navigationController pushViewController:commentsBVC animated:YES];
    };
    
    /********** 分享 ***********/
    self.operationBar.share = ^ {
        NSString *title = weakSelf.newsDetailsVC.newsDetailObj.listTitle;
        NSString *URL;
        if ((NSNull *)weakSelf.newsDetailsVC.newsDetailObj.shareUrl != [NSNull null]) {
            URL = weakSelf.newsDetailsVC.newsDetailObj.shareUrl == nil?@"":weakSelf.newsDetailsVC.newsDetailObj.shareUrl;
        }else{
            URL = @"https://mapi.nudt.edu.cn";
        }
        
        // 微信相关设置
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
        [UMSocialData defaultData].extConfig.wechatSessionData.url = URL;
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = URL;
        [UMSocialData defaultData].extConfig.title = title;
        
        // 手机QQ相关设置
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        [UMSocialData defaultData].extConfig.qqData.title = title;
        [UMSocialData defaultData].extConfig.qqData.url = URL;
        
        // 新浪微博相关设置
        [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:URL];

        NSData * imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:weakSelf.newsDetailsVC.newsDetailObj.image]];
        // 复制链接
        [UMSocialSnsService presentSnsIconSheetView:weakSelf
                                             appKey:@"5698bd72e0f55a6d460029b8"
                                          shareText:[NSString stringWithFormat:@"《%@》，分享来自 %@", title, URL]
                                         shareImage: [UIImage imageWithData:imageData]
                                    shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                           delegate:nil];

    };
    
    
    
    _didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
        [weakSelf hideEmojiPageView];
    };
}

- (void)setUpBlock
{
    __weak NewsDetailBarViewController *weakSelf = self;
    
    _newsDetailsVC.didCommentSelected = ^(GFKDNewsComment *comment) {
        
        if (!weakSelf.operationBar.isHidden) {
            weakSelf.operationBar.hidden = YES;
            weakSelf.editingBar.hidden = NO;
        }
        
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
    
    _newsDetailsVC.didScroll = ^ {
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
             [_newsDetailsVC.tableView reloadData];
             
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

- (void)sendContent
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    
//    URL = [NSString stringWithFormat:@"%@%@?token=%@&articleId=%d&text=%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_SENDCOMMENT,[Config getToken],_newsID,[Utils convertRichTextToRawText:self.editingBar.editView]];
    
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_SENDCOMMENT];
    
    parameters = @{
                   @"articleId": @(_replyID==0?_newsID:_replyID),  //评论或者文章的主键
                   @"token": [Config getToken],
                   @"text": [Utils convertRichTextToRawText:self.editingBar.editView],
                   @"fId":@(_newsID), //文章主键
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
              _newsDetailsVC.page = 0;
              [_newsDetailsVC getCommentWithURL:[NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&articleId=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_COMMENT,_newsDetailsVC.page,GFKDAPI_PAGESIZE,_newsID,[Config getToken]]];
             //[_newsDetailsVC.tableView reloadData];
             
             // NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
             // [_newsDetailsVC.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
              
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}

- (void) showFont{
    //
    FontChooseView *settingModelView = [FontChooseView createViewFromNib];
    settingModelView.fontSlider.markPositions = @[@1,@2,@3,@4];
    settingModelView.fontSlider.minimumValue = 0;
    settingModelView.fontSlider.maximumValue = 4;
    settingModelView.fontSlider.delegate = self;
    settingModelView.fontSlider.currentValue = _newsDetailsVC.font_scale;
    
    
    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:settingModelView preferredStyle:TYAlertControllerStyleActionSheet];
    alertController.backgoundTapDismissEnable = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString: @"\n"]) {
        [self sendContent];
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(PlaceholderTextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = [textView hasText];
}

- (void)textViewDidChange:(PlaceholderTextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = [textView hasText];
}

- (void)FXSliderTapGestureValue:(CGFloat)selectValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(selectValue) forKey:kSliderSelect];
    [userDefaults synchronize];
    
    _newsDetailsVC.font_scale = selectValue;
    _newsDetailsVC.isLoadingFinished = NO;
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [_newsDetailsVC.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
