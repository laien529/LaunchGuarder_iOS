//
//  ComponentsLoader.h
//  LaunchGuarder
//
//  Created by Cedric Cheng on 2021/4/13.
//  示例，此处代码实际场景为分布在一个或多个类的启动阶段调用的方法

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComponentsLoader : NSObject

+ (instancetype)sharedLoader;

- (void)methodA;
- (void)methodB;
- (void)methodC;
- (void)methodD;
- (void)methodE:(id)param;
- (void)methodF:(id)param withParam2:(id)param2;
- (void)methodG:(id)param withParam2:(id)param2 withParam3:(id)param3;


@end

NS_ASSUME_NONNULL_END
