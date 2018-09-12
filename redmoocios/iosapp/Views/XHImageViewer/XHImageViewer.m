//
//  XHImageViewer.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHImageViewer.h"
#import "XHViewState.h"
#import "XHZoomingImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"
#import <MBProgressHUD.h>

@interface XHImageViewer ()<UIActionSheetDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imgViews;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation XHImageViewer

- (id)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.backgroundScale = 0.95;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
    //add by lfh  增加长按
    UILongPressGestureRecognizer *subImageViewLongPressGesture  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(subSelectImageViewLongPressAction:)];
    subImageViewLongPressGesture.minimumPressDuration = 0.8;
    [self addGestureRecognizer:subImageViewLongPressGesture];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.frame.size.height-50, 100, 20)];
    self.countLabel.textColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self _setup];
    }
    return self;
}

- (void)setImageViewsFromArray:(NSArray*)views {
    NSMutableArray *imgViews = [NSMutableArray array];
    for(id obj in views){
        if([obj isKindOfClass:[UIImageView class]]){
            [imgViews addObject:obj];
            
            UIImageView *view = obj;
            
            XHViewState *state = [XHViewState viewStateForView:view];
            [state setStateWithView:view];
            
            view.userInteractionEnabled = NO;
        }
    }
    _imgViews = [imgViews copy];
}

- (void)showWithImageViews:(NSArray*)views selectedView:(UIImageView*)selectedView {
    [self setImageViewsFromArray:views];
    
    if(_imgViews.count > 0){
        if(![selectedView isKindOfClass:[UIImageView class]] || ![_imgViews containsObject:selectedView]){
            selectedView = _imgViews[0];
        }
        [self showWithSelectedView:selectedView];
    }
}

#pragma mark- Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[backgroundColor colorWithAlphaComponent:0]];
}

- (NSInteger)pageIndex {
    return (_scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5);
}

#pragma mark- View management

- (UIImageView *)currentView {
    return [_imgViews objectAtIndex:self.pageIndex];
}

- (void)showWithSelectedView:(UIImageView*)selectedView {
    for(UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    const NSInteger currentPage = [_imgViews indexOfObject:selectedView];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    if(_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
        _scrollView.alpha = 0;
    }
    
    [self addSubview:_scrollView];
    
    [window addSubview:self];
    
    const CGFloat fullW = window.frame.size.width;
    const CGFloat fullH = window.frame.size.height;
    
    selectedView.frame = [window convertRect:selectedView.frame fromView:selectedView.superview];
    [window addSubview:selectedView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 1;
                         window.rootViewController.view.transform = CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale);
                         
                         selectedView.transform = CGAffineTransformIdentity;
                         
                         CGSize size = (selectedView.image) ? selectedView.image.size : selectedView.frame.size;
                         CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                         CGFloat W = ratio * size.width;
                         CGFloat H = ratio * size.height;
                         selectedView.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                     }
                     completion:^(BOOL finished) {
                         _scrollView.contentSize = CGSizeMake(_imgViews.count * fullW, 0);
                         _scrollView.contentOffset = CGPointMake(currentPage * fullW, 0);
                         
                         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScrollView:)];
                         [_scrollView addGestureRecognizer:gesture];
                         
                         for(UIImageView *view in _imgViews){
                             view.transform = CGAffineTransformIdentity;
                             
                             CGSize size = (view.image) ? view.image.size : view.frame.size;
                             CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             view.frame = CGRectMake((fullW-W)/2, (fullH-H)/2, W, H);
                             
                             XHZoomingImageView *tmp = [[XHZoomingImageView alloc] initWithFrame:CGRectMake([_imgViews indexOfObject:view] * fullW, 0, fullW, fullH)];
                             tmp.imageView = view;
                             
                             [_scrollView addSubview:tmp];
                             
                             UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake([_imgViews indexOfObject:view] * fullW + 10, self.frame.size.height-30, 100, 20)];
                             countLabel.textColor = [UIColor whiteColor];
                             countLabel.font = [UIFont systemFontOfSize:14];;
                             NSString *countNum = [NSString stringWithFormat:@"%ld/%ld",[_imgViews indexOfObject:view]+1,self.imgViews.count];
                             countLabel.text = countNum;
                             [_scrollView addSubview:countLabel];
                         }
                     }
     ];
    
    //[_scrollView addSubview:_countLabel];
//    NSString *countNum = [NSString stringWithFormat:@"%ld/%ld",currentPage+1,self.imgViews.count];
//    self.countLabel.text = countNum;
}

- (void)prepareToDismiss {
    UIImageView *currentView = [self currentView];
    
    if([self.delegate respondsToSelector:@selector(imageViewer:willDismissWithSelectedView:)]) {
        [self.delegate imageViewer:self willDismissWithSelectedView:currentView];
    }
    
    for(UIImageView *view in _imgViews) {
        if(view != currentView) {
            XHViewState *state = [XHViewState viewStateForView:view];
            view.transform = CGAffineTransformIdentity;
            view.frame = state.frame;
            view.transform = state.transform;
            [state.superview addSubview:view];
        }
    }
}

- (void)dismissWithAnimate {
    UIView *currentView = [self currentView];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect rct = currentView.frame;
    currentView.transform = CGAffineTransformIdentity;
    currentView.frame = [window convertRect:rct fromView:currentView.superview];
    [window addSubview:currentView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 0;
                         window.rootViewController.view.transform =  CGAffineTransformIdentity;
                         
                         XHViewState *state = [XHViewState viewStateForView:currentView];
                         currentView.frame = [window convertRect:state.frame fromView:state.superview];
                         currentView.transform = state.transform;
                     }
                     completion:^(BOOL finished) {
                         XHViewState *state = [XHViewState viewStateForView:currentView];
                         currentView.transform = CGAffineTransformIdentity;
                         currentView.frame = state.frame;
                         currentView.transform = state.transform;
                         [state.superview addSubview:currentView];
                         
                         for(UIView *view in _imgViews){
                             XHViewState *_state = [XHViewState viewStateForView:view];
                             view.userInteractionEnabled = _state.userInteratctionEnabled;
                         }
                         
                         [self removeFromSuperview];
                     }
     ];
}

#pragma mark- Gesture events
//点一下
- (void)tappedScrollView:(UITapGestureRecognizer*)sender
{
    [self prepareToDismiss];
    [self dismissWithAnimate];
}

//滑动
- (void)didPan:(UIPanGestureRecognizer*)sender
{
    static UIImageView *currentView = nil;
    
    if(sender.state == UIGestureRecognizerStateBegan){
        currentView = [self currentView];
        
        UIView *targetView = currentView.superview;
        while(![targetView isKindOfClass:[XHZoomingImageView class]]){
            targetView = targetView.superview;
        }
        
        if(((XHZoomingImageView *)targetView).isViewing){
            currentView = nil;
        }
        else{
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            currentView.frame = [window convertRect:currentView.frame fromView:currentView.superview];
            [window addSubview:currentView];
            
            [self prepareToDismiss];
        }
    }
    
    if(currentView){
        if(sender.state == UIGestureRecognizerStateEnded){
            if(_scrollView.alpha>0.5){
                [self showWithSelectedView:currentView];
            }
            else{
                [self dismissWithAnimate];
            }
            currentView = nil;
        }
        else{
            CGPoint p = [sender translationInView:self];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, p.y);
            transform = CGAffineTransformScale(transform, 1 - fabs(p.y)/1000, 1 - fabs(p.y)/1000);
            currentView.transform = transform;
            
            CGFloat r = 1-fabs(p.y)/200;
            _scrollView.alpha = MAX(0, MIN(1, r));
        }
    }
}

//长按一张图片
- (void) subSelectImageViewLongPressAction : (UILongPressGestureRecognizer*) _gesture
{
    if (_gesture.state == UIGestureRecognizerStateBegan) // Handle the press
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看大图",@"保存图片", nil];
        
        actionSheet.tag = 0xAAAAAA;
        [actionSheet showInView:self];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0xAAAAAA)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                //查看大图
                UIImageView *currentImageView = [self currentView];
                NSString *currentUrlStr = [[self currentView].sd_imageURL absoluteString];
                
                [currentImageView sd_setImageWithURL:[NSURL URLWithString:[Utils getMaxImageNameWithName:currentUrlStr]] placeholderImage:[UIImage imageNamed:@"item_default"]];
            }
                break;
                
            case 1:
            {
                 //保存图片
                UIImageView *currentImageView = [self currentView];
                UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
            }
                break;
                
            default:
                break;
        }
        return;
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    
    if (!error) {
        HUD.labelText = @"保存图片成功";
    } else {
        HUD.labelText = [NSString stringWithFormat:@"%@", [error description]];
    }
    
    [HUD hide:YES afterDelay:1];
}


@end
