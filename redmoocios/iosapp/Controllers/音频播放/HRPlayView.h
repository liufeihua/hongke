//
//  HRPlayView.h
//  
//

#import <UIKit/UIKit.h>

@protocol PlayViewDelegate <NSObject>
// 传入按钮的selected属性
- (void)playButtonDidClick:(BOOL)selected;
@end


@interface HRPlayView : UIView
@property (nonatomic,strong) UIImageView *circleIV;
@property (nonatomic,strong) UIImageView *contentIV;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,weak) id<PlayViewDelegate> delegate;

- (void) setPlayButtonView;
- (void) setPauseButtonView;

@end
