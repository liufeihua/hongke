//
//  NewsImagesViewController.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/19.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsImagesViewController : UIViewController{
    CGFloat offset;
}

@property (nonatomic, assign) int   newsID;
@property(nonatomic,strong) UIViewController *parentVC;

@property(nonatomic,strong) NSArray *photoSet;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
- (IBAction)replyBtnAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *label_zanNum;

@property (weak, nonatomic) IBOutlet UIButton *btn_star;
@property (weak, nonatomic) IBOutlet UIButton *btn_zan;

@property (weak, nonatomic) IBOutlet UIButton *btn_share;

- (IBAction)btnZanClick:(id)sender;

- (IBAction)btnStarClick:(id)sender;

- (IBAction)btnShareClick:(id)sender;


@end
