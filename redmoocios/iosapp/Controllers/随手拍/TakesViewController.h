//
//  TakesViewController.h
//  iosapp
//
//  Created by redmooc on 16/6/15.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDObjsViewController.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

typedef NS_ENUM(int, TakesListType)
{
    TakesListTypeMy = 1,  //我的随手拍
    TakesListTypeALL = 2,  //随手拍按点击列表
    TakesListTypeOther = 3,  //显示别人的随手拍列表
    
};

typedef NS_ENUM(int, TakesInfoType)
{
    TakesInfoTypeTake = 1,  //随手拍
    TakesInfoTypeMarket = 2,  //跳蚤市场
    TakesInfoTypeTimeAlbum = 3, //时光相册
    
};

@interface TakesViewController : GFKDObjsViewController
{
    BMKLocationService *locService;
}

- (instancetype)initWithTakesListType:(TakesListType)type withInfoType:(TakesInfoType)infoType;


@property (nonatomic, assign) TakesListType myTakesListType;
@property (nonatomic, assign) TakesInfoType myTakesInfoType;
@property (nonatomic, copy) NSDictionary *dict;

- (void) addTake;

@end
