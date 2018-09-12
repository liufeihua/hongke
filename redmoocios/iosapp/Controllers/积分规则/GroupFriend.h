#import <Foundation/Foundation.h>
#import "GFKDPointsRule.h"

@interface GroupFriend : NSObject

@property (nonatomic,strong) GFKDPointsRule *mode;
@property (nonatomic,strong) NSArray *children;

@property (nonatomic, assign, getter = isOpened) BOOL opened;


- (instancetype)initWithMode:(GFKDPointsRule *)mode children:(NSArray *)children;

+ (instancetype)dataObjectWithMode:(GFKDPointsRule *)mode children:(NSArray *)children;
@end
