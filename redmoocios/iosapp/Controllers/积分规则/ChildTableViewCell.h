#import <UIKit/UIKit.h>
#import "GFKDPointsRule.h"

static NSString  *kChildTableViewCell=@"ChildTableViewCell";

@interface ChildTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UILabel *lblSubName;
@property (weak, nonatomic) IBOutlet UILabel *lblPoints;
@property (weak, nonatomic) IBOutlet UIImageView *imgGold;

@property (weak, nonatomic) IBOutlet UIView *subLine;
@property (nonatomic,copy)GFKDPointsRule *model;

@property (nonatomic,copy)NSString *child;

+ (CGFloat)heightForRow:(GFKDPointsRule *)model;
@end
