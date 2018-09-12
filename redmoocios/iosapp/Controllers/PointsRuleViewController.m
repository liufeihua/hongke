//
//  PointsRuleViewController.m
//  iosapp
//
//  Created by redmooc on 16/5/20.
//  Copyright © 2016年 redmooc. All rights reserved.
//

#import "PointsRuleViewController.h"
#import "Config.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCAPI.h"
#import <MBProgressHUD.h>
#import "Utils.h"
#import "FatherTableViewCell.h"
#import "ChildTableViewCell.h"
#import "GroupFriend.h"
#import <Masonry/Masonry.h>
#import "GFKDPointsRule.h"
#import "GFKDLevelPoints.h"
#import "LevelPointsTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


static NSString *kTreeViewCellID = @"TreeViewCell";
static int LINESPACE = 6;

@interface PointsRuleViewController ()<UITableViewDelegate,UITableViewDataSource,HeadViewDelegate>
{
    UITableView *boundTableView;
    NSArray *rulesItem;
    NSMutableArray *treeItem;
    NSArray *contentWords;
    NSMutableArray *levelPoints;
}



@end

@implementation PointsRuleViewController

- (void)viewDidLoad {
    self.navigationItem.title = @"积分规则";
    [super viewDidLoad];
    
    contentWords = @[
                     @"1、参与后台抽奖活动;\n2、累计积分兑换固定奖品;\n3、消耗积分兑换校内电影票;\n4、积分超过规定数后，超过部分积分可提现;\n5、积分抵话费",
                     @"为了给大家提供更好的言论环境，以下是针对违规和作弊行为的相关规则：\n\n1、严禁利用任何违规手段刷分、一经发现立即封号;\n\n2、禁止发布任何形式的反党反政府反社会言论，违者视情节轻重给予禁言或封号处理;\n\n3、超过两个红客账号积分提现或刷奖品到同一收款账号或同一人，系统自动冻结所有关联账号。可通过清除所有账户积分解冻其中一个账号。\n\n美好红客，我们一起努力！"
                     ];
    
    UIView *HeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 50)];
    HeaderView.backgroundColor = [UIColor themeColor];
    UIImageView *firstImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 17, 10, 16)];
    [firstImgView setImage:[UIImage imageNamed:@"pointsRuleTitle"]];
    [HeaderView addSubview:firstImgView];
    UILabel *HeaderLable = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, kNBR_SCREEN_W - 40, 50)];
    HeaderLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:15.0f];
    HeaderLable.textColor = kNBR_ProjectColor_DeepGray;
    [HeaderView addSubview:HeaderLable];
    HeaderLable.text = @"获得积分";
    
    boundTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, kNBR_SCREEN_H) style:UITableViewStyleGrouped];
    boundTableView.delegate = self;
    boundTableView.dataSource = self;
    boundTableView.separatorStyle = NO;
    [self.view addSubview:boundTableView];
    
    [boundTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTreeViewCellID];
    UINib *cellNib=[UINib nibWithNibName:@"LevelPointsTableViewCell" bundle:nil];
    [boundTableView registerNib:cellNib forCellReuseIdentifier:kLevelPointsTableViewCell];
    
    [boundTableView setTableHeaderView:HeaderView];
    [self getPointsRule];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void) getPointsRule{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_POINTSRULES];
    
    parameters = @{
                   @"token": [Config getToken],
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
              //NSDictionary *data = responseObject[@"result"];
              rulesItem = responseObject[@"result"];
              treeItem = [[NSMutableArray alloc] init];
              for (int i = 0; i<rulesItem.count; i++) {
                  GFKDPointsRule *pointsRule = [[GFKDPointsRule alloc] initWithDict:rulesItem[i]];
                  GroupFriend *name=[GroupFriend dataObjectWithMode:pointsRule children:nil];
                  GroupFriend *f=[GroupFriend dataObjectWithMode:pointsRule children:@[name]];
                  [treeItem addObject:f];
              }
              
              [self getPointsLevel];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
              
          }
     ];
}

//得到积分等级
-(void) getPointsLevel{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    NSString *URL;
    NSDictionary *parameters;
    URL = [NSString stringWithFormat:@"%@%@", GFKDAPI_HTTPS_PREFIX, GFKDAPI_LEVELPOINTS];
    
    parameters = @{
                   @"token": [Config getToken],
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
              levelPoints = [[NSMutableArray alloc] init];
              NSArray *data = responseObject[@"result"];
              for (int i = 0; i<data.count; i++) {
                  GFKDLevelPoints *model = [[GFKDLevelPoints alloc] initWithDict:data[i]];
                  model._id = data[i][@"id"];
                  [levelPoints addObject:model];
              }
              
              [boundTableView reloadData];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-error"]];
              HUD.labelText = @"网络异常，操作失败";
              
              [HUD hide:YES afterDelay:1];
              
          }
     ];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return treeItem.count + 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < treeItem.count) {
        GroupFriend *friendGroup = treeItem[section];
        NSInteger count = friendGroup.isOpened ? friendGroup.children.count : 0;
        return count;
    }else if(section == treeItem.count){
        return levelPoints.count;
    }else{
        return 1;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < treeItem.count) {
        GroupFriend *g=treeItem[indexPath.section];
        return [ChildTableViewCell heightForRow:g.mode];
    }else if(indexPath.section == treeItem.count){
        return 40;
    }else {
        NSString *contentStr = contentWords[indexPath.section -treeItem.count-1];
        NSMutableAttributedString *showStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:LINESPACE];//调整行间距
        [showStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentStr length])];
    
        NSDictionary *attrs = @{NSFontAttributeName:[UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:14.0f],NSParagraphStyleAttributeName:paragraphStyle};
        
        float Height = [[showStr string] boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W-40, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.height;
        return Height + 40;
    }
    return 0.1f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == treeItem.count) {
        return 70.0f;
    }else{
        return 50.0f;
    }
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < treeItem.count) {
        GroupFriend *g=treeItem[section];
        FatherTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:kFatherTableViewCell];
        if(cell==nil)
        {
            cell=[[NSBundle mainBundle]loadNibNamed:@"FatherTableViewCell" owner:self options:nil].lastObject;
        }
        cell.delegate = self;
        cell.value=g.mode;
        cell.g=g;
        //cell.treeView=treeView;
        return cell;
    }else{
        UIView *allView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, 70)];
        allView.backgroundColor = [UIColor themeColor];
        UIView *HeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kNBR_SCREEN_W, 50)];
        HeaderView.backgroundColor = kNBR_ProjectColor_StandWhite;
        UIImageView *firstImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 17, 10, 16)];
        [firstImgView setImage:[UIImage imageNamed:@"pointsRuleTitle"]];
        [HeaderView addSubview:firstImgView];
        UILabel *HeaderLable = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, kNBR_SCREEN_W - 40, 50)];
        HeaderLable.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:15.0f];
        HeaderLable.textColor = kNBR_ProjectColor_DeepGray;
        [HeaderView addSubview:HeaderLable];
        if (section == treeItem.count) {
            HeaderLable.text = @"积分等级";
        }else if (section == treeItem.count +1){
            HeaderLable.text = @"积分兑换制度";
        }else if (section == treeItem.count +2){
            HeaderLable.text = @"违规说明";
        }
        [allView addSubview:HeaderView];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 69, kNBR_SCREEN_W-10, 1)];
        line.backgroundColor = [UIColor themeColor];
        [allView addSubview:line];
        return allView;
    }
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < treeItem.count) {
        GroupFriend *g=treeItem[indexPath.section];
        ChildTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:kChildTableViewCell];
        cell.backgroundColor = [UIColor themeColor];
        if(cell==nil)
        {
            cell=[[NSBundle mainBundle]loadNibNamed:@"ChildTableViewCell" owner:self options:nil].lastObject;
        }
        cell.model = g.mode;
        
        return cell;
    }else if (indexPath.section == treeItem.count) {
        GFKDLevelPoints *model = levelPoints[indexPath.row];
        LevelPointsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kLevelPointsTableViewCell];
        if (!cell)
        {
            [tableView registerNib:[UINib nibWithNibName:@"LevelPointsTableViewCell" bundle:nil] forCellReuseIdentifier:kLevelPointsTableViewCell];
            cell = [tableView dequeueReusableCellWithIdentifier:kLevelPointsTableViewCell];
        }
        cell.label_name.text = model.levelName;
        cell.label_minPoints.text = [NSString stringWithFormat:@"%@",model.minPoints] ;
        if ([model.imageUrl isEqualToString:@""]) {
            cell.image_rule.image = nil;
        }else{
            [cell.image_rule sd_setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:nil];
        }
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNBR_TABLEVIEW_CELL_NOIDENTIFIER];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *contentStr = contentWords[indexPath.section -treeItem.count-1];
        NSMutableAttributedString *showStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:LINESPACE];//调整行间距
        [showStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentStr length])];
        
         NSDictionary *attrs = @{NSFontAttributeName:[UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:14.0f],NSParagraphStyleAttributeName:paragraphStyle};
        
        float Height = [[showStr string] boundingRectWithSize:CGSizeMake(kNBR_SCREEN_W-40, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size.height;
        
        UILabel *titileLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kNBR_SCREEN_W-40 , Height + 40)];
        titileLabel.numberOfLines = 0;
        titileLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titileLabel.attributedText = showStr;
        titileLabel.font = [UIFont fontWithName:kNBR_DEFAULT_FONT_NAME size:14.0f];
        titileLabel.textColor = kNBR_ProjectColor_DeepBlack;
        
        [cell.contentView addSubview:titileLabel];
        
        return cell;

    }
    
}

- (void)clickHeadView
{
    [boundTableView reloadData];
}


@end
