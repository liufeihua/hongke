//
//  MyCommentsViewController.m
//  iosapp
//
//  Created by redmooc on 16/3/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "MyCommentsViewController.h"
#import "CommentListViewController.h"

@interface MyCommentsViewController ()

@end

@implementation MyCommentsViewController

- (instancetype)init{
    self = [super initWithTitle:@"我的评论"
                   andSubTitles:@[@"收到的评论", @"发出的评论"]
                 andControllers:@[
                                  [[CommentListViewController alloc] initWithType:2],
                                  [[CommentListViewController alloc] initWithType:1],
                                  ]];
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
