//
//  VideoDetailViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/11/25.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "CommentCell.h"
#import "Config.h"
#import "GFKDNewsComment.h"
#import "Utils.h"
#import <MBProgressHUD.h>
#import "GFKDNewsDetail.h"
#import "CommentsBottomBarViewController.h"
#import "IQKeyboardManager.h"



@interface VideoDetailViewController ()
//@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) GFKDNewsDetail *newsDetailObj;
@property (nonatomic, strong) NSMutableArray *commmentOjbs;
//@property (nonatomic, strong) CommentsViewController *commentVC;
@end

@implementation VideoDetailViewController
{
    //local Frame store
    CGRect youtubeFrame;
    CGRect tblFrame;
    CGRect menuFrame;
    CGRect viewFrame;
    CGRect minimizedYouTubeFrame;
    CGRect growingTextViewFrame;;
    
    //local touch location
    CGFloat _touchPositionInHeaderY;
    CGFloat _touchPositionInHeaderX;
    
    //local restriction Offset--- for checking out of bound
    float restrictOffset,restrictTrueOffset,restictYaxis;
    
    //detecting Pan gesture Direction
    UIPanGestureRecognizerDirection direction;
    
    
    //Creating a transparent Black layer view
    UIView *transaparentVw;
    
    //Just to Check wether view  is expanded or not
    BOOL isExpandedMode;
    
    
     BOOL _wasKeyboardManagerEnabled; //系统IQKeyboardManager不可用
    
}
@synthesize player;

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _wasKeyboardManagerEnabled = [[IQKeyboardManager sharedManager] isEnabled];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:_wasKeyboardManagerEnabled];
}

//读取最新三条评论
- (void) getComment{
    self.view.backgroundColor = [UIColor themeColor];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?articleId=%d&pageNumber=1&pageSize=3&token=%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_NEWS_COMMENT,_newsID,[Config getToken]]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 return;
                 
             }
             NSArray *objectsDICT = responseObject[@"result"];
             self.commmentOjbs = [NSMutableArray new];
             for (NSDictionary *objectDict in objectsDICT) {
                 GFKDNewsComment *obj = [[GFKDNewsComment alloc] initWithDict:objectDict];
                 [_commmentOjbs addObject:obj];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.commentView reloadData];
             });
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}


- (void) getArticle{
    self.view.backgroundColor = [UIColor themeColor];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@?articleId=%d&token=%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_DETAIL,_newsID,[Config getToken]]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             _newsDetailObj = [[GFKDNewsDetail alloc] initWithDict:responseObject[@"result"]];
             self.label_title.text = _newsDetailObj.title;
             self.label_author.text = [NSString stringWithFormat:@"发布者:%@",_newsDetailObj.author];
             [self.label_dates setAttributedText:[Utils attributedTimeStringFormStr:_newsDetailObj.dates]];
             [self.label_browers setAttributedText:[Utils attributedBrowersCount:[_newsDetailObj.browsers intValue]]];
             
             if ([_newsDetailObj.collected intValue] == 1) {
                 [_btn_star setImage:[UIImage imageNamed:@"toolbar-star-selected"] forState:UIControlStateNormal];
             } else {
                 [_btn_star setImage:[UIImage imageNamed:@"toolbar-star"] forState:UIControlStateNormal];
             }
             
             
             if ([_newsDetailObj.digged intValue] == 1) {
                 [_btn_zan setImage:[UIImage imageNamed:@"toolbar-zan-selected"] forState:UIControlStateNormal];
             } else {
                 [_btn_zan setImage:[UIImage imageNamed:@"toolbar-zan"] forState:UIControlStateNormal];
             }
             
             _label_zanNum.text = [_newsDetailObj.diggs intValue]>0?[_newsDetailObj.diggs stringValue ]:@"";
             _label_zanNum.hidden = [_newsDetailObj.diggs intValue]>0?NO:YES;
             
             [self performSelector:@selector(addVideo) withObject:nil afterDelay:0.8];
  
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // [[BSUtils sharedInstance] showLoadingMode:self];
    
    [self getArticle];//添加文章
    //adding demo Video -- giving a little delay to store correct frame size
    
    
    //adding Pan Gesture
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    pan.delegate=self;
    [self.viewVedio addGestureRecognizer:pan];
    //setting view to Expanded state
    isExpandedMode=TRUE;
    
    self.btnDown.hidden=TRUE;
    
}

#pragma mark- Status Bar Hidden function

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
    
}
- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark- Add Video on View
-(void)addVideo
{
    
    //NSURL *urlString = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"]];
    NSURL *urlString = [NSURL URLWithString:_newsDetailObj.video];
    player  = [[MPMoviePlayerController alloc] initWithContentURL:urlString];
    
    [player.view setFrame:self.viewVedio.frame];
    player.controlStyle =  MPMovieControlStyleNone;
    player.shouldAutoplay=YES;
    player.repeatMode = NO;
    player.scalingMode = MPMovieScalingModeAspectFit;
    
    [self.viewVedio addSubview:player.view];
    [player prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [self calculateFrames];
    
    [self getComment];
    
}
#pragma mark- Calculate Frames and Store Frame Size
-(void)calculateFrames
{
    youtubeFrame=self.viewVedio.frame;
    tblFrame=self.viewTable.frame;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    self.viewVedio.translatesAutoresizingMaskIntoConstraints = YES;
    self.viewTable.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame=self.viewGrowingTextView.frame;
    growingTextViewFrame=self.viewGrowingTextView.frame;
    self.viewGrowingTextView.translatesAutoresizingMaskIntoConstraints = YES;
    self.viewGrowingTextView.frame=frame;
    frame=self.txtViewGrowing.frame;
    self.txtViewGrowing.translatesAutoresizingMaskIntoConstraints = YES;
    self.txtViewGrowing.frame=frame;
    
    self.viewVedio.frame=youtubeFrame;
    self.viewTable.frame=tblFrame;
    menuFrame=self.viewTable.frame;
    viewFrame=self.viewVedio.frame;
    self.player.view.backgroundColor=self.viewVedio.backgroundColor=[UIColor clearColor];
    //self.player.view.layer.shouldRasterize=YES;
    // self.viewYouTube.layer.shouldRasterize=YES;
    //self.viewTable.layer.shouldRasterize=YES;
    
    restrictOffset=self.initialFirstViewFrame.size.width-200;
    restrictTrueOffset = self.initialFirstViewFrame.size.height - 180;
    restictYaxis=self.initialFirstViewFrame.size.height-self.viewVedio.frame.size.height;
    
    //[[BSUtils sharedInstance] hideLoadingMode:self];
    self.view.hidden=TRUE;
    transaparentVw=[[UIView alloc]initWithFrame:self.initialFirstViewFrame];
    transaparentVw.backgroundColor=[UIColor blackColor];
    transaparentVw.alpha=0.9;
    [self.onView addSubview:transaparentVw];
    
    [self.onView addSubview:self.viewTable];
    [self.onView addSubview:self.viewVedio];
    [self stGrowingTextViewProperty];
    [self.player.view addSubview:self.btnDown];
    
    
    
    //animate Button Down
    
    
    self.btnDown.translatesAutoresizingMaskIntoConstraints = YES;
    self.btnDown.frame=CGRectMake( self.btnDown.frame.origin.x,  self.btnDown.frame.origin.y-22,  self.btnDown.frame.size.width,  self.btnDown.frame.size.width);
    CGRect frameBtnDown=self.btnDown.frame;
    
    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            self.btnDown.transform=CGAffineTransformMakeScale(1.5, 1.5);
            
            [self addShadow];
            self.btnDown.frame=CGRectMake(frameBtnDown.origin.x, frameBtnDown.origin.y+17, frameBtnDown.size.width, frameBtnDown.size.width);
            
            
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            self.btnDown.frame=CGRectMake(frameBtnDown.origin.x, frameBtnDown.origin.y, frameBtnDown.size.width, frameBtnDown.size.width);
            self.btnDown.transform=CGAffineTransformIdentity;
            [self addShadow];
        }];
    } completion:nil];
    
}
-(void)addShadow
{
    self.btnDown.imageView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.btnDown.imageView.layer.shadowOffset = CGSizeMake(0, 1);
    self.btnDown.imageView.layer.shadowOpacity = 1;
    self.btnDown.imageView.layer.shadowRadius = 4.0;
    self.btnDown.imageView.clipsToBounds = NO;
}
#pragma mark- MPMoviePlayerLoadStateDidChange Notification
- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification {
    
    if ((player.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK) {
        //add your code
        NSLog(@"Playing OK");
        self.btnDown.hidden=FALSE;
        
        //[self.btnDown bringSubviewToFront:self.player.view];
        
        
    }
    NSLog(@"loadState=%lu",player.loadState);
    //[self.btnDown bringSubviewToFront:self.player.view];
    
}





#pragma mark- Pan Gesture Delagate

- (BOOL)gestureRecognizerShould:(UIGestureRecognizer *)gestureRecognizer {
    
    if(gestureRecognizer.view.frame.origin.y<0)
    {
        return NO;
    }
    return YES;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark- Pan Gesture Selector Action

-(void)panAction:(UIPanGestureRecognizer *)recognizer
{
    
    CGFloat y = [recognizer locationInView:self.view].y;
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        direction = UIPanGestureRecognizerDirectionUndefined;
        //storing direction
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        [self detectPanDirection:velocity];
        
        //Snag the Y position of the touch when panning begins
        _touchPositionInHeaderY = [recognizer locationInView:self.viewVedio].y;
        _touchPositionInHeaderX = [recognizer locationInView:self.viewVedio].x;
        if(direction==UIPanGestureRecognizerDirectionDown)
        {
            player.controlStyle=MPMovieControlStyleNone;
            
        }
        
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged){
        
        
        if(direction==UIPanGestureRecognizerDirectionDown || direction==UIPanGestureRecognizerDirectionUp)
        {
            
            CGFloat trueOffset = y - _touchPositionInHeaderY;
            CGFloat xOffset = (y - _touchPositionInHeaderY)*0.35;
            [self adjustViewOnVerticalPan:trueOffset :xOffset recognizer:recognizer];
            
        }
        else if (direction==UIPanGestureRecognizerDirectionRight || direction==UIPanGestureRecognizerDirectionLeft)
        {
            [self adjustViewOnHorizontalPan:recognizer];
        }
        
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded){
        
        if(direction==UIPanGestureRecognizerDirectionDown || direction==UIPanGestureRecognizerDirectionUp)
        {
            
            if(recognizer.view.frame.origin.y<0)
            {
                [self expandViewOnPan];
                
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                
                return;
                
            }
            else if(recognizer.view.frame.origin.y>(self.initialFirstViewFrame.size.width/2))
            {
                
                [self minimizeViewOnPan];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
                
                
            }
            else if(recognizer.view.frame.origin.y<(self.initialFirstViewFrame.size.width/2))
            {
                [self expandViewOnPan];
                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
                
            }
        }
        
        else if (direction==UIPanGestureRecognizerDirectionLeft)
        {
            if(self.viewTable.alpha<=0)
            {
                
                if(recognizer.view.frame.origin.x<0)
                {
                    [self.view removeFromSuperview];
                    [self removeView];
                    [self.delegate removeController];
                    
                }
                else
                {
                    [self animateViewToRight:recognizer];
                    
                }
            }
        }
        
        else if (direction==UIPanGestureRecognizerDirectionRight)
        {
            if(self.viewTable.alpha<=0)
            {
                
                
                if(recognizer.view.frame.origin.x>self.initialFirstViewFrame.size.width-50)
                {
                    [self.view removeFromSuperview];
                    [self removeView];
                    [self.delegate removeController];
                    
                }
                else
                {
                    [self animateViewToLeft:recognizer];
                    
                }
            }
        }
        
        
    }
    
}

#pragma mark- View Function Methods
-(void)stGrowingTextViewProperty
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Keyboard events

//Handling the keyboard appear and disappering events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    
    //__weak typeof(self) weakSelf = self;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    [UIView animateWithDuration:0.3f
//                          delay:0.0f
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//                         float yPosition=self.view.frame.size.height- kbSize.height- self.viewGrowingTextView.frame.size.height;
//                         self.viewGrowingTextView.frame=CGRectMake(0, yPosition, self.viewGrowingTextView.frame.size.width, self.viewGrowingTextView.frame.size.height);
//                     }
//                     completion:^(BOOL finished) {
//                     }];
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    float yPosition=self.view.frame.size.height- kbSize.height- self.viewGrowingTextView.frame.size.height;
    self.viewGrowingTextView.frame=CGRectMake(0, yPosition, self.viewGrowingTextView.frame.size.width, self.viewGrowingTextView.frame.size.height);
    //[UIView beginAnimations:@"ResizeTextView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // __weak typeof(self) weakSelf = self;
    //NSDictionary* info = [aNotification userInfo];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         float yPosition=self.view.frame.size.height-self.viewGrowingTextView.frame.size.height;
                         self.viewGrowingTextView.frame=CGRectMake(0, yPosition, self.viewGrowingTextView.frame.size.width, self.viewGrowingTextView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark- View Function Methods


-(void)animateViewToRight:(UIPanGestureRecognizer *)recognizer{
    [self.txtViewGrowing resignFirstResponder];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = menuFrame;
                         self.viewVedio.frame=viewFrame;
                         player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                         self.viewTable.alpha=0;
                         self.viewVedio.alpha=1;
                         
                         
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
}

-(void)animateViewToLeft:(UIPanGestureRecognizer *)recognizer{
    [self.txtViewGrowing resignFirstResponder];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = menuFrame;
                         self.viewVedio.frame=viewFrame;
                         player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                         self.viewTable.alpha=0;
                         self.viewVedio.alpha=1;
                         
                         
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
}


-(void)adjustViewOnHorizontalPan:(UIPanGestureRecognizer *)recognizer {
    [self.txtViewGrowing resignFirstResponder];
    CGFloat x = [recognizer locationInView:self.view].x;
    
    if (direction==UIPanGestureRecognizerDirectionLeft)
    {
        if(self.viewTable.alpha<=0)
        {
            
            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            
            
            
            CGPoint translation = [recognizer translationInView:recognizer.view];
            
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y );
            
            
            if (!isVerticalGesture) {
                
                CGFloat percentage = (x/self.initialFirstViewFrame.size.width);
                
                recognizer.view.alpha = percentage;
                
            }
            
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
        }
    }
    else if (direction==UIPanGestureRecognizerDirectionRight)
    {
        if(self.viewTable.alpha<=0)
        {
            
            NSLog(@"recognizer x=%f",recognizer.view.frame.origin.x);
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
            
            
            
            CGPoint translation = [recognizer translationInView:recognizer.view];
            
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y );
            
            
            if (!isVerticalGesture) {
                
                if(velocity.x > 0)
                {
                    
                    CGFloat percentage = (x/self.initialFirstViewFrame.size.width);
                    recognizer.view.alpha =1.0- percentage;                }
                else
                {
                    CGFloat percentage = (x/self.initialFirstViewFrame.size.width);
                    recognizer.view.alpha =percentage;
                    
                    
                }
                
            }
            
            [recognizer setTranslation:CGPointZero inView:recognizer.view];
        }
    }
    
    
    
    
    
}

-(void)adjustViewOnVerticalPan:(CGFloat)trueOffset :(CGFloat)xOffset recognizer:(UIPanGestureRecognizer *)recognizer
{
    [self.txtViewGrowing resignFirstResponder];
    CGFloat y = [recognizer locationInView:self.view].y;
    
    if(trueOffset>=restrictTrueOffset+60||xOffset>=restrictOffset+60)
    {
        CGFloat trueOffset = self.initialFirstViewFrame.size.height - 100;
        CGFloat xOffset = self.initialFirstViewFrame.size.width-160;
        //Use this offset to adjust the position of your view accordingly
        menuFrame.origin.y = trueOffset;
        menuFrame.origin.x = xOffset;
        menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
        
        viewFrame.size.width=self.view.bounds.size.width-xOffset;
        viewFrame.size.height=200-xOffset*0.5;
        viewFrame.origin.y=trueOffset;
        viewFrame.origin.x=xOffset;
        
        
        
        
        [UIView animateWithDuration:0.05
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             self.viewTable.frame = menuFrame;
                             self.viewVedio.frame=viewFrame;
                             player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                             self.viewTable.alpha=0;
                             
                             
                             
                         }
                         completion:^(BOOL finished) {
                             minimizedYouTubeFrame=self.viewVedio.frame;
                             
                             isExpandedMode=FALSE;
                         }];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    }
    else
    {
        
        //Use this offset to adjust the position of your view accordingly
        menuFrame.origin.y = trueOffset;
        menuFrame.origin.x = xOffset;
        menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
        viewFrame.size.width=self.view.bounds.size.width-xOffset;
        viewFrame.size.height=200-xOffset*0.5;
        viewFrame.origin.y=trueOffset;
        viewFrame.origin.x=xOffset;
        float restrictY=self.initialFirstViewFrame.size.height-self.viewVedio.frame.size.height-10;
        
        
        if (self.viewTable.frame.origin.y<restrictY && self.viewTable.frame.origin.y>0) {
            [UIView animateWithDuration:0.09
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^ {
                                 self.viewTable.frame = menuFrame;
                                 self.viewVedio.frame=viewFrame;
                                 player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                                 
                                 CGFloat percentage = y/self.initialFirstViewFrame.size.height;
                                 self.viewTable.alpha= transaparentVw.alpha = 1.0 - percentage;
                                 
                                 
                                 
                                 
                             }
                             completion:^(BOOL finished) {
                                 if(direction==UIPanGestureRecognizerDirectionDown)
                                 {
                                     [self.onView bringSubviewToFront:self.view];
                                 }
                             }];
        }
        else if (menuFrame.origin.y<restrictY&& menuFrame.origin.y>0)
        {
            [UIView animateWithDuration:0.09
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^ {
                                 self.viewTable.frame = menuFrame;
                                 self.viewVedio.frame=viewFrame;
                                 player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                             }completion:nil];
            
            
        }
        
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    
}
-(void)detectPanDirection:(CGPoint )velocity
{
    self.btnDown.hidden=TRUE;
    BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
    
    if (isVerticalGesture) {
        if (velocity.y > 0) {
            direction = UIPanGestureRecognizerDirectionDown;
            
        } else {
            direction = UIPanGestureRecognizerDirectionUp;
        }
    }
    else
        
    {
        if(velocity.x > 0)
        {
            direction = UIPanGestureRecognizerDirectionRight;
        }
        else
        {
            direction = UIPanGestureRecognizerDirectionLeft;
        }
        
    }
    
}

- (void)expandViewOnTap:(UITapGestureRecognizer*)sender {
    
    [self expandViewOnPan];
    for (UIGestureRecognizer *recognizer in self.viewVedio.gestureRecognizers) {
        
        if([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.viewVedio removeGestureRecognizer:recognizer];
        }
    }
    
}

-(void)minimizeViewOnPan
{
    self.btnDown.hidden=TRUE;
    [self.txtViewGrowing resignFirstResponder];
    CGFloat trueOffset = self.initialFirstViewFrame.size.height - 100;
    CGFloat xOffset = self.initialFirstViewFrame.size.width-160;
    
    //Use this offset to adjust the position of your view accordingly
    menuFrame.origin.y = trueOffset;
    menuFrame.origin.x = xOffset;
    menuFrame.size.width=self.initialFirstViewFrame.size.width-xOffset;
    //menuFrame.size.height=200-xOffset*0.5;
    
    // viewFrame.origin.y = trueOffset;
    //viewFrame.origin.x = xOffset;
    viewFrame.size.width=self.view.bounds.size.width-xOffset;
    viewFrame.size.height=200-xOffset*0.5;
    viewFrame.origin.y=trueOffset;
    viewFrame.origin.x=xOffset;
    
    
    
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = menuFrame;
                         self.viewVedio.frame=viewFrame;
                         player.view.frame=CGRectMake( player.view.frame.origin.x,  player.view.frame.origin.x, viewFrame.size.width, viewFrame.size.height);
                         self.viewTable.alpha=0;
                         transaparentVw.alpha=0.0;
                         
                         
                     }
                     completion:^(BOOL finished) {
                         //add tap gesture
                         self.tapRecognizer=nil;
                         if(self.tapRecognizer==nil)
                         {
                             self.tapRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandViewOnTap:)];
                             self.tapRecognizer.numberOfTapsRequired=1;
                             self.tapRecognizer.delegate=self;
                             [self.viewVedio addGestureRecognizer:self.tapRecognizer];
                         }
                         
                         isExpandedMode=FALSE;
                         minimizedYouTubeFrame=self.viewVedio.frame;
                         
                         if(direction==UIPanGestureRecognizerDirectionDown)
                         {
                             [self.onView bringSubviewToFront:self.view];
                         }
                     }];
    
}
-(void)expandViewOnPan
{
    [self.txtViewGrowing resignFirstResponder];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.viewTable.frame = tblFrame;
                         self.viewVedio.frame=youtubeFrame;
                         self.viewVedio.alpha=1;
                         player.view.frame=youtubeFrame;
                         self.viewTable.alpha=1.0;
                         transaparentVw.alpha=1.0;
                         
                         
                     }
                     completion:^(BOOL finished) {
                         player.controlStyle = MPMovieControlStyleDefault;
                         isExpandedMode=TRUE;
                         self.btnDown.hidden=FALSE;
                     }];
    
    
    
}

-(void)removeView
{
    [self.player stop];
    [self.viewVedio removeFromSuperview];
    [self.viewTable removeFromSuperview];
    [transaparentVw removeFromSuperview];
    
    
}

- (IBAction)btnDownTapAction:(id)sender {
     [self minimizeViewOnPan];
}

//发送评论
- (IBAction)btnSendAction:(id)sender{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.labelText = @"评论发送中";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_NEWS_SENDCOMMENT];
    
    parameters = @{
                   @"articleId": @(_newsID),
                   @"token": [Config getToken],
                   @"text": self.txtViewGrowing.text,
                   };
    
    
    [manager POST:URL
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
              NSString *errorMessage = responseObject[@"reason"];
              if (errorCode == 1) {
                  NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                  [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                  
                  return;
                  
              }
              
              self.txtViewGrowing.text = @"";
              //[self updateInputBarHeight];
              
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
              HUD.labelText = responseObject[@"reason"];//@"评论发表成功";
              [HUD hide:YES afterDelay:1];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
          }
     ];
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.commmentOjbs.count;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 30)];
    sectionHeaderView.backgroundColor = kNBR_ProjectColor_BackGroundGray;
    sectionHeaderView.layer.borderColor = kNBR_ProjectColor_LineLightGray.CGColor;
    sectionHeaderView.layer.borderWidth = 0.5f;
    
    
    UILabel *sectionHeaderLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kNBR_SCREEN_W - 30, 30)];
    sectionHeaderLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:14.0f];
    sectionHeaderLable.textColor = [UIColor tagColor];
    
    [sectionHeaderView addSubview:sectionHeaderLable];
    sectionHeaderLable.text = @"评论";
    
    
    return sectionHeaderView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 30)];
    
    view.backgroundColor = kNBR_ProjectColor_BackGroundGray;
    view.layer.borderColor = kNBR_ProjectColor_LineLightGray.CGColor;
    view.layer.borderWidth = 0.5f;
    
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:view.bounds];
    textLabel.textColor = [UIColor nameColor];
    textLabel.backgroundColor = [UIColor themeColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont boldSystemFontOfSize:14];
    if (self.commmentOjbs.count > 0) {
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchCommentList)]];
        textLabel.text = @"查看更多评论";
    }else
    {
        textLabel.text = @"暂无评论";
    }
    
    [view addSubview:textLabel];
    return view;
    
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}


// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = [CommentCell new];// [tableView dequeueReusableCellWithIdentifier:kNewsCommentCellID forIndexPath:indexPath];
    cell.layer.borderColor = kNBR_ProjectColor_LineLightGray.CGColor;
    cell.layer.borderWidth = 0.5f;
    
    NSInteger row = indexPath.row;
    GFKDNewsComment *comments = self.commmentOjbs[row];
    [self setBlockForCommentCell:cell];
    [cell setContentWithComment:comments];
    cell.contentLabel.textColor = [UIColor contentTextColor];
    cell.portrait.tag = row;
    cell.authorLabel.tag = row;
    [cell.portrait enableAvatarModeWithUserInfoDict:[comments.creatorid intValue] pushedView:self];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFKDNewsComment *comment = self.commmentOjbs[indexPath.row];
    
    if (comment.cellHeight) {return comment.cellHeight;}
    
    
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils emojiStringFromRawString:comment.text]];
    
   UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = [UIFont boldSystemFontOfSize:15];
    [label setAttributedText:contentString];
    __block CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;
    
    comment.cellHeight = height + 61;
    
    return comment.cellHeight;
}

- (void)setBlockForCommentCell:(CommentCell *)cell
{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            return YES;
        }
        
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        //删除评论
    };
}

- (void)fetchCommentList
{
    [self minimizeViewOnPan];//当前视图最小化
    
    [self.delegate fetchCommentsBVCController:self.newsID];
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %ld row", (long)indexPath.row);
}
- (IBAction)btnZanClick:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *API = [_newsDetailObj.digged intValue] == 1? GFKDAPI_ARTICLE_REDIGG: GFKDAPI_ARTICLE_DIGG;
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
      parameters:@{
                   @"token":   [Config getToken],
                   @"articleId": @(self.newsID)
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             
             if (errorCode == 0) {
                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                 HUD.labelText = [_newsDetailObj.digged intValue] == 1? @"取消点赞成功": @"添加点赞成功";
                 if ([_newsDetailObj.digged intValue] == 1) {
                     _newsDetailObj.digged = [NSNumber numberWithInt: 0];
                     _label_zanNum.text = @"";
                     _label_zanNum.hidden = YES;
                     [_btn_zan setImage:[UIImage imageNamed:@"toolbar-zan"] forState:UIControlStateNormal];
                 }else
                 {
                     _newsDetailObj.digged = [NSNumber numberWithInt: 1];
                     [_btn_zan setImage:[UIImage imageNamed:@"toolbar-zan-selected"] forState:UIControlStateNormal];
                     
                     if ([_newsDetailObj.diggs intValue]==0) {
                         _newsDetailObj.diggs = [NSNumber numberWithInt: 1];
                         _label_zanNum.text = [_newsDetailObj.diggs stringValue];
                         _label_zanNum.hidden = NO;
                     }
                 }
                 
             } else {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
             }
             
             [HUD hide:YES afterDelay:1];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }];

}

- (IBAction)btnStarClick:(id)sender {
    if ([_newsDetailObj.collected intValue] == 1) {
        [_btn_star setImage:[UIImage imageNamed:@"toolbar-star"] forState:UIControlStateNormal];
    } else {
        [_btn_star setImage:[UIImage imageNamed:@"toolbar-star-selected"] forState:UIControlStateNormal];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *API = [_newsDetailObj.collected intValue] == 1? GFKDAPI_ARTICLE_RECOLLECT: GFKDAPI_ARTICLE_COLLECT;
    [manager GET:[NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, API]
      parameters:@{
                   @"token":   [Config getToken],
                   @"articleId": @(self.newsID)
                   }
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             
             if (errorCode == 0) {
                 HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                 HUD.labelText = [_newsDetailObj.collected intValue] == 1? @"取消收藏成功": @"添加收藏成功";
                 if ([_newsDetailObj.collected intValue] == 1) {
                     _newsDetailObj.collected = [NSNumber numberWithInt: 0];
                     [_btn_star setImage:[UIImage imageNamed:@"toolbar-star"] forState:UIControlStateNormal];
                 }else
                 {
                     _newsDetailObj.collected = [NSNumber numberWithInt: 1];
                     [_btn_star setImage:[UIImage imageNamed:@"toolbar-star-selected"] forState:UIControlStateNormal];
                 }
                 
             } else {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
             }
             
             [HUD hide:YES afterDelay:1];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }];
}


@end
