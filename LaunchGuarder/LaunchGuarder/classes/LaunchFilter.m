//
//  LaunchFilter.m
//  LaunchGuarder
//
//  Created by Cedric Cheng on 2021/4/13.
//

#import "LaunchFilter.h"
#import "Aspects.h"


#define CRASH_THRESHOLD  3 //连续崩溃次数阈值，正式启用时服务端下发

@interface LaunchFilter () {
    
}

@end

@implementation LaunchFilter

+ (void)load {
    [LaunchFilter installFilter];
}

+ (instancetype)sharedFilter {
    static dispatch_once_t onceToken;
    static LaunchFilter *_filter;
    dispatch_once(&onceToken, ^{
        _filter = [[LaunchFilter alloc] init];
    });
    return _filter;
}



/// 读取静态配置文件.load.json，注入了待hook追踪的启动阶段调用的方法。后期根据二进制重排的mach-o文件来做相关策略
+ (NSArray*)readFilterList {
    if ([NSUserDefaults.standardUserDefaults objectForKey:UD_FILTER_LIST]) {
        
    } else {
        NSString *path = [NSBundle.mainBundle pathForResource:@"load" ofType:@"json"];

        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            @try {
                NSData *fileData = [NSFileManager.defaultManager contentsAtPath:path];
                NSError *error;
                NSArray *filterList = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableLeaves error:&error];
                [NSUserDefaults.standardUserDefaults setObject:filterList forKey:UD_FILTER_LIST];
                [NSUserDefaults.standardUserDefaults synchronize];
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
        }
    }
    return [NSUserDefaults.standardUserDefaults objectForKey:UD_FILTER_LIST];
}


+ (void)installFilter {
    
    NSMutableArray *componentMethods = [NSMutableArray arrayWithArray:[LaunchFilter readFilterList]];
    
    for (NSDictionary *dict in componentMethods) {
        NSString *methodID = dict[@"MethodID"];
        NSString *cls = [methodID componentsSeparatedByString:@"$"].firstObject;
        NSString *methodName = [methodID componentsSeparatedByString:@"$"][1];
        
        NSNumber *isInit = dict[@"init"];
       
        if (isInit.integerValue == 0) { //上次未初始化成功（疑似崩溃发生）
            //1 崩溃数+1，连续崩溃阈值检查
            NSNumber *crashCount = [NSUserDefaults.standardUserDefaults objectForKey:UD_CRASH_COUNT];
            [NSUserDefaults.standardUserDefaults setObject:@(crashCount.integerValue + 1) forKey:UD_CRASH_COUNT];
            [NSUserDefaults.standardUserDefaults synchronize];
            NSLog(@"========================:%@",@"崩溃次数+1");

            if (crashCount.integerValue + 1 >= CRASH_THRESHOLD) { //or2 满足阈值，启动容错方案，hook replace
                [NSUserDefaults.standardUserDefaults setObject:@(0) forKey:UD_CRASH_COUNT];
                NSArray *methods = [NSUserDefaults.standardUserDefaults objectForKey:UD_CRASH_METHOD];

                if (methods) {
                    NSMutableArray *appendArray = [NSMutableArray arrayWithArray:methods];
                    [appendArray addObject:methodID];
                    [NSUserDefaults.standardUserDefaults setObject:appendArray forKey:UD_CRASH_METHOD];
                } else {
                    NSMutableArray *appendArray = [[NSMutableArray alloc] init];
                    [NSUserDefaults.standardUserDefaults setObject:appendArray forKey:UD_CRASH_METHOD];

                }

                [NSUserDefaults.standardUserDefaults synchronize];
                [LaunchFilter replaceCrashMethodAction:NSSelectorFromString(methodName)  target:NSClassFromString(cls)];
                NSString *predicateString = [NSString stringWithFormat:@"%@$%@",cls, methodName];

                [LaunchFilter setupInitFinishStatus:predicateString];
            } else { //为满足阈值，继续添加hook跟踪
                [LaunchFilter registHookMethod:NSSelectorFromString(methodName) target:NSClassFromString(cls)];
            }
        } else {
            [LaunchFilter registHookMethod:NSSelectorFromString(methodName) target:NSClassFromString(cls)];
        }
    }
}

/// 表示初始化开始，写入方法调用开始状态，后续没有写入完成则表明未完成方法执行，发生了异常/崩溃
/// @param methodID 方法id，同load.json配置项字段
+ (void)setupInitStatus:(NSString*)methodID {
    NSArray *filterList = [LaunchFilter readFilterList];
   
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"MethodID==%@",methodID];
    NSDictionary *paramDict = [filterList filteredArrayUsingPredicate:prd].firstObject;

    NSMutableDictionary *record = [NSMutableDictionary dictionaryWithDictionary:paramDict];
    record[@"init"] = @(0);
    NSMutableArray *componentMethods = [NSMutableArray arrayWithArray:[LaunchFilter readFilterList]] ;
   
    NSDictionary *dict = [componentMethods filteredArrayUsingPredicate:prd].firstObject;
    NSInteger index = [componentMethods indexOfObject:dict];
    [componentMethods setObject:record atIndexedSubscript:index];
    [LaunchFilter saveLoadRecord:componentMethods];
}


/// 表示初始化完成，写入完成标志位
/// @param methodID 方法id，同load.json配置项字段
+ (void)setupInitFinishStatus:(NSString*)methodID {
    NSArray *filterList = [LaunchFilter readFilterList];
   
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"MethodID==%@",methodID];
    NSDictionary *paramDict = [filterList filteredArrayUsingPredicate:prd].firstObject;

    NSMutableDictionary *record = [NSMutableDictionary dictionaryWithDictionary:paramDict];
    record[@"init"] = @(-1);
    NSMutableArray *componentMethods = [NSMutableArray arrayWithArray:[LaunchFilter readFilterList]] ;
    NSDictionary *dict = [componentMethods filteredArrayUsingPredicate:prd].firstObject;
    NSInteger index = [componentMethods indexOfObject:dict];
    [componentMethods setObject:record atIndexedSubscript:index];
    [LaunchFilter saveLoadRecord:componentMethods];
}

+ (void)registHookMethod:(SEL)methodName target:(Class)target {
    NSError *error;

    [target aspect_hookSelector:methodName withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> params){
        NSLog(@"hook-beforeAction:%@----%@",target, NSStringFromSelector(methodName));
        NSString *predicateString = [NSString stringWithFormat:@"%@$%@",NSStringFromClass(target),NSStringFromSelector(methodName)];
        [self setupInitStatus:predicateString];

    } error:&error];
    
    if (!error) {
        [target aspect_hookSelector:methodName withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> params){
            NSLog(@"hook-afterAction:%@----%@",target, NSStringFromSelector(methodName));
            NSString *predicateString = [NSString stringWithFormat:@"%@$%@",NSStringFromClass(target),NSStringFromSelector(methodName)];
            [LaunchFilter setupInitFinishStatus:predicateString];
        } error:&error];
    }
}


/// HOOK触发替换崩溃方法原实现，可以做降级，恢复等处理.
+ (void)replaceCrashMethodAction:(SEL)methodName target:(Class)target {
    
    NSError *error;
    [target aspect_hookSelector:methodName withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> params){
        //Do anything you want after recover from App launch crash. or ignore the method which crash happened.
        NSLog(@"replace-Action:%@----%@",target, NSStringFromSelector(methodName));
    } error:&error];
}

+ (void)saveLoadRecord:(NSArray*)records {

    [NSUserDefaults.standardUserDefaults setObject:records forKey:UD_FILTER_LIST];
    [NSUserDefaults.standardUserDefaults synchronize];
}

@end
