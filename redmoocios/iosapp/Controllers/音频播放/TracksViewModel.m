//
//  TracksViewModel.m
//  music
//

#import "TracksViewModel.h"
#import "FYPlayManager.h"

@interface TracksViewModel ()

@property (nonatomic) NSInteger  itemModel;

@end

@implementation TracksViewModel

- (instancetype)initWithCateId:(NSInteger)cateId WithCateName:(NSString *)name WithTrack:(DTracks *)tracks{
    if (self = [super init]) {
        _cateId = cateId;
        _cateName = name;
        _radios = tracks;
    }
    return self;
}


@end
