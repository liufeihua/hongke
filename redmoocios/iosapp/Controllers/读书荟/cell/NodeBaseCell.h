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

@protocol NodeBaseCellDelegate <NSObject>

- (void) NodeChick:(NSInteger)tag withNode:(GFKDTopNodes*)node;

@end

@interface NodeBaseCell : UITableViewCell

@property (nonatomic, weak) id<NodeBaseCellDelegate> delegate;

@property (nonatomic, assign) int indexTag;
@property(nonatomic,strong) GFKDTopNodes *node;

@property (nonatomic, assign) BOOL showRadioPlay;

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
@property (weak, nonatomic) IBOutlet UIImageView *image5;
@property (weak, nonatomic) IBOutlet UILabel *label5;

@property (weak, nonatomic) IBOutlet UILabel *label_subTitle_1;
@property (weak, nonatomic) IBOutlet UILabel *label_subTitle_2;
@property (weak, nonatomic) IBOutlet UILabel *label_subTitle_3;
@property (weak, nonatomic) IBOutlet UILabel *label_subTitle_4;
@property (weak, nonatomic) IBOutlet UILabel *label_subTitle_5;


@property (weak, nonatomic) IBOutlet UILabel *label_author_1;

@property (weak, nonatomic) IBOutlet UILabel *label_author_2;
@property (weak, nonatomic) IBOutlet UILabel *label_author_3;
@property (weak, nonatomic) IBOutlet UILabel *label_author_4;
@property (weak, nonatomic) IBOutlet UILabel *label_author_5;

@property (weak, nonatomic) IBOutlet UILabel *label_job_1;
@property (strong, nonatomic) EPUBParser *epubParser; //epub解析器，成员变量或全局

@property (weak, nonatomic) IBOutlet UIView *view_dotted_1;
@property (weak, nonatomic) IBOutlet UIView *view_dotted_2;
@property (weak, nonatomic) IBOutlet UIView *view_dotted_3;

@property (weak, nonatomic) IBOutlet UIView *view_selected_1;
@property (weak, nonatomic) IBOutlet UIView *view_selected_2;
@property (weak, nonatomic) IBOutlet UIView *view_selected_3;
@property (weak, nonatomic) IBOutlet UIView *view_selected_4;

@property (weak, nonatomic) IBOutlet UIView *carouselView;


@end
