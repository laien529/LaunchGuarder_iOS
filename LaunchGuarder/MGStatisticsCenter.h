//
//  MGStatisticsCenter.h
//  MGTV-iPhone
//
//  Created by chengsc on 2020/10/26.
//  Copyright © 2020 hunantv. All rights reserved.
//  切面管理中心，通过面向协议/接口和上层消息通信。

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MGHookOptions) {
    MGHookOptionBefore = 0, //在原方法执行前执行hook方法
    MGHookOptionAfter = 1,      //在原方法执行后执行hook方法
    MGHookOptionInstead = 2,    //替换原方法执行，只执行hook方法
    MGHookOptionAutomaticRemoval = 1 << 3  //执行完hook后自动将hook方法移除
};

@interface MGStatisticsCenter : NSObject


+ (MGStatisticsCenter*)defaultCenter;


///  切面注册方法
/// @param methodName 切面目标方法
/// @param target 切面目标方法所在类
/// @param option 切面插桩方法执行时机 MGHookOptions 枚举，
- (void)registHookMethod:(SEL)methodName target:(Class)target option:(MGHookOptions)option;
@end

NS_ASSUME_NONNULL_END
