//
//  AvatarImageView.h
//  iosapp
//
//  Created by redmooc on 16/7/4.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDUser.h"

@interface AvatarImageView : UIImageView

@property (nonatomic, strong)  GFKDUser *userInfoEntity;

- (void) enableAvatarModeWithUserInfoDict : (int) userId pushedView : (UIViewController*) _viewController;


@end
