#import "GroupFriend.h"


@implementation GroupFriend

- (instancetype)initWithMode:(GFKDPointsRule *)mode children:(NSArray *)children
{
    self = [super init];
    if (self) {
        self.children = [NSArray arrayWithArray:children];
        self.mode = mode;
    }
    return self;
}

+ (instancetype)dataObjectWithMode:(GFKDPointsRule *)mode children:(NSArray *)children
{
    return [[self alloc] initWithMode:mode children:children];
}
@end
