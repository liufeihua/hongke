//
//  NewsDetailCell.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/5.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "UIColor+Util.h"

#import "NewsDetailCell.h"

@implementation NewsDetailCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor whiteColor];
        
        [self initSubviews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        //selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
        selectedBackground.backgroundColor = [UIColor whiteColor];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)initSubviews
{
    _webView = [UIWebView new];
    _webView.scrollView.bounces = NO;
    _webView.scrollView.scrollEnabled = NO;
    _webView.scalesPageToFit = NO;  //禁止用户缩放页面
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.dataDetectorTypes = UIDataDetectorTypePhoneNumber|UIDataDetectorTypeLink;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    [self.contentView addSubview:_webView];
}



- (void)setLayout
{
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(_webView);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_webView]|"   options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:views]];
}



@end
