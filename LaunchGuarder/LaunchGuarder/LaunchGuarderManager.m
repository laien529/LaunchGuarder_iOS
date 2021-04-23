//
//  LaunchGuarderManager.m
//  LaunchGuarder
//
//  Created by chengsc on 2021/4/23.
//

#import "LaunchGuarderManager.h"

@implementation LaunchGuarderManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static LaunchGuarderManager *_launchGuarderManager;
    dispatch_once(&onceToken, ^{
        _launchGuarderManager = [[LaunchGuarderManager alloc] init];
    });
    return _launchGuarderManager;
}

- (void)setTrackEnable:(BOOL)isEnable {
    
}
@end
