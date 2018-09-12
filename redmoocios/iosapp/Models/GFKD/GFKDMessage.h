//
//  GFKDMessage.h
//  iosapp
//
//  Created by redmooc on 16/12/5.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDMessage : GFKDBaseObject

@property (nonatomic, assign) NSNumber *_id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createDate;

@end
