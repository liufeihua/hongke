//
//  UserInfoEditViewController.h
//  NeighborsApp
//
//  Created by apple on 15/8/18.
//  Copyright (c) 2015年 luwutech. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol UserInfoEditViewControllerDelegate

@optional
- (void)showText:(NSString*)value withName:(NSString *)name;
@end


typedef enum
{
    USERINFO_EDIT_MODE_NICKNAME,  //呢称
    USERINFO_EDIT_MODE_PHONE,   //手机号码
    USERINFO_EDIT_MODE_REALNAME,   //姓名
    USERINFO_EDIT_MODE_BANKCARD,   //工商银行卡号
} USERINFO_EDIT_MODE;



@interface UserInfoEditViewController : UIViewController

@property (nonatomic, assign) id<UserInfoEditViewControllerDelegate> delegate;

- (id) initWithMode : (USERINFO_EDIT_MODE) _mode Text: (NSString*) _text;

@end
