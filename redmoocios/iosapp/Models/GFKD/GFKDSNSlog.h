//
//  GFKDSNSlog.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/23.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"
#import <UIKit/UIKit.h>


@interface GFKDSNSlog : GFKDBaseObject

@property (nonatomic, assign) NSNumber *userId;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) NSNumber *fid;
@property (nonatomic, assign) NSNumber *type;
@property (nonatomic, strong) NSString *icon;

@property (nonatomic, assign) CGFloat cellHeight;

@end
