//
//  HeadTableViewCell.m
//  iosapp
//
//  Created by redmooc on 16/10/26.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "HeadTableViewCell.h"

@implementation HeadTableViewCell


-(id)init
{
    self=[[[NSBundle mainBundle]loadNibNamed:@"HeadTableViewCell" owner:nil options:nil] firstObject];
    
    if (self) {
        
//        self.headImageView.layer.cornerRadius=5;
//        self.headImageView.layer.masksToBounds=YES;
        self.title.text=@"主题教育";
    }
    
    return self;
}
@end
