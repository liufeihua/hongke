//
//  FYMainPlayController.h
//  music
//
//

#import <UIKit/UIKit.h>
@protocol FYMainPlayControllerDelegate <NSObject>

@required
- (void)refreshList;

@end


@interface FYMainPlayController : UIViewController

@property (nonatomic, weak) id<FYMainPlayControllerDelegate> delegate;
@property (nonatomic,strong) NSString *musicTitle;
@property (nonatomic,strong) NSString *musicName;
@property (nonatomic,strong) NSString *singer;

@property (nonatomic,strong) NSURL *coverLarge;

@property(nonatomic,strong) UIViewController *parentVC;

@end
