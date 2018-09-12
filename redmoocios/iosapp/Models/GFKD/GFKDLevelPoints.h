//
//  GFKDLevelPoints.h
//  iosapp
//
//  Created by redmooc on 16/8/17.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "GFKDBaseObject.h"

@interface GFKDLevelPoints : GFKDBaseObject

@property (nonatomic, assign) NSNumber *_id;//json中为“id”
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) NSNumber *minPoints;
@property (nonatomic, strong) NSString *levelName;


@end
