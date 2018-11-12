//
//  AddPhotoViewController.h
//  iosapp
//
//  Created by redmooc on 2018/10/22.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@protocol AddPhotoViewControllerDelegate <NSObject>

@optional

- (void) GiveisAdd:(bool) _isAdd;

@end

@interface AddPhotoViewController : UIViewController
{
    BMKLocationService *locService;
    BMKGeoCodeSearch *geocodesearch;
    NSString *positionTitle;
    float longitude;
    float latitude;
}

- (instancetype)initWithInfoType :(int) type;

@property (nonatomic,assign) id<AddPhotoViewControllerDelegate> delegate;
@property (nonatomic,assign) int infoType;

@end
