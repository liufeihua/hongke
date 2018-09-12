//
//  GFKDBaseObject.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/2.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "GFKDBaseObject.h"
#import <objc/runtime.h>

@implementation GFKDBaseObject

- (id) initWithDict : (NSDictionary*) _entityDict
{
    self = [super init];
    
    if (self)
    {
        self.dataDict = _entityDict;//保存数据字典
        Ivar*           ivarList;
        unsigned int    ivarCount;
        
        ivarList = class_copyIvarList([self class], &ivarCount);
        
        for (int i = 0; i < ivarCount; i++)
        {
            Ivar subIvar = ivarList[i];
            
            NSString *ivarName = [[NSString stringWithUTF8String:ivar_getName(subIvar)] substringFromIndex:1];
            
            if (ivarName && [_entityDict.allKeys containsObject:ivarName])
            {
                object_setIvar(self, subIvar, _entityDict[ivarName]);
            }
        }
    }
    return self;
}

- (NSDictionary*) dictEntity
{
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    
    Ivar*           ivarList;
    unsigned int    ivarCount;
    
    ivarList = class_copyIvarList([self class], &ivarCount);
    
    for (int i = 0; i < ivarCount; i++)
    {
        Ivar subIvar = ivarList[i];
        
        NSString *ivarName = [[NSString stringWithUTF8String:ivar_getName(subIvar)] substringFromIndex:1];
        
        id objectIvar = object_getIvar(self, subIvar);
        
        if (objectIvar)
        {
            resultDict[ivarName] = object_getIvar(self, subIvar);
        }
    }
    
    return resultDict;
}

@end
