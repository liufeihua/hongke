//
//  AuditPageViewController.m
//  iosapp
//
//  Created by redmooc on 16/11/4.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "AuditPageViewController.h"
#import "NewsViewController.h"


@interface AuditPageViewController ()

@end

@implementation AuditPageViewController

- (instancetype)init{
    self = [super initWithTitle:@""
                   andSubTitles:@[@"待审", @"退稿", @"已审核"]  //type 1：待审；2：退稿；3：已审核；
                 andControllers:@[
                                  [[NewsViewController alloc]  initWithNewsListType:NewsListTypeAuditInfo cateId:1  isSpecial:0],
                                  [[NewsViewController alloc]  initWithNewsListType:NewsListTypeAuditInfo cateId:2  isSpecial:0],
                                  [[NewsViewController alloc]  initWithNewsListType:NewsListTypeAuditInfo cateId:3  isSpecial:0],
                                  ]
                    underTabbar:NO];
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
