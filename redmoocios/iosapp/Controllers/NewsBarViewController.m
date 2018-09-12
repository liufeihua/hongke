//
//  NewsBarViewController.m
//  iosapp
//
//  Created by redmooc on 16/3/1.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "NewsBarViewController.h"
#import "NewsViewController.h"
#import "UIViewController+WHReturntop.h"

@interface NewsBarViewController ()



@end

@implementation NewsBarViewController


- (instancetype)initWithNewsListType:(NewsListType)type cateId:(int)cateId isSpecial:(int)isSpecial
{
    self = [super init];
    if (self) {
        _newsVC = [[NewsViewController alloc] initWithNewsListType:type cateId:cateId isSpecial:isSpecial];
        //[self addChildViewController:_newsVC];
       // [self.view addSubview:_newsVC];
    
        CGRect rect = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [_newsVC.tableView setFrame:rect];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:_newsVC];
    [self.view addSubview:_newsVC.tableView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fx_cart_top"]];
    [self AddWHReturnTop:CGRectMake(kNBR_SCREEN_W-60, kNBR_SCREEN_H - 200, 40, 40) BackImage:imageView CallBackblock:^{
        NSLog(@"点击了按钮");
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_newsVC.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
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
