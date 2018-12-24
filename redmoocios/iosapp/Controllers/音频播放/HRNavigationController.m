//
//  HRNavigationController.m
//  喜马拉雅FM(高仿品)
//
//  Created by apple-jd33 on 15/11/9.
//  Copyright © 2015年 HansRove. All rights reserved.
//

#import "HRNavigationController.h"
#import "HRPlayView.h"
#import <Masonry.h>
#import "UIImageView+WebCache.h"
#import "FYPlayManager.h"
#import "OSCAPI.h"

@interface HRNavigationController ()<PlayViewDelegate>
@property (nonatomic,strong) HRPlayView *playView;
@property (nonatomic,strong) NSString *imageName;

@property (nonatomic,strong) TracksViewModel *tracksVM;

@property (nonatomic,assign) NSInteger indexPathRow;
@property (nonatomic,assign) NSInteger rowNumber;
@property (nonatomic) BOOL isCan;

@end

@implementation HRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 防止其他ViewController的导航被遮挡, 这个类的主要作用是 PlayView
    //self.navigationBarHidden = YES;
    
    [self addNotification];

    self.playView = [[HRPlayView alloc] init];
    self.playView.delegate = self;
    [self.view addSubview:_playView];
    [_playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(70);
    }];
}

/** 添加通知 */
-(void)addNotification{
    // 控制PlayView样式
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPausePlayView:) name:@"setPausePlayView" object:nil];
    // 开启一个通知接受,开始播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingWithInfoDictionary:) name:@"BeginPlay" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingInfoDictionary:) name:@"StartPlay" object:nil];
    //当前歌曲改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCoverURL:) name:@"changeCoverURL" object:nil];
    
}


//// 隐藏图片
//- (void)hidePlayView:(NSNotification *)notification
//{
//    self.playView.hidden = YES;
//}
//
//// 显示图片
//- (void)showPlayView:(NSNotification *)notification
//{
//    self.playView.hidden = NO;
//}

// 暂停图片
- (void)setPausePlayView:(NSNotification *)notification{
    
    if ([[FYPlayManager sharedInstance] isPlay]) {
        [self.playView setPlayButtonView];
    }else{
        [self.playView setPauseButtonView];
    }
}

/** 通过播放地址 和 播放图片 */
- (void)playingWithInfoDictionary:(NSNotification *)notification {
    
    if (!_isCan) {
        _isCan = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dejTableInteger" object:nil userInfo:nil];
        // 设置背景图
        NSURL *coverURL = notification.userInfo[@"coverURL"];
        
        _tracksVM = notification.userInfo[@"theSong"];
        _indexPathRow = [notification.userInfo[@"indexPathRow"] integerValue];
        _rowNumber = self.tracksVM.radios.totalCount;
        
        [self.playView setPlayButtonView];
        
        /** 动画 */
        CGFloat y = [notification.userInfo[@"originy"] floatValue];
        CGRect rect = CGRectMake(10, y+80, 50, 50);
        
        CGFloat moveX = kNBR_SCREEN_W -68;
        CGFloat moveY = kNBR_SCREEN_H - rect.origin.y-60;
        
        NSTimeInterval nowTime = [[NSDate date]timeIntervalSince1970]*1000;
        NSInteger imTag = (long)nowTime%(3600000*24);
        
        UIImageView * sImgView = [[UIImageView alloc]initWithFrame:rect];
        sImgView.tag = imTag;
        [sImgView sd_setImageWithURL:coverURL];
        [self.view addSubview:sImgView];
        sImgView.layer.cornerRadius = 22;
        sImgView.clipsToBounds = YES;
        
        //组动画之修改透明度
        CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaBaseAnimation.fillMode = kCAFillModeForwards;//不恢复原态
        alphaBaseAnimation.duration = moveX/800;
        alphaBaseAnimation.removedOnCompletion = NO;
        [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];//决定动画的变化节奏
        
        //组动画之缩放动画
        CABasicAnimation * scaleBaseAnimation = [CABasicAnimation animation];
        scaleBaseAnimation.removedOnCompletion = NO;
        scaleBaseAnimation.fillMode = kCAFillModeForwards;//不恢复原态
        scaleBaseAnimation.duration = moveX/800;
        scaleBaseAnimation.keyPath = @"transform.scale";
        scaleBaseAnimation.toValue = @0.3;
        
        //组动画之路径变化
        CGMutablePathRef path = CGPathCreateMutable();//创建一个路径
        CGPathMoveToPoint(path, NULL, sImgView.center.x, sImgView.center.y);
        
        CGPathAddQuadCurveToPoint(path, NULL, sImgView.center.x+moveX/12, sImgView.center.y-80, sImgView.center.x+moveX/12*2, sImgView.center.y);
        
        CGPathAddLineToPoint(path,NULL,sImgView.center.x+moveX/12*4,sImgView.center.y+moveY/8);
        
        CGPathAddLineToPoint(path,NULL,sImgView.center.x+moveX/12*6,sImgView.center.y+moveY/8*3);
        
        CGPathAddLineToPoint(path,NULL,sImgView.center.x+moveX,sImgView.center.y+moveY);
        
        
        CAKeyframeAnimation * frameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        frameAnimation.duration = 5*moveX/800;
        
        frameAnimation.removedOnCompletion = NO;
        frameAnimation.fillMode = kCAFillModeForwards;
        
        [frameAnimation setPath:path];
        CFRelease(path);
        
        CAAnimationGroup *animGroup = [CAAnimationGroup animation];
        
        animGroup.animations = @[alphaBaseAnimation,scaleBaseAnimation,frameAnimation];
        animGroup.duration = moveX/800;
        animGroup.fillMode = kCAFillModeForwards;//不恢复原态
        animGroup.removedOnCompletion = NO;
        [sImgView.layer addAnimation:animGroup forKey:[NSString stringWithFormat:@"%ld",(long)imTag]];
        
        NSDictionary * dic = @{
                               @"animationGroup":sImgView,
                               @"coverURL":coverURL,
                               };
        
        
        NSTimer * t = [NSTimer scheduledTimerWithTimeInterval:animGroup.duration target:self selector:@selector(endPlayImgView:) userInfo:dic repeats:NO];
        [[NSRunLoop currentRunLoop]addTimer:t forMode:NSRunLoopCommonModes];
    }
    
}

- (void)endPlayImgView:(NSTimer *)timer{
    
    //NSLog(@"%@",timer.userInfo);
    
    UIImageView * imgView = (UIImageView *)[timer.userInfo objectForKey:@"animationGroup"];
    
    if (imgView) {
        [imgView removeFromSuperview];
        imgView = nil;
    }
    
    // 设置背景图
    NSURL *coverURL = timer.userInfo[@"coverURL"];
    
    [self.playView.contentIV sd_setImageWithURL:coverURL];
    self.playView.contentIV.alpha = 0.0;
    
    //修改透明度
    CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaBaseAnimation.fillMode = kCAFillModeForwards;//不恢复原态
    alphaBaseAnimation.duration = 1.0;
    alphaBaseAnimation.removedOnCompletion = NO;
    [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];//决定动画的变化节奏
    
    [self.playView.contentIV.layer addAnimation:alphaBaseAnimation forKey:[NSString stringWithFormat:@"%ld",(long)self.playView.contentIV]];
    
    FYPlayManager *playmanager = [FYPlayManager sharedInstance];
    [playmanager playWithModel:_tracksVM indexPathRow:_indexPathRow];
    _isCan = NO;
    // 远程控制事件 Remote Control Event
    // 加速计事件 Motion Event
    // 触摸事件 Touch Event
    // 开始监听远程控制事件
    // 成为第一响应者（必备条件）
    [self becomeFirstResponder];
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
}


- (void)playingInfoDictionary:(NSNotification *)notification {
    
    // 设置背景图
    NSURL *coverURL = notification.userInfo[@"coverURL"];
    
    _tracksVM = notification.userInfo[@"theSong"];
    _indexPathRow = [notification.userInfo[@"indexPathRow"] integerValue];
    _rowNumber = self.tracksVM.radios.totalCount;
    
   // [self.playView setPlayButtonView];
    
    [self.playView.contentIV sd_setImageWithURL:coverURL];
    self.playView.contentIV.alpha = 0.0;
    
    //修改透明度
    CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaBaseAnimation.fillMode = kCAFillModeForwards;//不恢复原态
    alphaBaseAnimation.duration = 1.0;
    alphaBaseAnimation.removedOnCompletion = NO;
    [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];//决定动画的变化节奏
    
    [self.playView.contentIV.layer addAnimation:alphaBaseAnimation forKey:[NSString stringWithFormat:@"%ld",(long)self.playView.contentIV]];
    
    FYPlayManager *playmanager = [FYPlayManager sharedInstance];
    [playmanager playWithModel:_tracksVM indexPathRow:_indexPathRow];
    _isCan = NO;
    // 远程控制事件 Remote Control Event
    // 加速计事件 Motion Event
    // 触摸事件 Touch Event
    // 开始监听远程控制事件
    // 成为第一响应者（必备条件）
    [self becomeFirstResponder];
    
}


/** 通过播放地址 和 播放图片 */
//- (void)playingWithInfoDictionary:(NSNotification *)notification {
//    // 设置背景图
//    NSURL *coverURL = notification.userInfo[@"coverURL"];
//    NSURL *musicURL = notification.userInfo[@"musicURL"];
//    [self.playView.contentIV sd_setImageWithURL:coverURL];
//
//    _tracksVM = notification.userInfo[@"theSong"];
//    _indexPathRow = [notification.userInfo[@"indexPathRow"] integerValue];
//    _rowNumber = self.tracksVM.radios.totalCount;
//
//    // 支持后台播放
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//    // 激活
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//
//    // 开始播放
//    _player = [AVPlayer playerWithURL:musicURL];
//    [_player play];
//    // 已改到背景变化时再变化
////    self.playView.playButton.selected = YES;
//}

- (void)changeCoverURL:(NSNotification *)notification {
    
    // 设置背景图
    NSURL *coverURL = notification.userInfo[@"coverURL"];
    
    [self.playView.contentIV sd_setImageWithURL:coverURL];
    self.playView.contentIV.alpha = 0.0;
    
    //修改透明度
    CABasicAnimation * alphaBaseAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaBaseAnimation.fillMode = kCAFillModeForwards;//不恢复原态
    alphaBaseAnimation.duration = 1.0;
    alphaBaseAnimation.removedOnCompletion = NO;
    [alphaBaseAnimation setToValue:[NSNumber numberWithFloat:1.0]];
    alphaBaseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];//决定动画的变化节奏
    
    [self.playView.contentIV.layer addAnimation:alphaBaseAnimation forKey:[NSString stringWithFormat:@"%ld",(long)self.playView.contentIV]];
    
}


#pragma mark - PlayView的代理方法
- (void)playButtonDidClick:(BOOL)selected {
    // 按钮被点击方法, 判断按钮的selected状态
//    if (selected) {
//        [_player play];  // 继续播放
//    } else {
//        [_player pause];  // 暂停播放, 以后会取消, 此处应该是跳转最后一个播放器控制器
//    }
}


- (void)dealloc {
    // 关闭消息中心
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
