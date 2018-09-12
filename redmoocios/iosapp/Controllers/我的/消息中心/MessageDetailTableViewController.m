//
//  MessageDetailTableViewController.m
//  iosapp
//
//  Created by redmooc on 16/12/5.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "MessageDetailTableViewController.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "Config.h"
#import "NewsDetailCell.h"
#import "XHImageViewer.h"
#import "OSCAPI.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MessageDetailTableViewController ()<UIWebViewDelegate,XHImageViewerDelegate>
@property (nonatomic, readonly, strong) GFKDMessage  *message;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, copy)   NSString *HTML;
@property (nonatomic, assign) BOOL      isLoadingFinished;
@property (nonatomic, assign) CGFloat   webViewHeight;

@property(nonatomic,strong) NSMutableArray *htmlImgs;
@property(nonatomic,strong) NSMutableArray *currentSelectImageViews;


@end

@implementation MessageDetailTableViewController

- (instancetype)initWitHMessage:(GFKDMessage *)message{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.title     = @"消息详情";
        _message = message;
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
    

    
    _HTML = [Utils HTMLWithData:@{
                                  @"createDate": _message.createDate,
                                  @"title": _message.title,
                                  @"content": _message.content
                                  }
                  usingTemplate:@"message"];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.1f;
//}
//
//- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return [[UIView alloc] init];}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.1f;
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _isLoadingFinished? _webViewHeight + 30 : 600;}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsDetailCell *cell = [NewsDetailCell new];
    cell.webView.delegate = self;
    if (_HTML != nil) {  //2016-11-18 当_HTML为空里，导致web高度得不到实际高度
        [cell.webView loadHTMLString:_HTML baseURL:[NSBundle mainBundle].resourceURL];
    }
    return cell;

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}




#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
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
    
    _webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    NSLog(@"_webViewHeight---%f",_webViewHeight);
    _isLoadingFinished = YES;
    
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
        
        return NO;
    }
    
    return YES;
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}


- (void)imageViewer:(XHImageViewer *)imageViewer  willDismissWithSelectedView:(UIImageView*)selectedView
{
    return;
}



@end
