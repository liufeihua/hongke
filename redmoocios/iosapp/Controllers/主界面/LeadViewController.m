//
//  LeadViewController.m
//  iosapp
//
//  Created by chen yu-jiao on 15/12/14.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "LeadViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import <MBProgressHUD.h>

@interface LeadViewController ()
@property (nonatomic, assign) int num;
@end

@implementation LeadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (instancetype)initWithNum:(int)num
{
    self = [super init];
    if (self) {
        _num = num;
        if (_num == 1) {
            [self showIntroWithCrossDissolve];
            //[self showIntroWithUrl :@"first_picture"];
        }else
        {
            [self showIntroWithUrl :@"picture"];//从后台读取
        }
    }
    return self;
}

- (instancetype)initWithArray:(NSArray*)objectArray
{
    self = [super init];
    if (self) {
        
        NSMutableArray *pages = [[NSMutableArray alloc] init];
        for (NSDictionary *objectDict in objectArray) {
            NSString *imgUrl = objectDict[@"image"];
           
            EAIntroPage *page = [EAIntroPage page];
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
            page.bgImage = [UIImage imageWithData:data];
          
            [pages addObject:page];
        }
        EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pages];
        
        [intro setDelegate:self];
        [intro showInView:self.view animateDuration:0.0];
    }
    return self;
}

- (instancetype) initWithDefaultImg:(NSString*)imgurl{
    self = [super init];
    if (self) {
        NSMutableArray *pages = [[NSMutableArray alloc] init];
        EAIntroPage *page = [EAIntroPage page];
        page.bgImage = [UIImage imageNamed:@"start"];
        [pages addObject:page];
        
        EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pages];
        
        [intro setDelegate:self];
        [intro showInView:self.view animateDuration:0.0];
    }
    return self;
}


- (void)setPicArray:(NSArray *)picArray{
    _picArray = picArray;
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    for (NSDictionary *objectDict in picArray) {
        NSString *imgUrl = objectDict[@"image"];
        
        EAIntroPage *page = [EAIntroPage page];
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
        page.bgImage = [UIImage imageWithData:data];
        
        [pages addObject:page];
    }
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pages];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}
//- (void)viewDidAppear:(BOOL)animated {
//    // all settings are basic, pages with custom packgrounds, title image on each page
//    if (_num == 1) {
//        //[self showIntroWithCrossDissolve];
//        [self showIntroWithUrl :@"first_picture"];
//    }else
//    {
//        [self showIntroWithUrl :@"picture"];//从后台读取
//    }
//}

- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    page1.bgImage = [UIImage imageNamed:@"lead_page_img_2_1.jpg"];
//    page1.titleImage = [UIImage imageNamed:@"original"];
    
    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
    page2.bgImage = [UIImage imageNamed:@"lead_page_img_2_2.jpg"];
//    page2.titleImage = [UIImage imageNamed:@"supportcat"];
    
    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
    page3.bgImage = [UIImage imageNamed:@"lead_page_img_2_3.jpg"];
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)showIntroWithUrl :(NSString *) code{
    NSMutableArray *pages = [[NSMutableArray alloc] init];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",GFKDAPI_HTTPS_PREFIX,GFKDAPI_LAUNCH]
      parameters:@{@"code":code}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSInteger errorCode = [responseObject[@"msg_code"] integerValue];
             NSString *errorMessage = responseObject[@"reason"];
             NSArray *objectArray = responseObject[@"result"];
             for (NSDictionary *objectDict in objectArray) {
                 NSString *imgUrl = objectDict[@"image"];
                 
                 NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
                 EAIntroPage *page = [EAIntroPage page];
                 page.bgImage = [UIImage imageWithData:data];
                 [pages addObject:page];
             }
             
             EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pages];
             
             [intro setDelegate:self];
             [intro showInView:self.view animateDuration:0.0];
             
             if (errorCode == 1) {
                 NSInteger invalidToken = [responseObject[@"invalidToken"] integerValue];
                 [Utils showHttpErrorWithCode:(int)invalidToken withMessage:errorMessage];
                 
                 return;
                 
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
             HUD.labelText = @"网络异常，操作失败";
             
             [HUD hide:YES afterDelay:1];
         }
     ];
    
    
}


//- (void)showBasicIntroWithBg {
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.titleImage = [UIImage imageNamed:@"original"];
//    
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
//    page2.titleImage = [UIImage imageNamed:@"supportcat"];
//    
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
//    
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
//    intro.bgImage = [UIImage imageNamed:@"introBg"];
//    
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
//}
//
//- (void)showBasicIntroWithFixedTitleView {
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
//    
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
//    
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
//    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"original"]];
//    intro.titleView = titleView;
//    intro.backgroundColor = [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f]; //iOS7 dark blue
//    
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
//}
//
//- (void)showCustomIntro {
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.titleImage = [UIImage imageNamed:@"original"];
//    
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.titlePositionY = 180;
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
//    page2.descPositionY = 160;
//    page2.titleImage = [UIImage imageNamed:@"supportcat"];
//    page2.imgPositionY = 70;
//    
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.titleFont = [UIFont fontWithName:@"Georgia-BoldItalic" size:20];
//    page3.titlePositionY = 220;
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.";
//    page3.descFont = [UIFont fontWithName:@"Georgia-Italic" size:18];
//    page3.descPositionY = 200;
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
//    page3.imgPositionY = 100;
//    
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
//    intro.backgroundColor = [UIColor colorWithRed:1.0f green:0.58f blue:0.21f alpha:1.0f]; //iOS7 orange
//    
//    intro.pageControlY = 100.0f;
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn setBackgroundImage:[UIImage imageNamed:@"skipButton"] forState:UIControlStateNormal];
//    [btn setFrame:CGRectMake((320-230)/2, [UIScreen mainScreen].bounds.size.height - 60, 230, 40)];
//    [btn setTitle:@"SKIP NOW" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    intro.skipButton = btn;
//    
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
//}
//
//- (void)showIntroWithCustomView {
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.bgImage = [UIImage imageNamed:@"1"];
//    page1.titleImage = [UIImage imageNamed:@"original"];
//    
//    UIView *viewForPage2 = [[UIView alloc] initWithFrame:self.view.bounds];
//    UILabel *labelForPage2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, 300, 30)];
//    labelForPage2.text = @"Some custom view";
//    labelForPage2.font = [UIFont systemFontOfSize:32];
//    labelForPage2.textColor = [UIColor whiteColor];
//    labelForPage2.backgroundColor = [UIColor clearColor];
//    labelForPage2.transform = CGAffineTransformMakeRotation(M_PI_2*3);
//    [viewForPage2 addSubview:labelForPage2];
//    EAIntroPage *page2 = [EAIntroPage pageWithCustomView:viewForPage2];
//    
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
//    page3.bgImage = [UIImage imageNamed:@"3"];
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
//    
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
//    
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
//}
//
//- (void)showIntroWithSeparatePagesInit {
//    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds];
//    
//    [intro setDelegate:self];
//    [intro showInView:self.view animateDuration:0.0];
//    
//    EAIntroPage *page1 = [EAIntroPage page];
//    page1.title = @"Hello world";
//    page1.desc = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//    page1.bgImage = [UIImage imageNamed:@"helpPhoto_1.png"];
//    page1.titleImage = [UIImage imageNamed:@"original"];
//    
//    EAIntroPage *page2 = [EAIntroPage page];
//    page2.title = @"This is page 2";
//    page2.desc = @"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.";
//    page2.bgImage = [UIImage imageNamed:@"helpPhoto_2.png"];
//    page2.titleImage = [UIImage imageNamed:@"supportcat"];
//    
//    EAIntroPage *page3 = [EAIntroPage page];
//    page3.title = @"This is page 3";
//    page3.desc = @"Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.";
//    page3.bgImage = [UIImage imageNamed:@"helpPhoto_3.png"];
//    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
//    
//    [intro setPages:@[page1,page2,page3]];
//}

- (void)introDidFinish {
    NSLog(@"Intro callback");
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if ([(id)self.delegate respondsToSelector:@selector(introDidFinish)]) {
        [self.delegate introDidFinish];
    }
}
@end
