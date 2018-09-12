#import <UIKit/UIKit.h>
#import "GroupFriend.h"
#import "DetailButton.h"
#import "GFKDPointsRule.h"

static NSString  *kFatherTableViewCell=@"FatherTableViewCell";

@protocol HeadViewDelegate <NSObject>

@optional
- (void)clickHeadView;

@end

@interface FatherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *lblPoints;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet DetailButton *btnOpen;
@property (weak, nonatomic) IBOutlet UIImageView *imgGold;


@property (nonatomic,copy)GFKDPointsRule *value;
@property (nonatomic,strong)GroupFriend *g;

@property (nonatomic, weak) id<HeadViewDelegate> delegate;

@end
