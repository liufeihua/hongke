//
//  TakeTableViewCell.h
//  iosapp
//
//  Created by redmooc on 16/6/15.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDTakes.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import "AvatarImageView.h"

@class TakeTableViewCell;
@protocol TakeTableViewCellDelegate
- (void) takeTableViewCell : (TakeTableViewCell*) _cell tapSubImageViews : (UIImageView*) tapView allSubImageViews : (NSMutableArray *) _allSubImageviews;

- (void) takeTableViewCellWithZanCount:(int) zanCount;

@end

@interface TakeTableViewCell : UITableViewCell



@property (nonatomic, strong) AvatarImageView       *avterImageView;
@property (nonatomic, strong) UILabel               *nikeNameLable;
@property (nonatomic, strong) UILabel               *contentLable;
@property (nonatomic, strong) UILabel               *addressLable;
@property (nonatomic, strong) UILabel               *commitDateLable;
@property (nonatomic, strong) UILabel               *rangeLable;

@property (nonatomic, assign) id<TakeTableViewCellDelegate> delegate;

@property (nonatomic, strong) UIImageView           *zanLogo;
@property (nonatomic, strong) UIImageView           *starLogo;

@property (nonatomic, assign) bool                  isZaned;
@property (nonatomic, assign) bool                  isStared;

@property (nonatomic, assign) double                longitude;
@property (nonatomic, assign) double                latitude;

+ (CGFloat) heightWithEntity : (GFKDTakes*) _dateEntity isDetail:(BOOL)_isDeatil;

- (void) setDateEntity : (GFKDTakes*) _dateEntity;


//是否是内容详情页面
@property (nonatomic, assign) BOOL isDetailView;

@end
