//
//  STTabViewController.m
//  iosapp
//
//  Created by redmooc on 16/10/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "STTabViewController.h"
#import "AudioViewController.h"
#import "RadioViewController.h"
#import "JRSegmentViewController.h"
#import "SearchArticleViewController.h"
#import "StudyHomeViewController.h"

@interface STTabViewController ()

@end

@implementation STTabViewController

- (instancetype)init{
    
    self = [super initWithTitle:@""
//                   andSubTitles:@[@"视频", @"电台"]
                   andSubTitles:@[@"视频", @"爱学习"]
                 andControllers:@[
                                  [[AudioViewController alloc] init],
//                                  [[RadioViewController alloc] initWithFrameHeight:self.view.bounds.size.height - 64 - 36 - 49 withNumber:@"audio"],
                                   [[StudyHomeViewController alloc] init],
                                  ]
                    underTabbar:YES];
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


@end
