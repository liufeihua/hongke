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

#import "StudySchoolViewController.h"

@interface STTabViewController ()

@end

@implementation STTabViewController

- (instancetype)init{
   
//    self = [super initWithTitle:@""
//                   andSubTitles:@[@"视频", @"听说"]
////                   andSubTitles:@[@"视频", @"爱学习"]
////                     andSubTitles:@[@"视频", @"读书荟"]
//                 andControllers:@[
//                                  [[AudioViewController alloc] init],
////                                  [[RadioViewController alloc] initWithFrameHeight:self.view.bounds.size.height - 64 - 36 - 49 withNumber:@"audio"],
////                                   [[StudyHomeViewController alloc] init],//爱学习
//                                  [[StudySchoolViewController alloc] initWithNumber:@"audio" WithNav:YES],//
//                                  ]
//                    underTabbar:YES];
    
//   self = [super initWithTitle:@""
//                  andSubTitles:@[@"视频", @"听说"]
//                andControllers:@[
//                                              [[AudioViewController alloc] init],
//                                              [[StudySchoolViewController alloc] initWithNumber:@"audio" WithNav:YES],//
//                                              ]
//                   underTabbar:YES];
    self = [super initWithTitle:@""
                   andSubTitles:@[@"视频", @"听说"]
              andSubControllers:@[
                                  [[AudioViewController alloc] init],
                                  [[StudySchoolViewController alloc] initWithNumber:@"audio" WithNav:YES],//
                                  ]
                 andUnderTabbar:YES];
    
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
