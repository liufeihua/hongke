//
//  UserDetailsViewController.m
//  iosapp
//
//  Created by redmooc on 16/7/4.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "ImageViewerController.h"

@interface UserDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation UserDetailsViewController

- (instancetype)initWithEntity:(GFKDUser *)entity{
    self = [super init];
    if (self) {
        _userInfoEntity = entity;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"详细资料"];
    leftArr = [[NSMutableArray alloc] initWithObjects:@"姓名",@"性别",@"呢称", nil];
    
    rightArr = [[NSMutableArray alloc] initWithObjects:
                self.userInfoEntity.realName,
                [self.userInfoEntity.gender  isEqual: @""]?@"":self.userInfoEntity.gender,
                self.userInfoEntity.nickname,
                nil];
    
    myTableview =[[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kNBR_SCREEN_W, kNBR_SCREEN_H) style:UITableViewStyleGrouped];
   // [myTableview setBackgroundView:nil];
    //[myTableview setBackgroundColor:[UIColor clearColor]];
    [myTableview setDelegate:self];
    [myTableview setDataSource:self];
    [self.view addSubview:myTableview];
    
    [self CreateHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Header and Footer View
-(void) CreateHeaderView
{
    UIView *headerbgview = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kNBR_SCREEN_W, 96.0f)];
    [headerbgview setBackgroundColor:[UIColor clearColor]];
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kNBR_SCREEN_W, 76.0f)];
    [headerview setBackgroundColor:kNBR_ProjectColor_StandWhite];
    [headerbgview addSubview:headerview];
    
    //头像
    UIImageView *avterImgView = [UIImageView new];
   // avterImgView.imageURL = [NSURL URLWithString:[self.userInfoDict stringWithKeyPath:@"avatar"]];
    avterImgView.frame = CGRectMake(10.0f, 76 / 2.0f - 50 / 2.0f, 50.0f, 50.0f);
    avterImgView.layer.cornerRadius = avterImgView.frame.size.width / 2.0f;
    avterImgView.layer.masksToBounds = YES;
    [avterImgView loadPortrait:[NSURL URLWithString:_userInfoEntity.photo]];
    avterImgView.contentMode = UIViewContentModeScaleAspectFit;
    [avterImgView setCornerRadius:25];
    avterImgView.userInteractionEnabled = YES;
    [avterImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortrait)]];
    
    
    [headerview addSubview:avterImgView];
    
    //用户昵称
    
    NSDictionary *nickNameFormart = @{
                                      NSFontAttributeName : [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:16.0f],
                                      NSForegroundColorAttributeName : kNBR_ProjectColor_DeepGray,
                                      };
    
    CGRect nickNameFrame = [self.userInfoEntity.nickname boundingRectWithSize:CGSizeMake(200, 30)
                                                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                        attributes:nickNameFormart context:nil];
    
    NSAttributedString *nickNameAttString = [[NSAttributedString alloc] initWithString:_userInfoEntity.nickname attributes:nickNameFormart];
    
    UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(avterImgView.frame.origin.x + avterImgView.frame.size.width + 10.0f, avterImgView.frame.origin.y + 8, nickNameFrame.size.width, nickNameFrame.size.height)];
    nicknameLabel.attributedText = nickNameAttString;
    [headerview addSubview:nicknameLabel];
        
    [myTableview setTableHeaderView:headerbgview];
}



#pragma mark tableview delegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [leftArr count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *leftlabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 65, 40.0f)];
    [leftlabel setBackgroundColor:[UIColor clearColor]];
    [leftlabel setFont:[UIFont fontWithName:kNBR_DEFAULT_FONT_NAME_BLOD size:14.0f]];
    [leftlabel setTextColor:kNBR_ProjectColor_DeepGray];
    [leftlabel setText:leftArr[indexPath.row]];
    [cell.contentView addSubview:leftlabel];
    
    UILabel *rightlabel = [[UILabel alloc] initWithFrame:CGRectMake(leftlabel.frame.size.width+leftlabel.frame.origin.x+5.0f, 0.0f, kNBR_SCREEN_W-leftlabel.frame.size.width-leftlabel.frame.origin.x-20.0f, 40.0f)];
    [rightlabel setBackgroundColor:[UIColor clearColor]];
    [rightlabel setFont:[UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:14.0f]];
    [rightlabel setTextColor:kNBR_ProjectColor_MidGray];
    [rightlabel setText:rightArr[indexPath.row]];
    [cell.contentView addSubview:rightlabel];
    
    return cell;
}


- (void)tapPortrait
{
    NSString *str =  _userInfoEntity.photo;
    
    if (str.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"尚未设置头像" message:nil delegate:self
                                                  cancelButtonTitle:@"知道了" otherButtonTitles: nil];
        [alertView show];
        return ;
    }

    if (!((NSNull *)_userInfoEntity.class == [NSNull null] ||[_userInfoEntity.origphoto isEqualToString:@""])) {
        str = _userInfoEntity.origphoto;
    }
    ImageViewerController *imgViewweVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:str]];
    
    [self presentViewController:imgViewweVC animated:YES completion:nil];
}


@end
