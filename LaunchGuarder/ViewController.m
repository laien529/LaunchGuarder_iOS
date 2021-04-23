//
//  ViewController.m
//  LaunchGuarder
//
//  Created by Cedric Cheng on 2021/4/13.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 100)];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.lineBreakMode = NSLineBreakByWordWrapping;
    msg.numberOfLines = 0;
    msg.center = self.view.center;
    NSString *str = @"启动成功 启动没有发生过崩溃";
    NSArray *crashMethods = [NSUserDefaults.standardUserDefaults objectForKey:UD_CRASH_METHOD];
    if (crashMethods.count > 0 ) {
        str = @"启动成功";
        msg.text = [NSString stringWithFormat:@"%@,最近崩溃方法：%@",str, crashMethods];

    } else {
        msg.text = str;
    }

    [self.view addSubview:msg];
}


@end
