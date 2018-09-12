//
//  AddTakeViewController.h
//  iosapp
//
//  Created by redmooc on 16/6/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@protocol AddTakeViewControllerDelegate <NSObject>

@optional

- (void) GiveisAdd:(bool) _isAdd;

@end

@interface AddTakeViewController : UIViewController
{
    BMKLocationService *locService;
    BMKGeoCodeSearch *geocodesearch;
    NSString *positionTitle;
    float longitude;
    float latitude;
}

- (instancetype)initWithInfoType :(int) type;

@property (nonatomic,assign) id<AddTakeViewControllerDelegate> delegate;
@property (nonatomic,assign) int infoType;


@end
