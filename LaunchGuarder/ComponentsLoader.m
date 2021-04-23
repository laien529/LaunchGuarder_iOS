//
//  ComponentsLoader.m
//  LaunchGuarder
//
//  Created by Cedric Cheng on 2021/4/13.
// 

#import "ComponentsLoader.h"

@implementation ComponentsLoader

+ (instancetype)sharedLoader {
    static dispatch_once_t onceToken;
    static ComponentsLoader *_loader;
    dispatch_once(&onceToken, ^{
        _loader = [[ComponentsLoader alloc] init];
    });
    return _loader;
}

- (void)methodA {
    const char  *fun = __func__;
    NSLog(@"%s 开始执行",fun);
    NSLog(@"%s 结束执行",fun);

}

- (void)methodB {
    const char  *fun = __func__;
    NSLog(@"%s 开始执行",fun);
    NSArray *arr = @[@"11"];
//    NSString *r =  arr[1];
    NSLog(@"%s 结束执行",fun);
}
- (void)methodC {
    const char  *fun = __func__;
    NSLog(@"%s 开始执行",fun);
    NSLog(@"%s 结束执行",fun);
}
- (void)methodD {
    const char  *fun = __func__;
    NSLog(@"%s 开始执行",fun);
    NSLog(@"%s 结束执行",fun);
}
- (void)methodE:(id)param {
    const char  *fun = __func__;
    NSLog(@"%s 开始执行",fun);
    NSLog(@"%s 结束执行",fun);
}
- (void)methodF:(id)param withParam2:(id)param2 {
    const char  *fun = __func__;
    NSLog(@"%s 开始执行",fun);
    NSLog(@"%s 结束执行",fun);
}
- (void)methodG:(id)param withParam2:(id)param2 withParam3:(id)param3 {
    const char  *fun = __func__;
    NSLog(@"%s 开始执行",fun);
    NSLog(@"%s 结束执行",fun);
}

@end
