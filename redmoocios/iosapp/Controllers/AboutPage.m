//
//  AboutPage.m
//  iosapp
//
//  Created by chenhaoxiang on 3/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AboutPage.h"
#import "Utils.h"
#import "FeedbackPage.h"

@interface AboutPage ()

@end

@implementation AboutPage

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"关于我们";
    self.view.backgroundColor = [UIColor themeColor];
    
    UIImageView *logo = [UIImageView new];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.image = [UIImage imageNamed:@"logo_login"];
    [self.view addSubview:logo];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = [UIColor darkGrayColor];
    NSString *content = [@"        " stringByAppendingString:@"红客是国防科技大学党委着眼过好网络关时代关，适应移动信息网络发展趋势，面向全校官兵和校友推出的一款思想政治教育APP，具有学习、教育、新闻、服务、交流等功能，致力于打造学校思想教育新阵地、工作指导新平台、学习成才新课堂、信息服务新窗口。\n\n投稿邮箱：hongke_gfkd@163.com；\n"];
    content = [content stringByAppendingString:@"                    "];
    content = [content stringByAppendingString:@"hongke@gfkd.mtn；\n报料热线：0731-574880\n技术保障: (电话）0731-573008\n"];
    content = [content stringByAppendingString:@"               "];
    content = [content stringByAppendingString:@"（邮箱）mapp@nudt.edu.cn"];
    
    contentLabel.text = content;
    [self.view addSubview:contentLabel];
    
    
    UILabel *declarationLabel = [UILabel new];
    declarationLabel.numberOfLines = 0;
    declarationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    declarationLabel.textAlignment = NSTextAlignmentCenter;
    declarationLabel.textColor = [UIColor lightGrayColor];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    declarationLabel.text = [NSString stringWithFormat:@"ver:%@\n©2016 nudt.edn.cn.All rights reserved.", version];
    [self.view addSubview:declarationLabel];
    
    UILabel *reportLabel = [UILabel new];
    reportLabel.numberOfLines = 0;
    reportLabel.lineBreakMode = NSLineBreakByWordWrapping;
    reportLabel.textAlignment = NSTextAlignmentCenter;
    reportLabel.textColor = [UIColor lightGrayColor];
    reportLabel.text = @"投诉";
    reportLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reportChick)];
    [reportLabel addGestureRecognizer:labelTapGestureRecognizer];
    
    [self.view addSubview:reportLabel];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(logo, declarationLabel,contentLabel,reportLabel);
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logo      attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logo      attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:-190.f]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[logo(60)]-15-[contentLabel]-15-[declarationLabel]-15-[reportLabel]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[logo(80)]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[contentLabel]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[declarationLabel]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[reportLabel]-20-|" options:0 metrics:nil views:views]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)reportChick
{
    [self.navigationController pushViewController:[FeedbackPage new] animated:YES];
}



@end
