//
//  LeadViewController.h
//  iosapp
//
//  Created by chen yu-jiao on 15/12/14.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"

@protocol LeadViewControllerDelegate
@optional
- (void)introDidFinish;
@end

@interface LeadViewController : UIViewController<EAIntroDelegate>

@property (nonatomic, assign) id<LeadViewControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *picArray;

- (instancetype)initWithNum:(int)num;
- (instancetype)initWithArray:(NSArray*)objectArray;

- (instancetype) initWithDefaultImg:(NSString*)imgurl;
@end
