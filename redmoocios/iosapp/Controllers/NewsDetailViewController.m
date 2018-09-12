//
//  NewsDetailViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/4.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"

#import <MBProgressHUD.h>
#import "NewsDetailCell.h"
#import "GFKDNewsDetail.h"
#import "CommentCell.h"
#import "GFKDNewsComment.h"
#import "UIBarButtonItem+Badge.h"
#import "CommentsBottomBarViewController.h"
#import "ImageViewerController.h"
#import "AppDelegate.h"
#import "ReaderViewController.h"
#import "ReplyCommentCell.h"
#import "XHImageViewer.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FeedbackPage.h"
#import "LSYReadPageViewController.h"

#import "CYWebViewController.h"

#import "NoticeViewController.h"
#import "popTransition.h"


static NSString *kNewsCommentCellID = @"NewsCommentCell";

@interface NewsDetailViewController ()<UIWebViewDelegate,ReaderViewControllerDelegate,XHImageViewerDelegate,UINavigationControllerDelegate>

@property (nonatomic, readonly, assign) int   newsID;

@property (nonatomic, strong) MBProgressHUD *HUD;


@property(nonatomic,strong) NSMutableArray *htmlImgs;
@property(nonatomic,strong) NSMutableArray *currentSelectImageViews;

@property (strong,nonatomic) popTransition *popTransition;

@end

@implementation NewsDetailViewController

- (instancetype)initWithNewsID:(int)newsID
{
    self = [super init];

    if (self) {
        _page = 1;
         _newsID = newsID;
        _font_scale = 2;
        self.commmentOjbs = [NSMutableArray new];
    }
    
    return self;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationItem.title = @"内容详情";
    self.view.backgroundColor = [UIColor themeColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _htmlImgs = [[NSMutableArray alloc] init];
    _currentSelectImageViews = [[NSMutableArray alloc] init];
    
    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?articleId=%d&token=%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_DETAIL,_newsID,[Config getToken]]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
 
                 return;
                 
             }
            //NSLog(@"%@",responseObject[@"result"]);
              _newsDetailObj = [[GFKDNewsDetail alloc] initWithDict:responseObject[@"result"]];
             if (_bottomBarVC != nil) {
                 _bottomBarVC.isStarred = [_newsDetailObj.collected intValue] == 1?YES:NO;
                 _bottomBarVC.isZan = [_newsDetailObj.digged intValue] == 1?YES:NO;
                 _bottomBarVC.zanNum = [_newsDetailObj.diggs intValue];
             }
             
             NSString *footer = @"";
             if (((NSNull *)_newsDetailObj.footer != [NSNull null]) && _newsDetailObj.footer != nil) {
                 footer = _newsDetailObj.footer;
             }else{
                 footer = [NSString stringWithFormat: @"发布者:%@ 发布单位:%@",_newsDetailObj.creator,[_newsDetailObj.editionUnit isEqual: @""]?@"红客":_newsDetailObj.editionUnit];
             }
             NSString *header = @"";
             if (((NSNull *)_newsDetailObj.header != [NSNull null]) && _newsDetailObj.header != nil) {
                 header = _newsDetailObj.header;
             }else{
                 header = [NSString stringWithFormat: @"作者:%@ %@",_newsDetailObj.author,[_newsDetailObj.source isEqual:@""]?@"":[NSString stringWithFormat:@"来源:%@",_newsDetailObj.source]];
             }
            
//             [self.label_browers setAttributedText:[Utils attributedBrowersCount:[_newsDetailObj.browsers intValue] WithFontSize:14]];
//             [self.label_dates setAttributedText:[Utils attributedDateStr:_newsDetailObj.dates]];
             
             _HTML = [Utils HTMLWithData:@{
//                                           @"author": _newsDetailObj.author,
//                                           @"source": [_newsDetailObj.source isEqual:@""]?@"":[NSString stringWithFormat:@"来源:%@",_newsDetailObj.source],
                                           @"dateTime": [[Utils attributedDateStr:_newsDetailObj.dates] string],
                                           @"browsers": [[Utils attributedBrowersCount:[_newsDetailObj.browsers intValue] WithFontSize:14] string],
                                           @"title": _newsDetailObj.title,
                                           @"content": _newsDetailObj.content,
//                                           @"creator": _newsDetailObj.creator,
//                                           @"editionUnit": [_newsDetailObj.editionUnit isEqual: @""]?@"红客":_newsDetailObj.editionUnit,
                                           @"night": @([Config getMode]),
                                           @"fileName": [_newsDetailObj.file isEqual:@""] ?@"": _newsDetailObj.fileName,
                                           @"file": _newsDetailObj.file,
                                           @"fileLength": [_newsDetailObj.file isEqual:@""] ?@"": [self converFileSize:_newsDetailObj.fileLength],
                                           @"footer":footer,
                                           @"header":header,
                                           }
                           usingTemplate:@"news"];
             
             if (_bottomBarVC!=nil) {
                 _bottomBarVC.operationBar.isStarred = _bottomBarVC.isStarred;
                 _bottomBarVC.operationBar.isZan = _bottomBarVC.isZan;
                 _bottomBarVC.operationBar.zanNum = _bottomBarVC.zanNum;
                 
                 _bottomBarVC.zanNumButton = _bottomBarVC.operationBar.items[10];
                 _bottomBarVC.zanNumButton.shouldHideBadgeAtZero = YES;
                 _bottomBarVC.zanNumButton.badgeValue = [NSString stringWithFormat:@"%d", _bottomBarVC.zanNum];
                 _bottomBarVC.zanNumButton.badgePadding = 1;
                 _bottomBarVC.zanNumButton.badgeBGColor = [UIColor colorWithHex:0xE25955];//0xDE9223
                 
                 if ([_newsDetailObj.infoLevel intValue] == 3) {
                     _bottomBarVC.operationBar.items = [_bottomBarVC.operationBar.items subarrayWithRange:NSMakeRange(0, 14)];
                 }else{
                     _bottomBarVC.operationBar.items = [_bottomBarVC.operationBar.items subarrayWithRange:NSMakeRange(0, 12)];
                 }
                 UIBarButtonItem *browsersCountButton = _bottomBarVC.operationBar.items[4];
                 browsersCountButton.shouldHideBadgeAtZero = YES;
                 browsersCountButton.badgeValue = [NSString stringWithFormat:@"%@", _newsDetailObj.comments];
                 //browsersCountButton.badgeValue = [NSString stringWithFormat:@"%ld", _commmentOjbs.count];
                 browsersCountButton.badgePadding = 1;
                 browsersCountButton.badgeBGColor = [UIColor colorWithHex:0xE25955];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
    [self getCommentWithURL:[NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&articleId=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_COMMENT,_page,GFKDAPI_PAGESIZE,_newsID,[Config getToken]]];
    
    _lastCell = [[LastCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [_lastCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMoreCommentData)]];
    self.tableView.tableFooterView = _lastCell;
    _lastCell.emptyMessage = @"暂无评论";
    
    
    self.popTransition = [[popTransition alloc] init];
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.bottomBarVC.navigationController.delegate = self;
        [weakSelf.bottomBarVC.navigationController popViewControllerAnimated:YES];
    }];
    
    [(MJRefreshBackStateFooter *)self.tableView.mj_footer setTitle:@"上拉关闭当前页" forState:MJRefreshStateIdle];
    [(MJRefreshBackStateFooter *)self.tableView.mj_footer setTitle:@"释放关闭当前页" forState:MJRefreshStatePulling];
    [(MJRefreshBackStateFooter *)self.tableView.mj_footer setTitle:@"" forState:MJRefreshStateRefreshing];

//    self.bottomBarVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:(UIBarButtonItemStyleDone) target:self action:@selector(back)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //    但是如果按了返回键，不希望出现这种效果，那么还需要处理一下，在pop/push到新的界面的时候，代理置空
    self.bottomBarVC.navigationController.delegate = nil;
    
}
//-(void)back
//{
//    //    但是如果按了返回键，不希望出现这种效果，那么还需要处理一下，在pop/push到新的界面的时候，代理置空
//    self.bottomBarVC.navigationController.delegate = nil;
//    [self.bottomBarVC.navigationController popViewControllerAnimated:YES];
//}

-(nullable id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop) {
        return self.popTransition;
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_HUD hide:YES];
    
    [super viewWillDisappear:animated];
}


- (void) getCommentWithURL:(NSString *)allUrlstring{
    self.view.backgroundColor = [UIColor themeColor];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    [manager GET:allUrlstring
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
            
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             NSArray *objectsDICT = responseObject[@"result"];
            // [_commmentOjbs removeAllObjects];
             for (NSDictionary *objectDict in objectsDICT) {
                 GFKDNewsComment *obj = [[GFKDNewsComment alloc] initWithDict:objectDict];
                 [_commmentOjbs addObject:obj];
             }
             
//             UIBarButtonItem *browsersCountButton = _bottomBarVC.operationBar.items[4];
//             browsersCountButton.shouldHideBadgeAtZero = YES;
//             browsersCountButton.badgeValue = [NSString stringWithFormat:@"%d", _sumCommentsNum];
//             //browsersCountButton.badgeValue = [NSString stringWithFormat:@"%ld", _commmentOjbs.count];
//             browsersCountButton.badgePadding = 1;
//             browsersCountButton.badgeBGColor = [UIColor colorWithHex:0xE25955];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (_page == 1 && objectsDICT.count == 0) {
                     _lastCell.status = LastCellStatusEmpty;
                 } else if (objectsDICT.count == 0 || (_page == 1 && objectsDICT.count < GFKD_PAGESIZE)) {
                     _lastCell.status = LastCellStatusFinished;
                 } else {
                     _lastCell.status = LastCellStatusMore;
                 }
                 
                 NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
                 [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
             });
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}


- (void) loadMoreCommentData{
    if (!_lastCell.shouldResponseToTouch) {return;}
    
    _lastCell.status = LastCellStatusLoading;
   
    [self getCommentWithURL:[NSString stringWithFormat:@"%@%@?pageNumber=%lu&%@&articleId=%d&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_COMMENT,++_page,GFKDAPI_PAGESIZE,_newsID,[Config getToken]]];
}

- (void)fetchCommentList
{
    //添加评论区
    CommentsBottomBarViewController  *commentsBVC = [[CommentsBottomBarViewController alloc]initWithCommentType:0 andObjectID:_newsID];
    [self.bottomBarVC.navigationController pushViewController:commentsBVC animated:YES];
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.1f;
    }
    else
    {
        if (_bottomBarVC != nil) {
            return 30;
        }else{
            return 0.1f;
        }        
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [[UIView alloc] init];
    }
    else
    {
        if (_bottomBarVC != nil) {
            UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 30)];
            sectionHeaderView.backgroundColor = kNBR_ProjectColor_BackGroundGray;
            sectionHeaderView.layer.borderColor = kNBR_ProjectColor_LineLightGray.CGColor;
            sectionHeaderView.layer.borderWidth = 0.5f;
            
            if (section == 1)
            {
                UILabel *sectionHeaderLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kNBR_SCREEN_W - 30, 30)];
                sectionHeaderLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:14.0f];
                sectionHeaderLable.textColor = [UIColor tagColor];
                
                [sectionHeaderView addSubview:sectionHeaderLable];
                sectionHeaderLable.text = @"评论";
                
//                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kNBR_SCREEN_W - 100, 0, 85, 30)];
//                textLabel.textColor = [UIColor nameColor];
//                
//                textLabel.textAlignment = NSTextAlignmentRight;
//                textLabel.font = [UIFont boldSystemFontOfSize:14];
//                [sectionHeaderView addSubview:textLabel];
//                if (self.commmentOjbs.count > 0) {
//                    [sectionHeaderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchCommentList)]];
//                    textLabel.text = @"更多";
//                }else
//                {
//                    textLabel.text = @"暂无";
//                }
            }
            
            return sectionHeaderView;
        }else return nil;
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0)
    {
        return 0.1f;
    }
    else
    {
        //return 30;
        return 0.1f;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return _isLoadingFinished? _webViewHeight + 30 : 600;
    }else
    {
        if (self.commmentOjbs.count > 0)
        {
            GFKDNewsComment *comment = self.commmentOjbs[indexPath.row];
            
            if (comment.cellHeight) {return comment.cellHeight;}
            
            if ([comment.ftype  isEqual: @"Info"]) {
                NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.text]];
                
                UILabel *label = [UILabel new];
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.font = [UIFont boldSystemFontOfSize:15];
                [label setAttributedText:contentString];
                __block CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
                
                comment.cellHeight = height + 61;
            }else  if ([comment.ftype  isEqual: @"Comment"])
            {
                NSString * contStr = [NSString stringWithFormat:@"%@ 回复 %@: %@",comment.creator,comment.fromUser,comment.text];
                NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:contStr]];
                
                UILabel *label = [UILabel new];
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.font = [UIFont boldSystemFontOfSize:15];
                [label setAttributedText:contentString];
                __block CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 62, MAXFLOAT)].height;
                
                comment.cellHeight = height + 10;
            }
            
            
            return comment.cellHeight;        }
        else
        {
            return 40.0;
        }
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NewsDetailCell *cell = [NewsDetailCell new];
        cell.webView.delegate = self;
        if (_HTML != nil) {  //2016-11-18 当_HTML为空里，导致web高度得不到实际高度
            [cell.webView loadHTMLString:_HTML baseURL:[NSBundle mainBundle].resourceURL];
        }
        return cell;
    }else
    {
        if (self.commmentOjbs.count > 0)
        {
            NSInteger row = indexPath.row;
            GFKDNewsComment *comments = self.commmentOjbs[row];
            if ([comments.ftype  isEqual: @"Info"]) {
                CommentCell *cell = [CommentCell new];
                [self setBlockForCommentCell:cell];
                [cell setContentWithComment:comments];
                cell.contentLabel.textColor = [UIColor contentTextColor];
                cell.portrait.tag = row; cell.authorLabel.tag = row;
                [cell.portrait enableAvatarModeWithUserInfoDict:[comments.creatorid intValue] pushedView:self];
                cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
                return cell;
            }else  if ([comments.ftype  isEqual: @"Comment"]) {
                ReplyCommentCell *cell = [ReplyCommentCell new];
                
                [cell setContentWithComment:comments];
                //cell.contentLabel.textColor = [UIColor contentTextColor];
                cell.authorLabel.tag = row;
                //            [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushDetailsView:)]];
                
                cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
                return cell;
            }
            return nil;
        }else{
            return nil;
        }
        
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
       GFKDNewsComment *comment = self.commmentOjbs[indexPath.row];
    
       if (self.didCommentSelected) {
          self.didCommentSelected(comment);
       }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return 1;
        }
            break;
            
        case 1:
        {
            return self.commmentOjbs.count;
        }
            break;
            
        default:
        {
            return 0;
        }
            break;
    }
}


#pragma mark - JSExport Methods

- (void)showTitlebarWithStr:(NSString *)str
{
   [self.bottomBarVC.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)hideTitlebarWithStr:(NSString *)str
{
    [self.bottomBarVC.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)closeContentWithStr:(NSString *)str
{
    [self.bottomBarVC.navigationController popViewControllerAnimated:YES];
   // [self.bottomBarVC dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)getTokenWithStr:(NSString *)str
{
    return [Config getToken];
}

- (NSString *)getIMEIWithStr:(NSString *)str
{
    return [Utils getIMEI];
}

- (NSString *)getDeviceTypeWithStr:(NSString *)str
{
    return [Utils getDeviceString];
}

- (NSString *)getVerNameWithStr:(NSString *)str
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];;
}

- (void)showToastWithTitle:(NSString *)title withContent:(NSString *)content
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)openContentWithTitle:(NSString *)title withUrl:(NSString *)url withLinkType:(NSNumber *)linkType
{
    GFKDDiscover *grid = [[GFKDDiscover alloc] init];
    grid.name = title;
    grid.url = url;
    grid.linkType = linkType;
    grid.range = @(3);
    grid.enabled = @(1);
    
    [Utils showLinkViewController:grid WithNowVC:self.bottomBarVC];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (_isLoadingFinished) { //防止加载二次
        self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        // 打印异常
        self.context.exceptionHandler =
        ^(JSContext *context, JSValue *exceptionValue)
        {
            context.exception = exceptionValue;
            NSLog(@"%@", exceptionValue);
        };
        self.context[@"window"] = self;
        self.context[@"hkListner"] = self;   //window.hkListner 改为 window.hk
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *fontsize;
    if (_font_scale == 0) {
        fontsize = @"75%";
    }else if (_font_scale == 1) {
        fontsize = @"100%";
    }else if (_font_scale == 2) {
        fontsize = @"125%";
    }else if (_font_scale == 3) {
        fontsize = @"150%";
    }else if (_font_scale == 4) {
        fontsize = @"200%";
    }
    NSString *webStr = [NSString stringWithFormat: @"document.getElementsByTagName('main')[0].style.webkitTextSizeAdjust= '%@'",fontsize];
    [webView stringByEvaluatingJavaScriptFromString:webStr];

    if (_HTML == nil) {return;}
    if (_isLoadingFinished) {
        webView.hidden = NO;
        [_HUD hide:YES];
        return;
    }
    
    webView.allowsInlineMediaPlayback = YES;
    
    int length = [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img').length"] intValue];
    for (int i =0 ; i<length; i++) {
        NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('img')[%d].src",i];
        NSString *src = [webView stringByEvaluatingJavaScriptFromString:str];
        UIImageView *subImageView =[[UIImageView alloc] initWithFrame:CGRectMake(kNBR_SCREEN_W/2.0, kNBR_SCREEN_H/2.0, 0, 0)];
        [subImageView sd_setImageWithURL:[NSURL URLWithString:src] placeholderImage:[UIImage imageNamed:@"item_default"]];
        [_currentSelectImageViews addObject:subImageView];
        [_htmlImgs addObject:src];
    }
    
    _isLoadingFinished = YES;
    
    _webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    NSLog(@"_webViewHeight---%f",_webViewHeight);
    
    
    
 //   [_HUD hide:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //NSString *htm1 =[webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
//    return [request.URL.absoluteString isEqualToString:@"about:blank"];
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        
        
        UIImageView *subImageView = _currentSelectImageViews[0];
        for (int i=0; i<_htmlImgs.count; i++) {
            if ([imageUrl isEqualToString:_htmlImgs[i]]) {
                subImageView = _currentSelectImageViews[i];
                break ;
            }
        }
        //点击单个选择的图片，放大显示
        XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
        imageViewer.delegate = self;
        
        [imageViewer showWithImageViews:_currentSelectImageViews selectedView:subImageView];
        
        
//        AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
//        ImageViewerController *imageViewerVC;
//        if (_htmlImgs.count > 1) {
//            imageViewerVC = [[ImageViewerController alloc] initWithImageArray:[_htmlImgs copy] currentImage:imageUrl];
//        }else
//        {
//            imageViewerVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:imageUrl]];
//        }
//        
//        
//        [delegate.window.rootViewController presentViewController:imageViewerVC animated:YES completion:nil];
        
        
        
        return NO;
    }
    
    if ([requestString hasPrefix:@"myweb:fileShowClick:"]) {
        NSString *fileUrl = [requestString substringFromIndex:@"myweb:fileShowClick:".length];
        
        [self fileShowChick:fileUrl];
        
        
        return NO;
    }
    
    if ([requestString hasPrefix:@"myweb:ReportClick"]) {
        FeedbackPage *feedback = [FeedbackPage new];
        feedback.hidesBottomBarWhenPushed = YES;
        [self.bottomBarVC.navigationController pushViewController:feedback animated:YES];
        return NO;
    }
    
    //用稿通知单
    if ([requestString hasPrefix:@"myweb:NoticeClick"]) {
        NoticeViewController *noticeVC = [NoticeViewController new];
        noticeVC.hidesBottomBarWhenPushed = YES;
        noticeVC.news_author = _newsDetailObj.author;
        noticeVC.news_title = _newsDetailObj.title;
        [self.bottomBarVC.navigationController pushViewController:noticeVC animated:YES];
        
        return NO;
    }
    
    
    
    //判断是否是单击
//    if (navigationType == UIWebViewNavigationTypeLinkClicked)
//    {
//        NSURL *url = [request URL];
//        if([[UIApplication sharedApplication]canOpenURL:url])
//        {
//            [[UIApplication sharedApplication]openURL:url];
//        }
//        return NO;
//    }
//    return YES;
    return YES;
    
}

- (void)fileShowChick:(NSString *)fileURL
{
    NSString *suffix = [fileURL pathExtension];
    if ([suffix isEqualToString:@"txt"] || [suffix isEqualToString:@"epub"]) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* _filePath = [paths objectAtIndex:0];
        //File Url
        NSString* fileUrl = fileURL;
        //Encode Url 如果Url 中含有空格，一定要先 Encode
        fileUrl = [fileUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        //创建 Request
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
        NSString* fileName = [NSString stringWithFormat:@"sqmple.%@",suffix];
        NSString* filePath = [_filePath stringByAppendingPathComponent:fileName];
        //下载进行中的事件
        AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = @"正在加载";
        [operation setCompletionBlock:^{
            [HUD hide:YES afterDelay:1];
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
            LSYReadPageViewController *pageView = [[LSYReadPageViewController alloc] init];
            // NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"txt"];
            pageView.resourceURL = fileURL;  //文件位置
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                pageView.model = [LSYReadModel getLocalModelWithURL:fileURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self presentViewController:pageView animated:YES completion:nil];
                    AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
                    [delegate.window.rootViewController presentViewController:pageView animated:YES completion:nil];
                });
            });
            
        }];
        
        [operation start];
    }else if ([suffix isEqualToString:@"pdf"]){
        //pdf
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* _filePath = [paths objectAtIndex:0];
        
        //File Url
        NSString* fileUrl = fileURL;
        
        //Encode Url 如果Url 中含有空格，一定要先 Encode
        fileUrl = [fileUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        
        //创建 Request
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
        NSString* fileName = @"sample.pdf";//sample.pdf
        NSString* filePath = [_filePath stringByAppendingPathComponent:fileName];
        
        //下载进行中的事件
        AFURLConnectionOperation *operation =   [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            //下载的进度，如 0.53，就是 53%
            float progress =   (float)totalBytesRead / totalBytesExpectedToRead;
            
            HUD.progress = progress;
            HUD.labelText = [NSString stringWithFormat:@"正在打开：%.0f％", progress*100];
            
            //下载完成
            //该方法会在下载完成后立即执行
            if (progress == 1.0) {
                [HUD hide:YES afterDelay:1];
                NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
                ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase] ;
                
                if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
                {
                    ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
                    
                    readerViewController.delegate = self; // Set the ReaderViewController delegate to self
                    
                    readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                    
                    AppDelegate *delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
                    
                    [delegate.window.rootViewController presentViewController:readerViewController animated:YES completion:nil];
                    
                    
                }
                else // Log the error so that we know that something went wrong
                {
                    NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
                }
                
            }
        }];
        
        //下载完成的事件
        //该方法会在下载完成后 延迟 2秒左右执行
        //根据完成后需要处理的及时性不高，可以采用该方法
        [operation setCompletionBlock:^{
            
        }];
        
        [operation start];
    }
}


#pragma mark - ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) // See README
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    else
        return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_bottomBarVC.didScroll) {
        _bottomBarVC.didScroll();
    }
}


- (void)setBlockForCommentCell:(CommentCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            return YES;
//            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//            
//            OSCComment *comment = self.objects[indexPath.row];
//            int64_t ownID = [Config getOwnID];
//            
//            return (comment.authorID == ownID || _objectAuthorID == ownID);
        }
        
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        //删除评论
    };
}

- (NSString *) converFileSize:(NSString *) sizeStr
{
    long size = [sizeStr longLongValue];
    long kb = 1024;
    long mb = kb * 1024;
    long gb = mb * 1024;
    
    NSString *str;
    if (size >= gb) {
        str = [NSString stringWithFormat:@"%.1f GB",(float) size / gb];
    } else if (size >= mb) {
        float f = (float) size / mb;
        str = [NSString stringWithFormat:f > 100 ?@"%.0f MB":@"%.1f MB", f];
    } else if (size >= kb) {
        float f = (float) size / kb;
        str = [NSString stringWithFormat:f > 100 ?@"%.0f KB":@"%.1f KB", f];
    } else
    {
        str = [NSString stringWithFormat:@"%ld B",size];
    };
    return str;
}


- (void)imageViewer:(XHImageViewer *)imageViewer  willDismissWithSelectedView:(UIImageView*)selectedView
{
    return;
}


@end
