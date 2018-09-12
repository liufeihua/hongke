//
//  GFKDObjsTopBtnViewController.m
//  iosapp
//
//  Created by redmooc on 16/3/1.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDObjsTopBtnViewController.h"
#import "GFKDObjsViewController.h"
#import "UIViewController+WHReturntop.h"


@interface GFKDObjsTopBtnViewController ()

@property (nonatomic, strong) GFKDObjsViewController *objsVC;

@end

@implementation GFKDObjsTopBtnViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self.view addSubview:_objsVC.tableView];
        
        //* 实例 */
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"fx_cart_top"]];
        [self AddWHReturnTop:CGRectMake(250, 500, 50, 50) BackImage:imageView CallBackblock:^{
            NSLog(@"Top--点击了按钮");
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
            [_objsVC.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }];
    }
    
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
