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
- (void)showText:(NSString*)value;
@end


typedef enum
{
    USERINFO_EDIT_MODE_NICKNAME,
    USERINFO_EDIT_MODE_PHONE,
    USERINFO_EDIT_MODE_HABIT,
    USERINFO_EDIT_MODE_SIGNATURE,
} USERINFO_EDIT_MODE;



@interface UserInfoEditViewController : UIViewController

@property (nonatomic, assign) id<UserInfoEditViewControllerDelegate> delegate;

- (id) initWithMode : (USERINFO_EDIT_MODE) _mode Text: (NSString*) _text;

@end
