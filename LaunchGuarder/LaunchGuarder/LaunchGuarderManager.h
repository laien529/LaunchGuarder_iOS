//
//  LaunchGuarderManager.h
//  LaunchGuarder
//
//  Created by chengsc on 2021/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaunchGuarderManager : NSObject

+ (instancetype)sharedManager;
- (void)setTrackEnable:(BOOL)isEnable;
@end

NS_ASSUME_NONNULL_END
