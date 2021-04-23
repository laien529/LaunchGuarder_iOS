//
//  MGStatisticsCenter.m
//  MGTV-iPhone
//
//  Created by chengsc on 2020/10/26.
//  Copyright © 2020 hunantv. All rights reserved.
//

#import "MGStatisticsCenter.h"
//#import "Stinger.h"
#import "Aspects.h"

@interface MGStatisticsCenter ()

@property(nonatomic, strong, nonnull) NSMutableDictionary *pageIds;

@end

@implementation MGStatisticsCenter

+ (void)load {
    MGStatisticsCenter registHookMethod:<#(SEL)#> target:<#(__unsafe_unretained Class)#> option:<#(MGHookOptions)#>
}

+ (MGStatisticsCenter *)defaultCenter {
    static dispatch_once_t onceToken;
    static MGStatisticsCenter *_center;
    dispatch_once(&onceToken, ^{
        _center = [[MGStatisticsCenter alloc] init];
    });
    return _center;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _pageIds = [[NSMutableDictionary alloc] initWithCapacity:1];
        
    }
    return self;
}
+ (void)registHookMethod:(SEL)methodName target:(Class)target option:(MGHookOptions)option {
//    NSString *methodString = NSStringFromSelector(methodName);
//    BOOL isClassMethod = [methodString hasPrefix:@"+"];
    [self registHookMethod:methodName instanceMethod:YES target:target option:option];
}

+ (void)registHookMethod:(SEL)methodName instanceMethod:(BOOL)isInstanceMethod target:(Class)target option:(MGHookOptions)option {
    NSString *clsName = NSStringFromClass(target);
    NSError *error;
    if (isInstanceMethod) {
        [target aspect_hookSelector:methodName withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> params){
        
        } error:&error];

    } else {
//        [target aspect_hookSelector:methodName withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> params){
//            [self aopTargetBind:params.instance];
//        }error:&error];
    }

}

@end
