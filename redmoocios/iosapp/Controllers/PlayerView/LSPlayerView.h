//
//  LSPlayerView.h
//  LSPlayer
//
//  Created by ls on 16/3/8.
//  Copyright © 2016年 song. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LSPLayerViewLocationType) {
    LSPLayerViewLocationTypeMiddle=0, //中间
    LSPLayerViewLocationTypeTop, //顶部
    LSPLayerViewLocationTypeBottom, //底部
    LSPLayerViewLocationTypeDragging
    
};

@interface LSPlayerView : UIImageView



//视频URL
@property (nonatomic, copy) NSString* videoURL;

//返回按钮点击事件
@property (nonatomic, copy) void (^backBlock)();

//当前显示的frame
@property (nonatomic, assign) CGRect currentFrame;

@property (nonatomic, assign) int indexRow;
@property (nonatomic, assign) int indexSection;

@property (nonatomic,strong) UITableView * tempSuperView;
//创建
+ (instancetype)playerView;

- (void)closeClick;//关闭

@end
