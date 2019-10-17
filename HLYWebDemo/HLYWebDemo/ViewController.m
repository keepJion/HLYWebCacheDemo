//
//  ViewController.m
//  HLYWebDemo
//
//  Created by codesign on 2019/10/15.
//  Copyright © 2019 codesign. All rights reserved.
//

#import "ViewController.h"
#import "HLYHybridController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)demoOpenWebCtrl:(UIButton *)sender {
    HLYHybridController *ctrl = [[HLYHybridController alloc] init];
    NSArray *list = @[@"https://www.qq.com",@"https://www.baidu.com",@"https://www.alipay.com",@"https://dingtalkstage.huilianyi.com/huilianyi/online/jssdk-demo/index.html"];
    NSInteger index = arc4random() % 4;
    NSString *url = list[index];
    NSLog(@"url is %@",url);
    [ctrl hly_bindWebViewLoadUrl:url isLocal:false];
    [self.navigationController pushViewController:ctrl animated:true];
}


@end
