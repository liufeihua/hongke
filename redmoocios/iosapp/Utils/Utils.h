//
//  Utils.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "UIImageView+Util.h"
#import "UIImage+Util.h"
#import "NSTextAttachment+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"
//#import "UINavigationController+Router.h"
#import "NSDate+Util.h"
#import "NSString+Util.h"
#import "GFKDDiscover.h"
#import "GFKDHomeAd.h"


typedef NS_ENUM(NSUInteger, hudType) {
    hudTypeSendingTweet,
    hudTypeLoading,
    hudTypeCompleted
};

@class MBProgressHUD;

@interface Utils : NSObject

+ (NSDictionary *)emojiDict;
+ (NSDictionary *)emojiBaseDict;

+ (NSAttributedString *)getAppclient:(int)clientType;

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews;
+ (NSString *)generateTags:(NSArray *)tags;

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString;
+ (NSMutableAttributedString *)attributedStringFromHTML:(NSString *)HTML;
+ (NSData *)compressImage:(UIImage *)image;
+ (NSString *)convertRichTextToRawText:(UITextView *)textView;

+ (BOOL)isURL:(NSString *)string;
+ (NSInteger)networkStatus;
+ (BOOL)isNetworkExist;

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent;

+ (MBProgressHUD *)createHUD;
+ (UIImage *)createQRCodeFromString:(NSString *)string;

+ (NSAttributedString *)attributedTimeString:(NSDate *)date;
+ (NSAttributedString *)attributedCommentCount:(int)commentCount;
+ (NSAttributedString *)attributedBrowersCount:(int)browersCount;
+ (NSAttributedString *)attributedArrowRight:(NSString *)str;
+ (NSAttributedString *)attributedTimeStringFormStr:(NSString *)dateStr;
+ (NSAttributedString *)attributedDateStr:(NSString *)dateStr;
+ (NSAttributedString *)attributedBrowersCount:(int)browersCount WithFontSize:(int)fontSize;

+ (NSString *)HTMLWithData:(NSDictionary *)data usingTemplate:(NSString *)templateName;

+(NSString *)getMinImageNameWithName:(NSString *)name;
+(NSString *)getMaxImageNameWithName:(NSString *)name;

+ (void) showHttpErrorWithCode:(int)code withMessage:(NSString *)message;


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSAttributedString *)attributedRecycle:(NSString *)str;

+ (NSString *)replaceWithUrl:(NSString *)url;

+ (void) showLinkViewController:(GFKDDiscover *)model WithNowVC:(UIViewController *)VC;
+ (void) showLinkAD:(GFKDHomeAd *)adv WithNowVC:(UIViewController *)VC;

+ (void) reNewUserWithDict:(NSDictionary *)dict token:(NSString *)token;


+(CGSize)getImageSizeWithURL:(id)imageURL;


+(NSString*)getDeviceString;
+(NSString *)getIMEI;

@end
