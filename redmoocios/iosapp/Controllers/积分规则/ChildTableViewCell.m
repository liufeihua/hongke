#import "ChildTableViewCell.h"
#import <Masonry/Masonry.h>

@interface ChildTableViewCell ()


@end

@implementation ChildTableViewCell

-(void)layoutSubviews
{
    [self.lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@15);
         make.left.equalTo(self.contentView.mas_left).offset(20);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-20);
        make.left.equalTo(@20);
        make.bottom.equalTo(@-30);
        make.height.equalTo(@1);
    }];
    
    [self.imgGold mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(@-5);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.height.equalTo(@20);
        make.width.equalTo(@20);
    }];
    
    [self.lblPoints mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imgGold);
        make.right.equalTo(self.imgGold).offset(-25);
    }];
    [self.lblSubName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imgGold);
        make.right.equalTo(self.lblPoints.mas_left).offset(-5);
    }];
    [self.subLine mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@1);
    }];
    
    [super layoutSubviews];
}
-(void)setChild:(NSString *)child
{
    _child=child;
    
    self.lblName.text=_child;
}

- (void) setModel:(GFKDPointsRule *)model
{
    _model = model;
    self.lblName.text = model.caption;
    self.lblPoints.text = [NSString stringWithFormat:@"%.0f",[model.maxPoints floatValue]];
}

+ (CGFloat)heightForRow:(GFKDPointsRule *)model{
    return 80;
}

@end
