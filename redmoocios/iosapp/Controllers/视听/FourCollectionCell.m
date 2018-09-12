//
//  FourCollectionCell.m
//  DouYU
//
//  Created by admin on 15/11/1.
//  Copyright © 2015年 Alesary. All rights reserved.
//

#import "FourCollectionCell.h"
#import "UIImageView+WebCache.h"

@interface FourCollectionCell ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;


@property (weak, nonatomic) IBOutlet UILabel *label_descript;
@property (weak, nonatomic) IBOutlet UIButton *btn_description;

@end

@implementation FourCollectionCell

- (void) setModel:(GFKDTopNodes *)model{
    [self.imageView sd_setImageWithURL:model.smallImage placeholderImage:[UIImage imageNamed:@"item_default"]];
    [self.btn_description setTitle:model.dataDict[@"description"] forState:UIControlStateNormal];
    self.btn_description.layer.borderColor = [UIColor whiteColor].CGColor;//边框颜色,要为CGColor
    self.btn_description.layer.borderWidth = 1;
   
    self.label_descript.text = model.cateName;
}


@end
