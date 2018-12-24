//
//  GFKDUser.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/2.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDUser : GFKDBaseObject

@property (nonatomic, assign) NSNumber *userId;
@property (nonatomic, readwrite ,copy) NSString *birthday;
@property (nonatomic, readwrite ,copy) NSString *email;
@property (nonatomic, readwrite ,copy) NSString *gender;//性别
@property (nonatomic, readwrite ,copy) NSString *mobile;
@property (nonatomic, readwrite ,copy) NSString *nickname;
@property (nonatomic, readwrite ,copy) NSString *photo;
@property (nonatomic, readwrite ,copy) NSString *realName;
@property (nonatomic, readwrite ,copy) NSString *userName;
@property (nonatomic, readwrite ,copy) NSString *origphoto; //原图
@property (nonatomic, assign) NSNumber *userType;  ///** 0-9 校外   10以上  校内

@property (nonatomic, readwrite ,copy) NSString *bankCard;
@end
