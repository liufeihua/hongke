

#import <UIKit/UIKit.h>
/**
 *  分类按钮, 左边图片 右边标签
 */

@interface CategoryButton : UIButton

@property (nonatomic,strong) UIImageView *icon;
@property (nonatomic,strong) UILabel *categoryLb;

@end
