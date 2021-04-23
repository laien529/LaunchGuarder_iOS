//
//  LaunchFilter.m
//  LaunchGuarder
//
//  Created by Cedric Cheng on 2021/4/13.
//

#import "LaunchFilter.h"
#import "Aspects.h"


#define CRASH_THRESHOLD  3

@interface LaunchFilter () {
    
}

@end

@implementation LaunchFilter

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

+ (void)installFilter {
    NSMutableArray *componentMethods = [NSMutableArray arrayWithArray:[LaunchFilter readFilterList]];
    
    for (NSDictionary *dict in componentMethods) {
        NSString *methodID = dict[@"MethodID"];
        NSString *cls = [methodID componentsSeparatedByString:@"$"].firstObject;
        NSString *methodName = [methodID componentsSeparatedByString:@"$"][1];
//        NSMutableDictionary *appendIndexDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
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
                NSString *predicateString =[ NSString stringWithFormat:@"%@$%@",cls, methodName];

                [LaunchFilter setupInitFinishStatus:predicateString];
            } else { //为满足阈值，继续添加hook跟踪
                [LaunchFilter registHookMethod:NSSelectorFromString(methodName) target:NSClassFromString(cls)];
            }
        } else {
            [LaunchFilter registHookMethod:NSSelectorFromString(methodName) target:NSClassFromString(cls)];
        }
    }
}

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

+ (void)setupInitFinishStatus:(NSString*)methodID {
    NSArray *filterList = [LaunchFilter readFilterList];
   
    NSPredicate *prd = [NSPredicate predicateWithFormat:@"MethodID==%@",methodID];
    NSDictionary *paramDict = [filterList filteredArrayUsingPredicate:prd].firstObject;

    NSMutableDictionary *record = [NSMutableDictionary dictionaryWithDictionary:paramDict];    record[@"init"] = @(-1);
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
        NSString *predicateString =[ NSString stringWithFormat:@"%@$%@",NSStringFromClass(target),NSStringFromSelector(methodName)];
        [self setupInitStatus:predicateString];

    } error:&error];
    
    if (!error) {
        [target aspect_hookSelector:methodName withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> params){
            NSLog(@"hook-afterAction:%@----%@",target, NSStringFromSelector(methodName));
            NSString *predicateString =[ NSString stringWithFormat:@"%@$%@",NSStringFromClass(target),NSStringFromSelector(methodName)];
            [LaunchFilter setupInitFinishStatus:predicateString];
        } error:&error];
    }
}

+ (void)replaceCrashMethodAction:(SEL)methodName target:(Class)target {
    
    NSError *error;
    [target aspect_hookSelector:methodName withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> params){
        NSLog(@"replace-Action:%@----%@",target, NSStringFromSelector(methodName));
    } error:&error];
}

+ (void)saveLoadRecord:(NSArray*)records {

    [NSUserDefaults.standardUserDefaults setObject:records forKey:UD_FILTER_LIST];
    [NSUserDefaults.standardUserDefaults synchronize];
}

@end
