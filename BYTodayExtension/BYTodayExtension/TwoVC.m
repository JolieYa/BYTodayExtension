//
//  TwoVC.m
//  BYTodayExtension
//
//  Created by admin on 2018/1/4.
//  Copyright © 2018年 banyan. All rights reserved.
//

#import "TwoVC.h"

@interface TwoVC ()

@end

@implementation TwoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"第二页";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    UIApplication.shared.openURL(URL.init(string: "XHWL://action=GotoHomePage")!)
//    AppDelegate.shared().window?.makeKeyAndVisible()
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"TodayURLHttp://action=GotoHomePage"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
