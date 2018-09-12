//
//  LaunchScreenViewController.m
//  iosapp
//
//  Created by redmooc on 16/2/25.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "LaunchScreenViewController.h"

#import "UIImageView+WebCache.h"

@interface LaunchScreenViewController ()

@end

@implementation LaunchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 //   [_launchImage setImage:[UIImage imageNamed:@"002"]];
   NSString *str = @"http://mapp.nudt.edu.cn/uploads/1/image/public/201602/20160216103635_xhh8og002l.jpg";
   [_launchImage sd_setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"default.png"]];
   
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
