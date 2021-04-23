//
//  AppDelegate.m
//  LaunchGuarder
//
//  Created by Cedric Cheng on 2021/4/13.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ComponentsLoader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    ViewController *root = [[ViewController alloc] init];
    self.window.rootViewController = root;
    
    //
    [ComponentsLoader.sharedLoader methodA];
    [ComponentsLoader.sharedLoader methodB];
    [ComponentsLoader.sharedLoader methodC];
    [ComponentsLoader.sharedLoader methodD];
    [ComponentsLoader.sharedLoader methodE:@"E"];
    [ComponentsLoader.sharedLoader methodF:@"F1" withParam2:@"F2"];
    [ComponentsLoader.sharedLoader methodG:@"G1" withParam2:@"G2" withParam3:@"G3"];

    [self.window makeKeyAndVisible];
    return YES;
}


@end
