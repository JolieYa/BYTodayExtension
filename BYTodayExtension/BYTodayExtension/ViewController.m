//
//  ViewController.m
//  BYTodayExtension
//
//  Created by admin on 2018/1/3.
//  Copyright © 2018年 banyan. All rights reserved.
//

#import "ViewController.h"
#import "TwoVC.h"

#define kDefaultVolume 1

@interface ViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *showL;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.showL = [[UITextField alloc] init];
    self.showL.frame = (CGRect){self.view.bounds.size.width-120, 120, 50, 30};
    self.showL.textColor = [UIColor blackColor];
    self.showL.textAlignment = NSTextAlignmentCenter;
    self.showL.backgroundColor = [UIColor redColor];
    self.showL.delegate = self;
    self.showL.text = [NSString stringWithFormat:@"%d", [self getVolume]];
    [self.view addSubview:self.showL];
    
    NSLog(@"volume: %d", [self getVolume]); // 从共享沙盒中获取数据
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)refreshData
{
    self.showL.text = [NSString stringWithFormat:@"%d", [self getVolume]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
//    TwoVC *vc = [[TwoVC alloc] init];
//    [self.navigationController pushViewController:vc animated:true];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setVolume:textField.text.intValue]; // 保存数据到共享沙盒中
    NSLog(@"volume: %d", [self getVolume]); // 从共享沙盒中获取数据
}

//读写共享的数据
- (NSUserDefaults *)loadGroupData
{
    NSUserDefaults *userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.BYgroup"];// SuiteName必须和上面Capabilities配置填写的一致
    return userDefault;
}

- (void)setVolume:(uint32_t)volume
{
    [[self loadGroupData] setObject:@(volume) forKey:@"volume"];
    [[self loadGroupData] synchronize];
}

- (uint32_t)getVolume
{
    NSNumber *volumeNumber = [[self loadGroupData] objectForKey:@"volume"];
    if (volumeNumber && [volumeNumber isKindOfClass:[NSNumber class]]) {
        return volumeNumber.unsignedIntValue;
    } else {
        return kDefaultVolume;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
