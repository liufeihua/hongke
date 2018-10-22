//
//  CALayer+MZXibConfig.m
//  iosapp
//
//  Created by redmooc on 2018/10/18.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "CALayer+MZXibConfig.h"

@implementation CALayer (MZXibConfig)

- (void)setBorderColorWithUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

-(void)setShadowColorWithUIColor:(UIColor *)color

{
    self.shadowColor = color.CGColor;
    
}



@end
