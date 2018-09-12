//
//  Config.h
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GFKDUser.h"

@class OSCMyInfo;

@interface Config : NSObject

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password;

+ (void)saveOwnID:(int64_t)userID userName:(NSString *)userName score:(int)score favoriteCount:(int)favoriteCount fansCount:(int)fanCount andFollowerCount:(int)followerCount;

+ (void)updateMyInfo:(OSCMyInfo *)myInfo;

+ (void)savePortrait:(UIImage *)portrait;

+ (void)saveName:(NSString *)actorName sex:(NSInteger)sex phoneNumber:(NSString *)phoneNumber corporation:(NSString *)corporation andPosition:(NSString *)position;

+ (void)clearCookie;

+ (NSArray *)getOwnAccountAndPassword;
+ (int64_t)getOwnID;
+ (NSString *)getOwnUserName;
+ (NSArray *)getActivitySignUpInfomation;
+ (NSArray *)getUsersInformation;
+ (UIImage *)getPortrait;
+ (GFKDUser*)getMyInfo;

+ (void)saveTweetText:(NSString *)tweetText forUser:(ino64_t)userID;
+ (NSString *)getTweetText;

+ (int)teamID;
+ (void)setTeamID:(int)teamID;
+ (void)saveTeams:(NSArray *)teams;
+ (NSMutableArray *)teams;
+ (void)removeTeamInfo;
+ (void)saveWhetherNightMode:(BOOL)isNight;
+ (BOOL)getMode;


/*2015-11-2 保存用户信息 add by lfh*/
+ (void) saveUserName:(NSString *) userName realName:(NSString *) readNmae birthday:(NSString *) birthday email:(NSString *)email gender:(NSString *)gender mobile:(NSString *)mobile nickName:(NSString *)nickName photo:(NSString *)photo token:(NSString*)token;
+ (void) saveUser:(GFKDUser *) user token:(NSString*)token;


/*add by lfh 2015-11-02 保存token*/
+ (NSString *) getToken;
+ (void) reomveToken;

//add by lfh 2016-5-6 保存deviceToken 方便APNS推送使用
+ (void) saveDeviceToken:(NSString *)deviceToken;
+ (NSString *) getDeviceToken;


@end
