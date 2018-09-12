//
//  LSPlayerMaskView.h
//  LSPlayer
//
//  Created by ls on 16/3/8.
//  Copyright © 2016年 song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSPlayerMaskView : UIView

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *fullButton;



+(instancetype)playerMaskView;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com