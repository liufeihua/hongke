//
//  UITableView+Video.m
//  LCTableViewVideoPlay
//
//  Created by lcc on 2017/12/14.
//  Copyright © 2017年 early bird international. All rights reserved.
//

#import "UITableView+Video.h"
#import "NewsCell.h"
#import <objc/runtime.h>
#import "WMPlayer.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@implementation UITableView (Video)
WMPlayer *wmPlayer;


#pragma public method
- (void)handleScrollingCellOutScreen{
    if (self.playingCell  && [self playingCellIsOutScreen]) {
        //NSLog(@"移动到屏幕外，停止播放视频");
        NewsCell *videoCell = self.playingCell;
        if (wmPlayer) {
            [self releaseWMPlayer];
            [videoCell.VideoImg setHidden:NO];
        }
    }
    
}

/* 进行视频自动播放判定逻辑判断 */
- (void)handleScrollPlay{
    NewsCell *cell = (NewsCell *)[self getMinCenterCell];
    if (cell && ![self.playingCell isEqual:cell]) {
        //NSLog(@"当前的 cell 存在,是%ld",cell.indexPathRow);
        
        if ([cell.NewsModel.hasVideo intValue] == 1){
            if (wmPlayer) {
                [cell.VideoImg.superview bringSubviewToFront:cell.VideoImg];
                [cell.VideoImg setHidden:NO];
                [self releaseWMPlayer];
            }
            
            
            UIApplication *app = [UIApplication sharedApplication];
            NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
            int netType = 0;
            //获取到网络返回码
            for (id child in children) {
                if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                    //获取到状态栏
                    netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
                    if (netType == 5){
                        NSLog(@"当前网络状态wifi");
                        
                        wmPlayer = [[WMPlayer alloc]initWithFrame:cell.imgIcon.bounds];
                        wmPlayer.delegate = self;
                        //关闭音量调节的手势
                        wmPlayer.enableVolumeGesture = NO;
                        wmPlayer.closeBtn.hidden = YES;
                        wmPlayer.fullScreenBtn.hidden = YES;
                        wmPlayer.playOrPauseBtn.hidden = YES;
                        wmPlayer.closeBtnStyle = CloseBtnStyleClose;
                        wmPlayer.URLString = cell.NewsModel.video;
                        [wmPlayer play];
                        
                        
                        //cell.VideoImg.hidden = YES;
                        [cell.imgIcon addSubview:wmPlayer];
                        [cell.imgIcon bringSubviewToFront:wmPlayer];
                        [cell.VideoImg bringSubviewToFront:wmPlayer];
                    }
                }
            }
            
            
//               FGGNetWorkStatus status=[FGGReachability networkStatus];
//            if (status == FGGNetWorkStatusWifi){
//                NSLog(@"当前网络状态wifi");
//                wmPlayer = [[WMPlayer alloc]initWithFrame:cell.imgIcon.bounds];
//                wmPlayer.delegate = self;
//                //关闭音量调节的手势
//                wmPlayer.enableVolumeGesture = NO;
//                wmPlayer.closeBtn.hidden = YES;
//                wmPlayer.fullScreenBtn.hidden = YES;
//                wmPlayer.playOrPauseBtn.hidden = YES;
//                wmPlayer.closeBtnStyle = CloseBtnStyleClose;
//                wmPlayer.URLString = cell.NewsModel.video;
//                [wmPlayer play];
//
//
//                cell.VideoImg.hidden = YES;
//                [cell.imgIcon addSubview:wmPlayer];
//                [cell.imgIcon bringSubviewToFront:wmPlayer];
//            }
        }
        
        
//        if (self.playingCell) {
//            NewsCell *playingCell = (NewsCell *)self.playingCell;
//        }
        self.playingCell = cell;
    }
}

/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    //堵塞主线程
    //    [wmPlayer.player.currentItem cancelPendingSeeks];
    //    [wmPlayer.player.currentItem.asset cancelLoading];
    [wmPlayer pause];
    
    
    [wmPlayer removeFromSuperview];
    [wmPlayer.playerLayer removeFromSuperlayer];
    [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    wmPlayer.player = nil;
    wmPlayer.currentItem = nil;
    //释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [wmPlayer.autoDismissTimer invalidate];
    wmPlayer.autoDismissTimer = nil;
    
    
    wmPlayer.playOrPauseBtn = nil;
    wmPlayer.playerLayer = nil;
    wmPlayer = nil;
}

/* 获取距离屏幕最中间的cell */
- (id)getMinCenterCell{
    CGFloat minDelta = CGFLOAT_MAX;
    //屏幕中央位置
    CGFloat screenCenterY = SCREEN_HEIGHT * 0.5;
    //当前距离屏幕中央最近的cell
    id minCell = nil;
    for (id cell in self.visibleCells) {
        if ([cell isKindOfClass:[NewsCell class]]) {
            NewsCell *videoCell = (NewsCell *)cell;
            //获取当前 cell 的居中点坐标
            CGPoint cellCenterPoint = CGPointMake(videoCell.frame.origin.x, videoCell.frame.size.height * 0.5 + videoCell.frame.origin.y);
            //转换当前的 cell 的坐标
            CGPoint coorPoint = [videoCell.superview convertPoint:cellCenterPoint toView:nil];
            CGFloat deltaTemp =  fabs(coorPoint.y - screenCenterY);
            
            if (deltaTemp < minDelta) {
                minCell = videoCell;
                minDelta = deltaTemp;
            }
        }
    }
    return minCell;
    
}

/* 当前播放的视频是否划出屏幕 */
- (BOOL)playingCellIsOutScreen{
    if (!self.playingCell) {
        return YES;
    }
    NewsCell *videoCell = (NewsCell *)self.playingCell;
    //当前显示区域内容
    CGRect visiableContentZone = [UIScreen mainScreen].bounds;
    //向上滚动
    if(self.scrollDirection == LC_SCROLL_UP){
        //找到滚动时候的正在播放视频的cell底部的y坐标点，计算出当前播放的视频是否移除到屏幕外
        CGRect playingCellFrame = videoCell.frame;
        //当前正在播放视频的坐标
        CGPoint cellBottomPoint = CGPointMake(playingCellFrame.origin.x, playingCellFrame.size.height + playingCellFrame.origin.y);
        //坐标系转换（转换到 window坐标）
        CGPoint coorPoint = [videoCell.superview convertPoint:cellBottomPoint toView:nil];
        return CGRectContainsPoint(visiableContentZone, coorPoint);
    }
    //向下滚动
    else if(self.scrollDirection == LC_SCROLL_DOWN){
        //找到滚动时候的正在播放视频的cell底部的y坐标点，计算出当前播放的视频是否移除到屏幕外
        CGRect playingCellFrame = videoCell.frame;
        //当前正在播放视频的坐标
        CGPoint orginPoint = CGPointMake(playingCellFrame.origin.x, playingCellFrame.origin.y);
        //坐标系转换（转换到 window坐标）
        CGPoint coorPoint = [videoCell.superview convertPoint:orginPoint toView:nil];
        return CGRectContainsPoint(visiableContentZone, coorPoint);
    }
    else{
        return NO;
    }
    return YES;
}

#pragma getter and setter

- (void)setScrollDirection:(LCSCROLL_DIRECTION)scrollDirection{
    objc_setAssociatedObject(self, @selector(scrollDirection), @(scrollDirection), OBJC_ASSOCIATION_ASSIGN);
}

- (LCSCROLL_DIRECTION)scrollDirection{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setPlayingCell:(id)playingCell{
    objc_setAssociatedObject(self, @selector(playingCell), playingCell, OBJC_ASSOCIATION_RETAIN);
}

- (id)playingCell{
   return objc_getAssociatedObject(self, _cmd);
}

- (UIView *)centerSepLine{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCenterSepLine:(UIView *)centerSepLine{
    objc_setAssociatedObject(self, @selector(centerSepLine), centerSepLine, OBJC_ASSOCIATION_RETAIN);
}



-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    NSLog(@"didSingleTaped");
}
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    NSLog(@"didDoubleTaped");
}

///播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    NSLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    NSLog(@"wmplayerDidFinishedPlay");
//    VideoCell *currentCell = (VideoCell *)[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
//    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self releaseWMPlayer];
    //[self setNeedsStatusBarAppearanceUpdate];
}

@end
