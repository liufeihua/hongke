#import "FatherTableViewCell.h"
#import <Masonry/Masonry.h>


@interface FatherTableViewCell ()


@end

@implementation FatherTableViewCell

-(void)awakeFromNib
{
     [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chickView:)]];
}
-(void)layoutSubviews
{
    [self.lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).offset(20);
    }];
    
    [self.btnOpen mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.height.equalTo(@15);
        make.width.equalTo(@15);
    }];
    
    [self.imgGold mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView.mas_right).offset(-35);
        make.height.equalTo(@20);
        make.width.equalTo(@20);
    }];
    
    [self.lblPoints mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.btnOpen).offset(-45);
    }];
    
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.bottom.equalTo(self.contentView).offset(-0.1);
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@1);
    }];
    
    [super layoutSubviews];
}
-(void)setValue:(GFKDPointsRule *)value
{
    _value= value;
    
    self.lblName.text= _value.ruleName;
    float points = [_value.isas floatValue] * [_value.points floatValue];
    if (points > 0) {
        self.lblPoints.text = [NSString stringWithFormat:@"+%.0f",points];
    }else{
        self.lblPoints.text = [NSString stringWithFormat:@"%.0f",points];
    }
    
}


- (IBAction)action:(DetailButton*)sender {
    
    _g.opened = !_g.isOpened;
    //_btnOpen.imageView.transform = _g.isOpened ? CGAffineTransformMakeRotation(M_PI_2) : CGAffineTransformMakeRotation(0);
    
    if ([_delegate respondsToSelector:@selector(clickHeadView)]) {
        [_delegate clickHeadView];
    }
}

- (void)chickView:(UITapGestureRecognizer *)tapGesture{
    _g.opened = !_g.isOpened;
    if ([_delegate respondsToSelector:@selector(clickHeadView)]) {
        [_delegate clickHeadView];
    }
}

- (void)didMoveToSuperview
{
    _btnOpen.imageView.transform = _g.isOpened ? CGAffineTransformMakeRotation(0) : CGAffineTransformMakeRotation(M_PI);
}


@end
