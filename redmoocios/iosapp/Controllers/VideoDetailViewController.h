//
//  VideoDetailViewController.h
//  iosapp
//
//  Created by chen yu-jiao on 15/11/25.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "GFKDObjsViewController.h"
#import "VideoDetailBarViewController.h"
#import "EditingBar.h"

@protocol RemoveViewDelegate
- (void)removeController;
- (void)fetchCommentsBVCController:(int)newsID;

@end

//@protocol videoDetailViewControllerDelegate <NSObject>
//
//@optional
//- (void)fetchCommentsBVCController:(int)newsID;
//@end


typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
    UIPanGestureRecognizerDirectionUndefined,
    UIPanGestureRecognizerDirectionUp,
    UIPanGestureRecognizerDirectionDown,
    UIPanGestureRecognizerDirectionLeft,
    UIPanGestureRecognizerDirectionRight
};


@interface VideoDetailViewController : UIViewController<UIGestureRecognizerDelegate>



@property (nonatomic, assign) id  <RemoveViewDelegate> delegate;
@property (strong, nonatomic) MPMoviePlayerController *player;

@property (weak, nonatomic) IBOutlet UIView *viewTable;

@property (weak, nonatomic) IBOutlet UILabel *label_title;

@property (weak, nonatomic) IBOutlet UILabel *label_dates;

@property (weak, nonatomic) IBOutlet UILabel *label_browers;

@property (weak, nonatomic) IBOutlet UILabel *label_author;

@property (weak, nonatomic) IBOutlet UIButton *btnDown;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnDownBottomLayout;

- (IBAction)btnDownTapAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *label_zanNum;

@property (weak, nonatomic) IBOutlet UIButton *btn_star;
@property (weak, nonatomic) IBOutlet UIButton *btn_zan;
- (IBAction)btnZanClick:(id)sender;

- (IBAction)btnStarClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewVedio;

@property (weak, nonatomic) IBOutlet UIView *viewGrowingTextView;

@property (weak, nonatomic) IBOutlet UITableView *commentView;

@property (weak, nonatomic) IBOutlet UITextField *txtViewGrowing;
- (IBAction)btnSendAction:(id)sender;


@property(nonatomic)CGRect initialFirstViewFrame;
@property(nonatomic,strong) UIPanGestureRecognizer *panRecognizer;
@property(nonatomic,strong) UITapGestureRecognizer *tapRecognizer;
-(void)removeView;

@property(nonatomic,strong) UIView *onView;

@property (nonatomic, assign) int   newsID;

//@property (nonatomic, weak) VideoDetailBarViewController *bottomBarVC;

@property (nonatomic, strong) EditingBar *editingBar;

@end
