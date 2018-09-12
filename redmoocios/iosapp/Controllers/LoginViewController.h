//
//  LoginViewController.h
//  iosapp
//
//  Created by chenhaoxiang on 11/4/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *label_notes;
@property (weak, nonatomic) IBOutlet UILabel *label_shows;

@property (weak, nonatomic) IBOutlet UIImageView *img_shows;
@property (strong, nonatomic) IBOutlet UIView *content_view;
@end
