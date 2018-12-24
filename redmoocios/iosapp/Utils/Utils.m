//
//  Utils.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "Utils.h"
#import "AppDelegate.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

#import <MBProgressHUD.h>
#import <objc/runtime.h>
#import <Reachability.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <GRMustache.h>
#import "Config.h"
#import "sys/utsname.h"

#import "CYWebViewController.h"
#import "NewsDetailBarViewController.h"
#import "NewsViewController.h"
#import "NewsImagesViewController.h"
#import "TakesViewController.h"
#import "RadioViewController.h"
#import "CatagoryNewsViewController.h"
#import "StudySchoolViewController.h"

@implementation Utils


#pragma mark - 处理API返回信息

+ (NSAttributedString *)getAppclient:(int)clientType
{
    NSMutableAttributedString *attributedClientString;
    if (clientType > 1 && clientType <= 6) {
        NSArray *clients = @[@"", @"", @"手机", @"Android", @"iPhone", @"Windows Phone", @"微信"];
        
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForEnum:FAMobile]
                                                                        attributes:@{
                                                                                     NSFontAttributeName: [UIFont fontAwesomeFontOfSize:13],
                                                                                     }];
        
        [attributedClientString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", clients[clientType]]]];
    } else {
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    return attributedClientString;
}

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews
{
    if (relativeNews == nil || [relativeNews count] == 0) {
        return @"";
    }
    
    NSString *middle = @"";
    for (NSArray *news in relativeNews) {
        middle = [NSString stringWithFormat:@"%@<a href=%@>%@</a><p/>", middle, news[1], news[0]];
    }
    return [NSString stringWithFormat:@"相关文章<div style='font-size:14px'><p/>%@</div>", middle];
}

+ (NSString *)generateTags:(NSArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    } else {
        NSString *result = @"";
        for (NSString *tag in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;", result, tag, tag];
        }
        return result;
    }
}




#pragma mark - 通用

#pragma mark - emoji Dictionary

+ (NSDictionary *)emojiDict
{
    static dispatch_once_t once;
    static NSDictionary *emojiDict;
    
    dispatch_once(&once, ^ {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"emoji" ofType:@"plist"];
        emojiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    });
    
    return emojiDict;
}

+ (NSDictionary *)emojiBaseDict
{
    static dispatch_once_t once;
    static NSDictionary *emojiDict;
    
    dispatch_once(&once, ^ {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"emojiBase" ofType:@"plist"];
        emojiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    });
    
    return emojiDict;
}

#pragma mark 信息处理

+ (NSAttributedString *)attributedTimeString:(NSDate *)date
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [date timeAgoSinceNow]];
    
    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:rawString
                                                                         attributes:@{
                                                                                      NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                      }];
    
    return attributedTime;
}

+ (NSAttributedString *)attributedTimeStringFormStr:(NSString *)dateStr
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    NSString *rawString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [date timeAgoSinceNow]];
    
    rawString = [dateStr isEqual:@""]?@"":rawString;
    
    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:rawString
                                                                         attributes:@{
                                                                                      NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                      }];
    
    
    return attributedTime;
}

// 参考 http://www.cnblogs.com/ludashi/p/3962573.html

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString
{
    NSMutableAttributedString *emojiString = [[NSMutableAttributedString alloc] initWithString:rawString];
    NSDictionary *emoji = self.emojiDict;
    
    NSString *pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]|:[a-zA-Z0-9\\u4e00-\\u9fa5_]+:";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:rawString options:0 range:NSMakeRange(0, rawString.length)];
    
    NSMutableArray *emojiArray = [NSMutableArray arrayWithCapacity:resultsArray.count];
    
    for (NSTextCheckingResult *match in resultsArray) {
        NSRange range = [match range];
        NSString *emojiName = [rawString substringWithRange:range];
        
        if ([emojiName hasPrefix:@"["] && emoji[emojiName]) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            textAttachment.image = [UIImage imageNamed:emoji[emojiName]];
            [textAttachment adjustY:-3];
            
            NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            
            [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
        } else if ([emojiName hasPrefix:@":"]) {
            if (emoji[emojiName]) {
                [emojiArray addObject:@{@"text": emoji[emojiName], @"range": [NSValue valueWithRange:range]}];
            } else {
                UIImage *emojiImage = [UIImage imageNamed:[emojiName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]];
                NSTextAttachment *textAttachment = [NSTextAttachment new];
                textAttachment.image = emojiImage;
                [textAttachment adjustY:-3];
                
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
            }
        }
    }
    
    for (NSInteger i = emojiArray.count -1; i >= 0; i--) {
        NSRange range;
        [emojiArray[i][@"range"] getValue:&range];
        if (emojiArray[i][@"image"]) {
            [emojiString replaceCharactersInRange:range withAttributedString:emojiArray[i][@"image"]];
        } else {
            [emojiString replaceCharactersInRange:range withString:emojiArray[i][@"text"]];
        }
    }
    
    return emojiString;
}

+ (NSMutableAttributedString *)attributedStringFromHTML:(NSString *)HTML
{
    return [[NSMutableAttributedString alloc] initWithData:[HTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                   options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                        documentAttributes:nil
                                                     error:nil];
}

+ (NSString *)convertRichTextToRawText:(UITextView *)textView
{
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
                                                    if (!attachment) {return;}
                                        
                                                    NSString *emojiStr = objc_getAssociatedObject(attachment, @"emoji");
                                                    [rawText insertString:emojiStr atIndex:range.location];
                                                }];
    
    NSString *pattern = @"[\ue000-\uf8ff]|[\\x{1f300}-\\x{1f7ff}]|\\x{263A}\\x{FE0F}|☺";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emojiToText" ofType:@"plist"];
    NSDictionary *emojiToText = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        NSString *emoji = [textView.text substringWithRange:match.range];
        [rawText replaceCharactersInRange:match.range withString:emojiToText[emoji]];
    }
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSData *)compressImage:(UIImage *)image
{
    CGSize size = [self scaleSize:image.size];
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger maxFileSize = 500 * 1024;
    CGFloat compressionRatio = 0.7f;
    CGFloat maxCompressionRatio = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
    
    while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
        compressionRatio -= 0.1f;
        imageData = UIImageJPEGRepresentation(image, compressionRatio);
    }
    
    return imageData;
}

+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    } else {
        return CGSizeMake(800 * width / height, 800);
    }
}


+ (BOOL)isURL:(NSString *)string
{
    NSString *pattern = @"^(http|https)://.*?$(net|com|.com.cn|org|me|)";
    
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    
    return [urlPredicate evaluateWithObject:string];
}


+ (NSInteger)networkStatus
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.oschina.net"];
    return reachability.currentReachabilityStatus;
}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] > 0;
}


#pragma mark UI处理

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent
{
    return min + (max - min) * percent;
}

+ (MBProgressHUD *)createHUD
{
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:window];
    HUD.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
    [window addSubview:HUD];
    [HUD show:YES];
    HUD.removeFromSuperViewOnHide = YES;
    //[HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
    
    return HUD;
}

+ (UIImage *)createQRCodeFromString:(NSString *)string
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [QRFilter setValue:stringData forKey:@"inputMessage"];
    [QRFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CGFloat scale = 5;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:QRFilter.outputImage fromRect:QRFilter.outputImage.extent];
    
    //Scale the image usign CoreGraphics
    CGFloat width = QRFilter.outputImage.extent.size.width * scale;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return image;
}

+ (NSAttributedString *)attributedCommentCount:(int)commentCount
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FACommentO], commentCount];
    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                              }];
    
    return attributedCommentCount;
}

+ (NSAttributedString *)attributedBrowersCount:(int)browersCount
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FAEye], browersCount];
    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:10],
                                                                                              }];
    
    return attributedCommentCount;
}

+ (NSAttributedString *)attributedBrowersCount:(int)browersCount WithFontSize:(int)fontSize
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FAEye], browersCount];
    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:fontSize],
                                                                                              }];
    
    return attributedCommentCount;
}

+ (NSAttributedString *)attributedDateStr:(NSString *)dateStr
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], dateStr];//
    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:14],
                                                                                              }];
    
    return attributedCommentCount;
}

+ (NSAttributedString *)attributedArrowRight:(NSString *)str
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %@",  str,[NSString fontAwesomeIconStringForEnum:FAAngleRight]];
    
    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:14],
                                                                                            
                                                                                              }];
    return attributedCommentCount;
}


+ (NSString *)HTMLWithData:(NSDictionary *)data usingTemplate:(NSString *)templateName
{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html" inDirectory:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *mutableData = [data mutableCopy];
    [mutableData setObject:@(((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode)
                    forKey:@"night"];
    
    return [GRMustacheTemplate renderObject:mutableData fromString:template error:nil];
}

+(NSString *)getMinImageNameWithName:(NSString *)name
{
    NSRange rang = [name rangeOfString:@"." options:NSBackwardsSearch];
    if (rang.location != NSNotFound) {
        NSString *str = [name stringByReplacingCharactersInRange:rang withString:@"_min."];
        return str;
    }else{
        return name;
    }
   
}


+(NSString *)getMaxImageNameWithName:(NSString *)name{
    NSRange rang = [name rangeOfString:@"_min." options:NSBackwardsSearch];
    if (rang.location != NSNotFound) {
        NSString *str = [name stringByReplacingCharactersInRange:rang withString:@"."];
        return str;
    }else{
        return name;
    }
}

//显示错误信息
+ (void) showHttpErrorWithCode:(int)code withMessage:(NSString *)message{
    if (code == 1) {//token失效
        [((AppDelegate*)[UIApplication sharedApplication].delegate) showLoginViewController];
    }else{
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
        HUD.labelText = [NSString stringWithFormat:@"错误：%@", message];
        [HUD hide:YES afterDelay:1];
    }
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


+ (NSAttributedString *)attributedRecycle:(NSString *)str{
    NSString *rawString = [NSString stringWithFormat:@"%@ %@",  str,[NSString fontAwesomeIconStringForEnum:FAtrash]];
    
    NSAttributedString *attributedRecycle = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:14],
                                                                                              
                                                                                              }];
    return attributedRecycle;
}

+ (NSString *)replaceWithUrl:(NSString *)url{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *newUrl  = [[[[url
                          stringByReplacingOccurrencesOfString:@"<token>" withString:[Config getToken]]
                         stringByReplacingOccurrencesOfString:@"<deviceType>" withString:[self getDeviceString]]
                         stringByReplacingOccurrencesOfString:@"<appVersion>" withString:version]
                         //stringByReplacingOccurrencesOfString:@"<IMEI>" withString:[Config getDeviceToken]] ;
                         stringByReplacingOccurrencesOfString:@"<IMEI>" withString:[self getIMEI]] ;
    
   
    return newUrl;
}

+(NSString *)getIMEI{
    NSString *deviceID;
#if TARGET_IPHONE_SIMULATOR
    deviceID = @"7C8A8F5B-E5F4-4797-8758-05367D2A4D61";
    NSLog(@"device id:%@", @"7C8A8F5B-E5F4-4797-8758-05367D2A4D61");
#else
    deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"device id:%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
#endif
    return deviceID;
}

+(NSString*)getDeviceString
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone4(GSM)";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone4(GSMRevA)";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone4(CDMA)";
    if ([deviceString isEqualToString:@"iPhone4,2"])    return @"iPhone4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone5(GSM)";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone5(GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone5c(GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone5c(Global)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iphone5s(GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iphone5s(Global)";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone6";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone6Plus";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone6sPlus";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone7Plus";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPodTouch1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPodTouch2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPodTouch3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPodTouch4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad2(WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad2(GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad2(CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}

+ (void) showLinkAD:(GFKDHomeAd *)adv WithNowVC:(UIViewController *)VC{
    NSString *title_1 = @"功能开发过程中,敬请期待!";
    if ((NSNull *)adv.url == [NSNull null] || [adv.url isEqualToString:@""]){
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = title_1;
        [HUD hide:YES afterDelay:1];
        return;
    }
    if ([adv.linkType intValue] == 1)//网站链接
    {
        NSString *newUrl = [Utils replaceWithUrl:adv.url];
        CYWebViewController *webViewController = [[CYWebViewController alloc] initWithURL:[NSURL URLWithString:newUrl]];
        webViewController.hidesBottomBarWhenPushed = YES;
        webViewController.navigationButtonsHidden = YES;
        webViewController.loadingBarTintColor = [UIColor redColor];
        [VC.navigationController pushViewController:webViewController animated:YES];
    }else if ([adv.linkType intValue] == 2)  //文章链接
    {
        NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[adv.url intValue]];
        newsDetailVC.hidesBottomBarWhenPushed = YES;
        [VC.navigationController pushViewController:newsDetailVC animated:YES];
    }else if ([adv.linkType intValue] == 3)  //跳转到专题页面 3
    {
        NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[adv.url intValue] isSpecial:1];
        specalViewController.hidesBottomBarWhenPushed = YES;
        specalViewController.title = @"专题";
        [VC.navigationController pushViewController:specalViewController animated:YES];
    } else if ([adv.linkType intValue] == 4)  // 跳转到多图 4
    {
        NewsImagesViewController *vc = [[NewsImagesViewController alloc] initWithNibName:@"NewsImagesViewController"   bundle:nil];
        vc.hidesBottomBarWhenPushed = YES;
        vc.newsID = [adv.url intValue];
        vc.parentVC = VC;
        [VC presentViewController:vc animated:YES completion:nil];
    }else if ([adv.linkType intValue] == 6)  // 跳转到栏目 6
    {
        //
        int nodeId = [adv.url intValue];
        [self showNodeOrNewsWithId:nodeId withTitle:adv.advTitle WithNowVC:VC];
    }
}


+ (void) showNodeOrNewsWithId:(int) nodeId withTitle:(NSString *)title WithNowVC:(UIViewController *)VC{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX,GFKDAPI_NODELIST]
      parameters:@{@"token":[Config getToken],
                   @"parentId":@(nodeId)}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
             }
             
             NSArray *array = responseObject[@"result"][@"data"];
             if (array.count == 0) {
                 NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:nodeId isSpecial:0];
                 specalViewController.title = title;
                 specalViewController.hidesBottomBarWhenPushed = YES;
                 [VC.navigationController pushViewController:specalViewController animated:YES];
             }else{
                 StudySchoolViewController *studuSchoolVC = [[StudySchoolViewController alloc] initWithParentId:[NSNumber numberWithInt:nodeId] WithNav:NO];
                 studuSchoolVC.title = title;
                 studuSchoolVC.hidesBottomBarWhenPushed = YES;
                 [VC.navigationController pushViewController:studuSchoolVC animated:YES];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
//    if ([topNodes.terminated intValue] == 1){ //没有子栏目了
//        [controllers addObject:[[NewsBarViewController alloc]  initWithNewsListType:NewsListTypeNews cateId:[topNodes.cateId intValue] isSpecial:0]];
//    }else{
//        [controllers addObject: [[StudySchoolViewController alloc] initWithParentId:topNodes.cateId]];
//    }
}

+ (void) showLinkViewController:(GFKDDiscover *)model WithNowVC:(UIViewController *)VC{
    NSString *title_1 = @"功能开发过程中,敬请期待!";
    NSString *title_2 = @"您需要登录后,才能查看全部信息!";
    GFKDUser *user = [Config getMyInfo];
    if ([model.enabled intValue] != 1) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = title_1;
        [HUD hide:YES afterDelay:1];
        return;
    }
    if (([user.userType intValue] < 10) && ([model.range intValue] == 1)) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = title_2;
        [HUD hide:YES afterDelay:1];
        return;
    }
    switch ([model.linkType intValue])
    {
        case 1://站内栏目
        {
            if ((NSNull *)model.url == [NSNull null] || [model.url isEqualToString:@""]){
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = title_1;
                [HUD hide:YES afterDelay:1];
                return;
            }
            NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[model.url intValue] isSpecial:0];
            specalViewController.title = model.name;
            specalViewController.hidesBottomBarWhenPushed = YES;
            [VC.navigationController pushViewController:specalViewController animated:YES];
        }
            break;
        case 2: //站内文章
        {
            if ((NSNull *)model.url == [NSNull null] || [model.url isEqualToString:@""]){
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = title_1;
                [HUD hide:YES afterDelay:1];
                return;
            }
            NewsDetailBarViewController *newsDetailVC = [[NewsDetailBarViewController alloc] initWithNewsID:[model.url intValue]];
            [VC.navigationController pushViewController:newsDetailVC animated:YES];
            
        }
            break;
        case 3://站外文章
        {
            if ((NSNull *)model.url == [NSNull null] || [model.url isEqualToString:@""]){
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = title_1;
                [HUD hide:YES afterDelay:1];
                return;
            }
            NSString *newUrl = [Utils replaceWithUrl:model.url];
            
            CYWebViewController *controller = [[CYWebViewController alloc] init];
            controller.url = [NSURL URLWithString:newUrl];
            controller.hidesBottomBarWhenPushed = YES;
            controller.loadingBarTintColor = [UIColor redColor];
            [VC.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 4://跳蚤市场
        {
            TakesViewController *takeVC = [[TakesViewController alloc] initWithTakesListType:TakesListTypeALL withInfoType:TakesInfoTypeMarket];
            takeVC.hidesBottomBarWhenPushed = YES;
            takeVC.title = @"跳蚤市场";
            [VC.navigationController pushViewController:takeVC animated:YES];
        }
            break;
        case 5: //电子书
        {
            if ((NSNull *)model.url == [NSNull null] || [model.url isEqualToString:@""]){
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = title_1;
                [HUD hide:YES afterDelay:1];
                return;
            }
            //== 站内栏目
            NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[model.url intValue] isSpecial:0];
            specalViewController.title = model.name;
            specalViewController.hidesBottomBarWhenPushed = YES;
            [VC.navigationController pushViewController:specalViewController animated:YES];
        }
            break;
        case 6://随手拍
        {
            TakesViewController *takeVC = [[TakesViewController alloc] initWithTakesListType:TakesListTypeALL withInfoType:TakesInfoTypeTake];
            takeVC.hidesBottomBarWhenPushed = YES;
            takeVC.title = @"随手拍";
            [VC.navigationController pushViewController:takeVC animated:YES];
        }
            break;
        case 7://专题
        {
            if ((NSNull *)model.url == [NSNull null] || [model.url isEqualToString:@""]){
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = title_1;
                [HUD hide:YES afterDelay:1];
                return;
            }
            NewsViewController *specalViewController  = [[NewsViewController alloc] initWithNewsListType:NewsListTypeNews cateId:[model.url intValue] isSpecial:1];
            specalViewController.title = model.name;//@"专题";
            specalViewController.hidesBottomBarWhenPushed = YES;
            [VC.navigationController pushViewController:specalViewController animated:YES];
        }
            break;
        case 8://电台
        {
            if ((NSNull *)model.url == [NSNull null] || [model.url isEqualToString:@""]){
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = title_1;
                [HUD hide:YES afterDelay:1];
                return;
            }
            RadioViewController *radioVC = [[RadioViewController alloc] initWithFrameHeight:VC.view.bounds.size.height withNumber:model.url];
            radioVC.hidesBottomBarWhenPushed = YES;
            radioVC.title = model.name;
            [VC.navigationController pushViewController:radioVC animated:YES];
        }
            break;
        case 9://多栏目
        {
            if ((NSNull *)model.url == [NSNull null] || [model.url isEqualToString:@""]){
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = title_1;
                [HUD hide:YES afterDelay:1];
                return;
            }
            CatagoryNewsViewController *catagoryViewController  = [[CatagoryNewsViewController alloc] initWithNumber:model.url];
            catagoryViewController.title = model.name;
            catagoryViewController.hidesBottomBarWhenPushed = YES;
            [VC.navigationController pushViewController:catagoryViewController animated:YES];
        }
            break;
        default:
        {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = title_1;
            [HUD hide:YES afterDelay:1];
            break;
        }
    }
}


+ (void) reNewUserWithDict:(NSDictionary *)dict token:(NSString *)token
{
    GFKDUser *user = [[GFKDUser alloc] initWithDict:dict];
    [Config saveUser:user token:token];
    [self saveCookies];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
    [((AppDelegate*)[UIApplication sharedApplication].delegate) showMainViewController];
}

+ (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
    
}

// 根据图片url获取图片尺寸
+ (CGSize)getImageSizeWithURL:(id)imageURL
{
    NSURL* URL = nil;
    if([imageURL isKindOfClass:[NSURL class]]){
        URL = imageURL;
    }
    if([imageURL isKindOfClass:[NSString class]]){
        URL = [NSURL URLWithString:imageURL];
    }
    if(URL == nil)
        return CGSizeZero;                  // url不正确返回CGSizeZero
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString* pathExtendsion = [URL.pathExtension lowercaseString];
    
    CGSize size = CGSizeZero;
    if([pathExtendsion isEqualToString:@"png"]){
        size =  [self getPNGImageSizeWithRequest:request];
    }
    else if([pathExtendsion isEqual:@"gif"])
    {
        size =  [self getGIFImageSizeWithRequest:request];
    }
    else{
        size = [self getJPGImageSizeWithRequest:request];
    }
    if(CGSizeEqualToSize(CGSizeZero, size))                    // 如果获取文件头信息失败,发送异步请求请求原图
    {
        NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
        UIImage* image = [UIImage imageWithData:data];
        if(image)
        {
            size = image.size;
        }
    }
    return size;
}
//  获取PNG图片的大小
+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取gif图片的大小
+(CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取jpg图片的大小
+(CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}


#pragma mark 检验银行卡
+ (BOOL) checkCardNo:(NSString*) cardNo {
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[cardNo length];
    int lastNum = [[cardNo substringFromIndex:cardNoLength-1] intValue];
    
    cardNo = [cardNo substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}

#pragma mark 检验是否为工商银行
+ (BOOL)checkGSWithBanknumber:(NSString *)banknumber{
    NSString *bankNumber = [banknumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary *dic;
    NSString *bank = @"";
    NSString *bankname;
    bank = [bankNumber substringToIndex:6];
    if (!dic) {
        dic = @{
                 @"402791":@"工商银行",@"427028":@"工商银行",@"427038":@"工商银行",@"548259":@"工商银行",@"620200":@"工商银行",@"620302":@"工商银行",@"620402":@"工商银行",@"620403":@"工商银行",@"620404":@"工商银行",@"620405":@"工商银行",@"620406":@"工商银行",@"620407":@"工商银行",@"620408":@"工商银行",@"620409":@"工商银行",@"620410":@"工商银行",@"620411":@"工商银行",@"620412":@"工商银行",@"620502":@"工商银行",@"620503":@"工商银行",@"620512":@"工商银行",@"620602":@"工商银行",@"620604":@"工商银行",@"620607":@"工商银行",@"620609":@"工商银行",@"620611":@"工商银行",@"620612":@"工商银行",@"620704":@"工商银行",@"620706":@"工商银行",@"620707":@"工商银行",@"620708":@"工商银行",@"620709":@"工商银行",@"620710":@"工商银行",@"620711":@"工商银行",@"620712":@"工商银行",@"620713":@"工商银行",@"620714":@"工商银行",@"620802":@"工商银行",@"620904":@"工商银行",@"620905":@"工商银行",@"621101":@"工商银行",@"621102":@"工商银行",@"621103":@"工商银行",@"621105":@"工商银行",@"621106":@"工商银行",@"621107":@"工商银行",@"621202":@"工商银行",@"621203":@"工商银行",@"621204":@"工商银行",@"621205":@"工商银行",@"621206":@"工商银行",@"621207":@"工商银行",@"621208":@"工商银行",@"621209":@"工商银行",@"621210":@"工商银行",@"621211":@"工商银行",@"621302":@"工商银行",@"621303":@"工商银行",@"621304":@"工商银行",@"621305":@"工商银行",@"621306":@"工商银行",@"621307":@"工商银行",@"621308":@"工商银行",@"621309":@"工商银行",@"621311":@"工商银行",@"621313":@"工商银行",@"621315":@"工商银行",@"621317":@"工商银行",@"621402":@"工商银行",@"621404":@"工商银行",@"621405":@"工商银行",@"621406":@"工商银行",@"621407":@"工商银行",@"621408":@"工商银行",@"621409":@"工商银行",@"621410":@"工商银行",@"621502":@"工商银行",@"621511":@"工商银行",@"621602":@"工商银行",@"621603":@"工商银行",@"621604":@"工商银行",@"621605":@"工商银行",@"621606":@"工商银行",@"621607":@"工商银行",@"621608":@"工商银行",@"621609":@"工商银行",@"621610":@"工商银行",@"621611":@"工商银行",@"621612":@"工商银行",@"621613":@"工商银行",@"621614":@"工商银行",@"621615":@"工商银行",@"621616":@"工商银行",@"621617":@"工商银行",@"621804":@"工商银行",@"621807":@"工商银行",@"621813":@"工商银行",@"621814":@"工商银行",@"621817":@"工商银行",@"621901":@"工商银行",@"621903":@"工商银行",@"621904":@"工商银行",@"621905":@"工商银行",@"621906":@"工商银行",@"621907":@"工商银行",@"621908":@"工商银行",@"621909":@"工商银行",@"621910":@"工商银行",@"621911":@"工商银行",@"621912":@"工商银行",@"621913":@"工商银行",@"621914":@"工商银行",@"621915":@"工商银行",@"622002":@"工商银行",@"622003":@"工商银行",@"622004":@"工商银行",@"622005":@"工商银行",@"622006":@"工商银行",@"622007":@"工商银行",@"622008":@"工商银行",@"622009":@"工商银行",@"622010":@"工商银行",@"622011":@"工商银行",@"622012":@"工商银行",@"622013":@"工商银行",@"622014":@"工商银行",@"622015":@"工商银行",@"622016":@"工商银行",@"622017":@"工商银行",@"622018":@"工商银行",@"622019":@"工商银行",@"622020":@"工商银行",@"622102":@"工商银行",@"622103":@"工商银行",@"622104":@"工商银行",@"622105":@"工商银行",@"622110":@"工商银行",@"622111":@"工商银行",@"622114":@"工商银行",@"622302":@"工商银行",@"622303":@"工商银行",@"622304":@"工商银行",@"622305":@"工商银行",@"622306":@"工商银行",@"622307":@"工商银行",@"622308":@"工商银行",@"622309":@"工商银行",@"622313":@"工商银行",@"622314":@"工商银行",@"622315":@"工商银行",@"622317":@"工商银行",@"622402":@"工商银行",@"622403":@"工商银行",@"622404":@"工商银行",@"622502":@"工商银行",@"622504":@"工商银行",@"622505":@"工商银行",@"622509":@"工商银行",@"622510":@"工商银行",@"622513":@"工商银行",@"622517":@"工商银行",@"622604":@"工商银行",@"622605":@"工商银行",@"622606":@"工商银行",@"622703":@"工商银行",@"622706":@"工商银行",@"622715":@"工商银行",@"622806":@"工商银行",@"622902":@"工商银行",@"622903":@"工商银行",@"622904":@"工商银行",@"623002":@"工商银行",@"623006":@"工商银行",@"623008":@"工商银行",@"623011":@"工商银行",@"623012":@"工商银行",@"623014":@"工商银行",@"623015":@"工商银行",@"623100":@"工商银行",@"623202":@"工商银行",@"623301":@"工商银行",@"623400":@"工商银行",@"623500":@"工商银行",@"623602":@"工商银行",@"623700":@"工商银行",@"623803":@"工商银行",@"623901":@"工商银行",@"624000":@"工商银行",@"624100":@"工商银行",@"624200":@"工商银行",@"624301":@"工商银行",@"624402":@"工商银行",@"620058":@"工商银行",@"620516":@"工商银行",@"621225":@"工商银行",@"621226":@"工商银行",@"621227":@"工商银行",@"621281":@"工商银行",@"621288":@"工商银行",@"621721":@"工商银行",@"621722":@"工商银行",@"621723":@"工商银行",@"622200":@"工商银行",@"622202":@"工商银行",@"622203":@"工商银行",@"622208":@"工商银行",@"900000":@"工商银行",@"900010":@"工商银行",@"620086":@"工商银行",@"621558":@"工商银行",@"621559":@"工商银行",@"621618":@"工商银行",@"621670":@"工商银行",@"623062":@"工商银行"};
        
    }
    for (NSString *s in [dic allKeys]) {
        if ([bank isEqualToString:s]) {
            bankname = dic[s];
            NSLog(@"bankname%@",bankname);
            return YES;
        }
    }
    return NO;
}


//这里写了一个方法传入需要的透明度和图片
+ (UIImage *)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}




@end
