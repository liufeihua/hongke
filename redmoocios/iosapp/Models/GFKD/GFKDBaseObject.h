//
//  GFKDBaseObject.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/2.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFKDBaseObject : NSObject
- (id) initWithDict : (NSDictionary*) _entityDict;

- (NSDictionary*) dictEntity;

//服务器返回的数据
@property (nonatomic, copy) NSDictionary *dataDict;

@end
