//
//  NodeBaseCell.h
//  iosapp
//
//  Created by redmooc on 2018/10/16.
//  Copyright © 2018年 redmooc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFKDTopNodes.h"
#import "EPUBParser.h"

@interface NodeBaseCell : UITableViewCell

@property(nonatomic,strong) GFKDTopNodes *node;

+ (CGFloat)heightForRow:(GFKDTopNodes *)node;
+ (NSString *)idForRow:(GFKDTopNodes *)node;

@property(nonatomic,strong) UIViewController *parentVC;

@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UILabel *label1;

@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UILabel *label4;


@property (strong, nonatomic) EPUBParser *epubParser; //epub解析器，成员变量或全局

@end
