//
//  Config.m
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "Config.h"
//#import "TeamTeam.h"
//#import "OSCMyInfo.h"


#import <SSKeychain.h>

NSString * const kService = @"OSChina";
NSString * const kAccount = @"account";
NSString * const kUserID = @"userID";

//NSString * const kUserName = @"name";
NSString * const kPortrait = @"portrait";
NSString * const kUserScore = @"score";
NSString * const kFavoriteCount = @"favoritecount";
NSString * const kFanCount = @"fans";
NSString * const kFollowerCount = @"followers";

NSString * const kJointime = @"jointime";
NSString * const kDevelopPlatform = @"devplatform";
NSString * const kExpertise = @"expertise";
NSString * const kHometown = @"from";

NSString * const kTrueName = @"trueName";
NSString * const kSex = @"sex";
NSString * const kPhoneNumber = @"phoneNumber";
NSString * const kCorporation = @"corporation";
NSString * const kPosition = @"position";

NSString * const kTeamID = @"teamID";
NSString * const kTeamsArray = @"teams";

/*用户信息*/
NSString * const kUserName = @"userName";
NSString * const kRealName = @"realName";
NSString * const kBirthday = @"birthday";
NSString * const kEmail = @"email";
NSString * const kGender = @"gender";
NSString * const kMobile = @"mobile";
NSString * const kNickName = @"nickName";
NSString * const kBankCard = @"bankCard";
NSString * const kPhoto = @"photo";
NSString * const kToken = @"token";
NSString * const kUserType = @"userType";


NSString * const kDeviceToken = @"devicetoken";


@implementation Config

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account forKey:kAccount];
    [userDefaults synchronize];
    
    [SSKeychain setPassword:password forService:kService account:account];
}


+ (void)saveOwnID:(int64_t)userID
         userName:(NSString *)userName
            score:(int)score
    favoriteCount:(int)favoriteCount
        fansCount:(int)fanCount
 andFollowerCount:(int)followerCount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(userID) forKey:kUserID];
    [userDefaults setObject:userName forKey:kUserName];
    [userDefaults setObject:@(score) forKey:kUserScore];
    [userDefaults setObject:@(favoriteCount) forKey:kFavoriteCount];
    [userDefaults setObject:@(fanCount)      forKey:kFanCount];
    [userDefaults setObject:@(followerCount) forKey:kFollowerCount];
    [userDefaults synchronize];
}


+ (void)updateMyInfo:(OSCMyInfo *)myInfo
{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:myInfo.name forKey:kUserName];
//    [userDefaults setObject:@(myInfo.score) forKey:kUserScore];
//    [userDefaults setObject:@(myInfo.favoriteCount) forKey:kFavoriteCount];
//    [userDefaults setObject:@(myInfo.fansCount)      forKey:kFanCount];
//    [userDefaults setObject:@(myInfo.followersCount) forKey:kFollowerCount];
//    [userDefaults synchronize];
}



+ (void)clearCookie
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"sessionCookies"];
}

+ (void)savePortrait:(UIImage *)portrait
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:UIImagePNGRepresentation(portrait) forKey:kPortrait];
    
    [userDefaults synchronize];
}

+ (void)saveName:(NSString *)actorName sex:(NSInteger)sex phoneNumber:(NSString *)phoneNumber corporation:(NSString *)corporation andPosition:(NSString *)position
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:actorName forKey:kTrueName];
    [userDefaults setObject:@(sex) forKey:kSex];
    [userDefaults setObject:phoneNumber forKey:kPhoneNumber];
    [userDefaults setObject:corporation forKey:kCorporation];
    [userDefaults setObject:position forKey:kPosition];
    [userDefaults synchronize];
}

+ (void)saveTweetText:(NSString *)tweetText forUser:(ino64_t)userID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *key = [NSString stringWithFormat:@"tweetTmp_%lld", userID];
    [userDefaults setObject:tweetText forKey:key];
    
    [userDefaults synchronize];
}


+ (NSArray *)getOwnAccountAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kAccount];
    NSString *password = [SSKeychain passwordForService:kService account:account];
    
    if (account) {return @[account==nil?@"":account, password==nil?@"":password];}
    return nil;
}

+ (int64_t)getOwnID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *userID = [userDefaults objectForKey:kUserID];
    
    if (userID) {return [userID longLongValue];}
    return 0;
}

+ (NSString *)getOwnUserName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:kUserName];
    if (userName) {return userName;}
    return @"";
}

+ (NSArray *)getActivitySignUpInfomation
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *name = [userDefaults objectForKey:kTrueName] ?: @"";
    NSNumber *sex = [userDefaults objectForKey:kSex] ?: @(0);
    NSString *phoneNumber = [userDefaults objectForKey:kPhoneNumber] ?: @"";
    NSString *corporation = [userDefaults objectForKey:kCorporation] ?: @"";
    NSString *position = [userDefaults objectForKey:kPosition] ?: @"";
    
    return @[name, sex, phoneNumber, corporation, position];
}

+ (NSArray *)getUsersInformation
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [userDefaults objectForKey:kUserName];
    NSString *nickName = [userDefaults objectForKey:kNickName] == nil?@"":[userDefaults objectForKey:kNickName];
    NSString *gender = [userDefaults objectForKey:kGender] == nil?@"":[userDefaults objectForKey:kGender];
    NSString *mobile = [userDefaults objectForKey:kMobile] == nil?@"":[userDefaults objectForKey:kMobile];
    NSString *birthday = [userDefaults objectForKey:kBirthday] == nil?@"":[userDefaults objectForKey:kBirthday];
    NSString *email = [userDefaults objectForKey:kEmail] == nil?@"":[userDefaults objectForKey:kEmail];
    NSString *photo = [userDefaults objectForKey:kPhoto]==nil?@"":[userDefaults objectForKey:kPhoto];
    
    if (userName) {
        return @[userName, nickName, gender, mobile, birthday, email,photo];
    } else{
       return @[@"点击头像登录", @"", @"", @"", @"", @"",@""];
    }
}

+ (GFKDUser*)getMyInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    GFKDUser *user = [GFKDUser alloc];
    user.userName = [userDefaults objectForKey:kUserName];
    user.realName = [userDefaults objectForKey:kRealName];
    user.gender = [userDefaults objectForKey:kGender];
    user.mobile = [userDefaults objectForKey:kMobile];
    user.birthday = [userDefaults objectForKey:kBirthday];
    user.email = [userDefaults objectForKey:kEmail];
    user.photo = [userDefaults objectForKey:kPhoto];
    user.nickname = [userDefaults objectForKey:kNickName];
    user.userType = [userDefaults objectForKey:kUserType];
    
    user.bankCard = [userDefaults objectForKey:kBankCard];
    return user;
}

+ (UIImage *)getPortrait
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSData * data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[userDefaults objectForKey:kPhoto]]];
    UIImage *portrait = [UIImage imageWithData:data];
    
    return portrait;
}

+ (NSString *)getTweetText
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *IdStr = [NSString stringWithFormat:@"tweetTmp_%lld", [Config getOwnID]];
    NSString *tweetText = [userDefaults objectForKey:IdStr];
    
    return tweetText;
}


#pragma mark - Team

+ (int)teamID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userDefaults objectForKey:kTeamID] intValue];
}

+ (void)setTeamID:(int)teamID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:@(teamID) forKey:kTeamID];
    [userDefaults synchronize];
}

+ (void)saveTeams:(NSArray *)teams
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *rawTeams = [NSMutableArray new];
    
//    for (TeamTeam *team in teams) {
//        [rawTeams addObject:@[@(team.teamID), team.name]];
//    }
    [userDefaults setObject:rawTeams forKey:kTeamsArray];
    
    [userDefaults synchronize];
}

+ (NSMutableArray *)teams
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *rawTeams = [userDefaults objectForKey:kTeamsArray];
    NSMutableArray *teams = [NSMutableArray new];
    
    for (NSArray *rawTeam in rawTeams) {
//        TeamTeam *team = [TeamTeam new];
//        team.teamID = [((NSNumber *)rawTeam[0]) intValue];
//        team.name = rawTeam[1];
//        [teams addObject:team];
    }
    
    return teams;
}


+ (void)removeTeamInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kTeamID];
    [userDefaults removeObjectForKey:kTeamsArray];
}

//夜间状态
+ (void)saveWhetherNightMode:(BOOL)isNight
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(isNight) forKey:@"mode"];
    [userDefaults synchronize];
}
+ (BOOL)getMode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    return [[userDefaults objectForKey:@"mode"] boolValue];
}


//2015-11-2 保存用户信息
+ (void) saveUserName:(NSString *) userName realName:(NSString *) readNmae birthday:(NSString *) birthday email:(NSString *)email gender:(NSString *)gender mobile:(NSString *)mobile nickName:(NSString *)nickName photo:(NSString *)photo token:(NSString*)token
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userName forKey:kUserName];
    [userDefaults setObject:readNmae forKey:kRealName];
    [userDefaults setObject:birthday forKey:kBirthday];
    [userDefaults setObject:email forKey:kEmail];
    [userDefaults setObject:gender forKey:kGender];
    [userDefaults setObject:mobile forKey:kMobile];
    [userDefaults setObject:nickName forKey:kNickName];
     [userDefaults setObject:photo forKey:kPhoto];
     [userDefaults setObject:token forKey:kToken];
    
    
    [userDefaults synchronize];
}

+ (void) saveUser:(GFKDUser *) user token:(NSString*)token{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:user.userId forKey:kUserID];
    [userDefaults setObject:user.userName forKey:kUserName];
    [userDefaults setObject:user.realName forKey:kRealName];
    [userDefaults setObject:user.birthday forKey:kBirthday];
    [userDefaults setObject:user.email forKey:kEmail];
    [userDefaults setObject:user.gender forKey:kGender];
    [userDefaults setObject:user.mobile forKey:kMobile];
    [userDefaults setObject:user.nickname forKey:kNickName];
    [userDefaults setObject:user.photo forKey:kPhoto];
    [userDefaults setObject:user.userType forKey:kUserType];
     [userDefaults setObject:user.bankCard forKey:kBankCard];
    
    [userDefaults setObject:token forKey:kToken];
}


+ (void) reomveToken{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"" forKey:kToken];
    
    [userDefaults synchronize];
}

/*add by lfh 2015-11-02 保存token*/
+ (NSString *) getToken{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:kToken];
    if (token) {return token;}
    return @"";
}


//add by lfh 2016-5-6 保存deviceToken 方便APNS推送使用
+ (void) saveDeviceToken:(NSString *)deviceToken{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:deviceToken forKey:kDeviceToken];
    
    [userDefaults synchronize];
}

+ (NSString *) getDeviceToken{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults objectForKey:kDeviceToken];
    if (token) {return token;}
    return @"";
}
@end
