//
//  NewShowViewCell.m
//  DouYU
//
//  Created by Alesary on 15/11/2.
//  Copyright © 2015年 Alesary. All rights reserved.
//

#import "NewShowViewCell.h"
#import "NewShow.h"
#import "UIImageView+WebCache.h"
#import "OSCAPI.h"


#define NewCell_H 90

@interface NewShowViewCell ()
{
    UIScrollView *_backScrollView;
    NSMutableArray *_dataArray;
}

@end

@implementation NewShowViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _dataArray = [NSMutableArray array];
        [self addContentView];
        
    }
    
    return self;
}

-(void)addContentView
{
    
    _backScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kNBR_SCREEN_W, NewCell_H)];
    // _backScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    _backScrollView.contentSize=CGSizeMake(kNBR_SCREEN_W, 0);
    _backScrollView.userInteractionEnabled=YES;
    _backScrollView.directionalLockEnabled=YES;
    _backScrollView.pagingEnabled=NO;
    _backScrollView.bounces=NO;
    _backScrollView.showsHorizontalScrollIndicator=NO;
    _backScrollView.showsVerticalScrollIndicator=NO;
    
    [self addSubview:_backScrollView];
    
//    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, NewCell_H-1, kNBR_SCREEN_W, 1)];
//    lineView.backgroundColor = UIColorFromRGB(0xE6E6E6);
//    [self addSubview:lineView];

}


-(void)setContentView:(NSArray *)array
{
    for(UIView *newShowview in [_backScrollView subviews])
    {
        if ([newShowview isKindOfClass:[NewShow class]]) {
            [newShowview removeFromSuperview];
        }
    }
    
    _dataArray = [array copy];
    for (int i=0; i<array.count; i++) {
            GFKDDiscover *grid = [[GFKDDiscover alloc] initWithDict:array[i]];
            //CGRect frame=CGRectMake(i *kNBR_SCREEN_W/4.0, 5, kNBR_SCREEN_W/4.0, NewCell_H);
            CGRect frame=CGRectMake(i%4 *kNBR_SCREEN_W/4.0, 5 + i/4 * (NewCell_H), kNBR_SCREEN_W/4.0, NewCell_H);
            NewShow *_newShowView=[[NewShow alloc] init];
            _newShowView.tag=i;
            _newShowView.frame=frame;
            
            [_newShowView.HeadView sd_setImageWithURL:[NSURL URLWithString:grid.image] placeholderImage:[UIImage imageNamed:@"item_default"]];
            
            _newShowView.Name.text=grid.name;
            
            [_backScrollView addSubview:_newShowView];
            
            UITapGestureRecognizer *tapNewview=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOneNewView:)];
            [_newShowView addGestureRecognizer:tapNewview];
    }
    //_backScrollView.contentSize=CGSizeMake(array.count*kNBR_SCREEN_W/4.0, 0);
    [_backScrollView setFrame:CGRectMake(0, 0, kNBR_SCREEN_W, NewCell_H + (array.count-1)/4 * (NewCell_H))];
    _backScrollView.contentSize=CGSizeMake(kNBR_SCREEN_W, NewCell_H + (array.count-1)/4 * (NewCell_H));
    
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, _backScrollView.frame.size.height-1, kNBR_SCREEN_W, 1)];
    lineView.backgroundColor = UIColorFromRGB(0xE6E6E6);
    [self addSubview:lineView];
}

-(void)tapOneNewView:(UIGestureRecognizer*)sender
{
    GFKDDiscover *grid = [[GFKDDiscover alloc] initWithDict:_dataArray[sender.view.tag]];
    NSLog(@"%ld_linkType:%@",sender.view.tag,grid.linkType);
    if (self.delegate)
    {
        [self.delegate NewShowViewCellWithModel:grid];
    }
}


@end
