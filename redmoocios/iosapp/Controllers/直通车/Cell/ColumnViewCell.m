//
//  ColumnViewCell.m
//  DouYU
//
//  Created by Alesary on 15/11/2.
//  Copyright © 2015年 Alesary. All rights reserved.
//

#import "ColumnViewCell.h"
#import "UIImageView+WebCache.h"


@interface ColumnViewCell ()
@property (strong, nonatomic) IBOutlet UIImageView *image;

@property (strong, nonatomic) IBOutlet UILabel *title;
@end

@implementation ColumnViewCell

-(void)setContentWith:(GFKDDiscover *)model
{
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"item_default"]];
    self.image.layer.cornerRadius= 5;
    self.image.layer.masksToBounds=YES;
    
    self.title.text=model.name;
    
}
@end
