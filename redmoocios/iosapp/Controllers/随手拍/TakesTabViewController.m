//
//  TakesTabViewController.m
//  iosapp
//
//  Created by redmooc on 16/6/24.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "TakesTabViewController.h"
#import "TakesViewController.h"
#import "AddTakeViewController.h"
#import "JRSegmentViewController.h"
#import "AddPhotoViewController.h"

@interface TakesTabViewController ()<UIActionSheetDelegate,AddPhotoViewControllerDelegate>

@end

@implementation TakesTabViewController

- (instancetype)init{
    self = [super initWithTitle:@""
                   andSubTitles:@[@"随手拍",@"时光相册", @"跳蚤市场"]
                 andControllers:@[
                                  [[TakesViewController alloc] initWithTakesListType:TakesListTypeALL withInfoType:TakesInfoTypeTake],
                                  [[TakesViewController alloc] initWithTakesListType:TakesListTypeALL withInfoType:TakesInfoTypeTimeAlbum],
                                  [[TakesViewController alloc] initWithTakesListType:TakesListTypeALL withInfoType:TakesInfoTypeMarket],
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

- (void) addTake{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择发布类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"随手拍",@"时光相册",@"跳蚤市场", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1)
    {
        switch (buttonIndex)
        {
            case 0:
            {
//                AddTakeViewController *VC = [[AddTakeViewController alloc] initWithInfoType:1];
//                VC.hidesBottomBarWhenPushed = YES;
//                VC.delegate = self;
//                [self.navigationController pushViewController:VC animated:NO];
                
                AddPhotoViewController *VC = [[AddPhotoViewController alloc] initWithInfoType:1];
                VC.hidesBottomBarWhenPushed = YES;
                VC.delegate = self;
                [self.navigationController pushViewController:VC animated:NO];
            }
                break;
            case 1:
            {
                
                AddPhotoViewController *VC = [[AddPhotoViewController alloc] initWithInfoType:3];
                VC.hidesBottomBarWhenPushed = YES;
                VC.delegate = self;
                [self.navigationController pushViewController:VC animated:NO];
            }
                break;
                
            case 2:
            {
                AddPhotoViewController *VC = [[AddPhotoViewController alloc] initWithInfoType:2];
                VC.hidesBottomBarWhenPushed = YES;
                VC.delegate = self;
                [self.navigationController pushViewController:VC animated:NO];
            }
                break;
                
            default:
                break;
        }
        return;
    }
}

#pragma delegate AddTakeViewController
- (void) GiveisAdd:(bool)_isAdd{
    if (_isAdd) {
        TakesViewController * currentVC = (TakesViewController *)[self.viewPager.controllers objectAtIndex:self.viewPager.currentIndex];
        [currentVC refresh];
    }
}

@end
