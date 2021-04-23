//
//  LaunchFilter.h
//  LaunchGuarder
//
//  Created by Cedric Cheng on 2021/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaunchFilter : NSObject

+ (instancetype)sharedFilter;
+ (void)installFilter;

@end

NS_ASSUME_NONNULL_END
