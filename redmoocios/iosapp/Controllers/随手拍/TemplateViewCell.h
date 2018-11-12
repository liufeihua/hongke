//
//  TemplateViewCell.h
//  iosapp
//
//  Created by redmooc on 2018/11/9.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDAd.h"

@interface TemplateViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label_name;

@property(nonatomic,strong)GFKDAd *model;

@end
