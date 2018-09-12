//
//  WebHtmlViewController.h
//  iosapp
//
//  Created by redmooc on 16/12/6.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebHtmlViewController : UIViewController

-(instancetype) initWithTitle:(NSString *)title WithUrl:(NSString *)Url;

@property (nonatomic, assign) NSString *showTitle;
@property (nonatomic, assign) NSString *url;

@end
