//
//  TracksViewModel.m
//  music
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "GFKDNews.h"
#import "GFKDTopNodes.h"
#import "DTracks.h"


@interface TracksViewModel : NSObject

- (instancetype)initWithCateId:(NSInteger)cateId WithCateName:(NSString *)name WithTrack:(DTracks *)tracks;

@property (nonatomic, assign) NSInteger cateId;
@property (nonatomic, strong) DTracks *radios;
//@property (nonatomic, strong) GFKDTopNodes *album;
@property (nonatomic, assign) NSString *cateName;

@end
