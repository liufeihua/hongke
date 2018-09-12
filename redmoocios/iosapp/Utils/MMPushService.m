//
//  MMPushService.m
//  yuxi-manager
//
//  Created by Guo Yu on 14-8-27.
//  Copyright (c) 2014年 ylink. All rights reserved.
//

#import "MMPushService.h"

#import "MQTTKit/MQTTKit.h"

//#define kMQTTServerHost @"iot.eclipse.org"
//#define kMQTTServerHost @"192.168.1.200"
#define kMQTTServerHost @"mapi.nudt.edu.cn"
#define kTopic @"RedMoocPush"

@interface MMPushService()

@property (nonatomic, strong) MQTTClient *client;


@end

@implementation MMPushService

+ (MMPushService *)sharedService {
	static dispatch_once_t predicate = 0;
	static MMPushService *object = nil;
    
	dispatch_once(&predicate, ^{ object = [[self class] new]; });
    
	return object;
}


- (void)reconnect {
    UIApplication *application = [UIApplication sharedApplication];
    
    if (self.client) {
        //[self sendNotification:@"服务器重新连接..."];
        self.client = nil;
    }
    NSString *clientID = [[[UIDevice currentDevice]identifierForVendor]UUIDString];
    self.client = [[MQTTClient alloc] initWithClientId:clientID];
    self.client.keepAlive = 600;
    
//    [self.client setUsername:@"10000001"];
//    [self.client setPassword:@"000000"];
    
    [self.client setUsername:@"10000001"];
    [self.client setPassword:@"b36bc70cee55441f923c26ddfa988dfc"];
    
    [self.client setPort:8001];
  
    [self.client connectToHost:kMQTTServerHost completionHandler:^(MQTTConnectionReturnCode code) {
        if (code == ConnectionAccepted) {
            //[self sendNotification:@"服务器已经连接..."];
            NSLog(@"MQTT服务器已经连接...");
            // 订阅主题
//            [self.client subscribe:kTopic withCompletionHandler:nil];
            [self.client subscribe:kTopic withCompletionHandler:^(NSArray *grantedQos) {
                NSLog(@"MQTT主题 %@", kTopic);
                
                //开启后台
                BOOL res = [self.client enableBackgrounding];
                if (!res) {
                    NSLog(@"开启socket失败...");
                }
           }];
        } else {
            NSLog(@"连接服务器失败...");
        }
    }];
    
    __weak MMPushService *weakSelf = self;
    [self.client setMessageHandler:^(MQTTMessage *message) {
        NSString * newStr = [[NSString alloc] initWithData:message.payload encoding:NSUTF8StringEncoding];
        [weakSelf sendNotification:newStr];
    }];
    
    [application setKeepAliveTimeout:600 handler:^{
        //[self sendNotification:@"Timeout连接超时-重新连接..."];
        [self.client connectToHost:kMQTTServerHost completionHandler:^(MQTTConnectionReturnCode code) {
            if (code == ConnectionAccepted) {
                //[self sendNotification:@"Timeout服务器已经连接..."];
                NSLog(@"MQTT服务器已经连接...");
                // 订阅主题
                //            [self.client subscribe:kTopic withCompletionHandler:nil];
                [self.client subscribe:kTopic withCompletionHandler:^(NSArray *grantedQos) {
                    NSLog(@"MQTT主题 %@", kTopic);
                    
                    //开启后台
                    BOOL res = [self.client enableBackgrounding];
                    if (!res) {
                        NSLog(@"开启socket失败...");
                    }
                }];
            } else {
                NSLog(@"连接服务器失败...");
            }
        }];
        //[self reconnect];
    }];
    
//    [self.client disconnectWithCompletionHandler:^(NSUInteger code) {
//        [self sendNotification:@"disconnect连接已断开..."];
//        [self.client reconnect];
//    }];
}




/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
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

- (void)sendNotification:(NSString*)message {
    
    UIApplication *application = [UIApplication sharedApplication];

    //msgType 消息类型，0：Web地址跳转，1：新闻资讯类，11：类似服务号的推送消息
    //encodeType 消息编码方式，用来标示消息是明文还是加密的，0：不加密，1：RSA证书加密
    
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.repeatInterval = 0;
    NSDictionary *dict = [self dictionaryWithJsonString:message];
    if (dict == nil) {
        [notification setAlertBody:[NSString stringWithFormat:@"%@", message]];
    }else{
        [notification setAlertBody:[NSString stringWithFormat:@"%@: %@", dict[@"msgTitle"], dict[@"msgDesc"]]];
    }
    
    [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
    [notification setSoundName:UILocalNotificationDefaultSoundName];
    notification.applicationIconBadgeNumber = 0;
    [notification setUserInfo:dict];
    
    
    [application scheduleLocalNotification:notification];
    
}




@end
