//
//  WebHtmlViewController.m
//  iosapp
//
//  Created by redmooc on 16/12/6.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "WebHtmlViewController.h"

@interface WebHtmlViewController ()


@end

@implementation WebHtmlViewController

-(instancetype) initWithTitle:(NSString *)title WithUrl:(NSString *)Url{
    self = [super init];
    if (self) {
        _showTitle = title;
        _url = Url;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = _showTitle;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
    webView.dataDetectorTypes = UIDataDetectorTypeAll;
//    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    webView.scrollView.bounces = NO;
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
