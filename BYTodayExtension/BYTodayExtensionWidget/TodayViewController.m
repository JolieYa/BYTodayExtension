//
//  TodayViewController.m
//  BYTodayExtensionWidget
//
//  Created by admin on 2018/1/3.
//  Copyright © 2018年 banyan. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#define kDefaultVolume 1

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) UILabel *showL;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = (CGRect){15, 20, 50, 30};
    leftBtn.contentHorizontalAlignment = UIViewContentModeLeft;
    [leftBtn setTitle:@"减小" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(onDecrease) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    UIProgressView *progressView = [[UIProgressView alloc] init];
    progressView.frame = (CGRect){70, 35, self.view.bounds.size.width-190, 30};
//    [progressView addTarget:self action:@selector(openURLContainingAPP) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:progressView];
    
    UILabel *showL = [[UILabel alloc] init];
    showL.frame = (CGRect){self.view.bounds.size.width-120, 20, 50, 30};
    showL.text = @"30%";
    showL.textColor = [UIColor blackColor];
    showL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:showL];
    self.showL = showL;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = (CGRect){self.view.bounds.size.width-65, 20, 50, 30};
    rightBtn.contentHorizontalAlignment = UIViewContentModeRight;
    [rightBtn setTitle:@"增加" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onIncrease) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openBtn.frame = (CGRect){0, 0, 50, 30};
    openBtn.center = (CGPoint){self.view.center.x, 85};
    openBtn.contentHorizontalAlignment = UIViewContentModeLeft;
    [openBtn setTitle:@"打开" forState:UIControlStateNormal];
    [openBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [openBtn addTarget:self action:@selector(openURLContainingAPP) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openBtn];
    
    [self setPreferredContentSize:CGSizeMake(0, 100)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.showL.text = [NSString stringWithFormat:@"%d", [self getVolume]];
}

//1.调整Widget的高度
-(void)awakeFromNib {
    [super awakeFromNib];
    [self setPreferredContentSize:CGSizeMake(0, 100)];
}

//取消widget默认的inset，让应用靠左
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

// 打开containingApp
-(void)openURLContainingAPP
{
    [self.extensionContext openURL:[NSURL URLWithString:@"TodayURLHttp://action=GotoHomePage"] // lecoding
                 completionHandler:^(BOOL success) {
                     NSLog(@"open url result:%d",success);
                 }];
}

// 增加
-(void)onIncrease
{
    NSInteger volume = [self getVolume];
    volume++;
    [self setVolume:volume]; // 保存数据到共享沙盒中
    NSLog(@"volume: %d", [self getVolume]); // 从共享沙盒中获取数据
    self.showL.text = [NSString stringWithFormat:@"%d", [self getVolume]];
}

- (void)onDecrease
{
    NSInteger volume = [self getVolume];
    if (volume > 0) {
        volume--;
        [self setVolume:volume]; // 保存数据到共享沙盒中
        NSLog(@"volume: %d", [self getVolume]); // 从共享沙盒中获取数据
        self.showL.text = [NSString stringWithFormat:@"%d", [self getVolume]];
    }
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

//1、容器App设置定时器去轮询共享数据，一旦发生变化，就相应地改变音量。
//2、扩展发送请求到服务器，服务器再通知容器App。

//3.它就是 CFNotificationCenterGetDarwinNotifyCenter！这是CoreFoundation库中一个系统级的通知中心，苹果的系统自己也在用它，看清了“Darwin””了没有？哈哈！看了下CFNotificationCenter相关的API，跟NSNotificationCenter有点像。需要用到Toll-Bridge的知识与CoreFoundation相关的类进行桥接，这虽不常用但也不难。还需要注意下个别参数的使用。
// 接受不到数据，扩展发送通知前先存储数据，容器App接收到通知后，再读取共享数据那就好了
// 发送通知
- (void)postNotificaiton
{
    CFNotificationCenterRef notification = CFNotificationCenterGetDarwinNotifyCenter ();
    CFNotificationCenterPostNotification(notification, CFSTR("通知名"), NULL, NULL, YES);
//    CFNotificationCenterPostNotification(notification, CFSTR("通知名"), NULL, 数据, YES);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
