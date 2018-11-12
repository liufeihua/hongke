//
//  TemplateViewCell.m
//  iosapp
//
//  Created by redmooc on 2018/11/9.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import "TemplateViewCell.h"
#import "UIImageView+WebCache.h"

@implementation TemplateViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(GFKDAd *)model{
    _model = model;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"item_default"]];
    self.label_name.text = model.name;
}

@end
