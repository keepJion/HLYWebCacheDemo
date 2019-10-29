//
//  HLYBridgeDemo.m
//  HLYWebDemo
//
//  Created by codesign on 2019/10/15.
//  Copyright © 2019 codesign. All rights reserved.
//

#import "HLYBridgeDemo.h"
#import "HLYHybridController.h"

@implementation HLYBridgeDemo

@end

@implementation NSObject (CtrlTool)

- (UIViewController *)getCurrentViewController:(UIViewController *)viewCtrl {
    UIViewController *vc = nil;
    if (viewCtrl == nil) {
        viewCtrl = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    if ([viewCtrl isKindOfClass:[UITabBarController class]]) {
       return [self getCurrentViewController:[(UITabBarController *)viewCtrl selectedViewController]];
    }
    else if ([viewCtrl isKindOfClass:[UINavigationController class]]) {
        return [self getCurrentViewController:[(UINavigationController *)viewCtrl visibleViewController]];
    }else {
        vc = viewCtrl;
    }
//    while (viewCtrl.presentedViewController) {
//        vc = viewCtrl.presentedViewController;
//    }
    return vc;
}

@end


@implementation ToolBarBridge

//设置导航title
- (void)changeToolBar:(id)params :(void(^)(id responses))successBack :(void(^)(id response))failureBack {
    NSString *title = params[@"title"];
//    NSString *color = params[@"color"];
    UIViewController *ctrl = [self getCurrentViewController:nil];
    ctrl.title = title;
    successBack(@{@"result":@(true)});
}

@end


@implementation WebViewBridge

//关闭当前webview Ctrl
- (void)close_webview:(id)params :(void(^)(id response))successBack :(void(^)(id response))failureBack {
    UIViewController *ctrl = [self getCurrentViewController:nil];
    [ctrl.navigationController popViewControllerAnimated:true];
    
    successBack(@{@"result":@(true)});
}

//打开新的webview Ctrl
- (void)new_webView:(id)params :(void(^)(id response))successBack :(void(^)(id response))failureBack {
    NSArray *list = @[@"https://www.qq.com",@"https://www.baidu.com",@"https://www.alipay.com"];
    NSInteger index = arc4random() % 3;
//    NSString *url = params[@"url"];
    UIViewController *ctrl = [self getCurrentViewController:nil];
    HLYHybridController *hlyCtrl = [[HLYHybridController alloc] init];
    [hlyCtrl hly_bindWebViewLoadUrl:list[index] isLocal:false];
    hlyCtrl.title = @"New Webview";
    [ctrl.navigationController pushViewController:hlyCtrl animated:true];
    
    successBack(@{@"result":@(true)});
}

@end


@implementation WeixinBridge

//获取微信电子票信息
- (void)chooseInvoiceTicket:(id)params :(void (^)(id))successBack :(void (^)(id))failureBack {
//    NSString *appid = params[@"appId"]?:@"wx82a1dd12c4147742";
//    [WXApi registerApp:appid enableMTA:YES];
//    WXChooseCardReq *chooseReq = [[WXChooseCardReq alloc] init];
//    chooseReq.appID = appid;
//    chooseReq.cardSign = params[@"cardSign"];
//    chooseReq.nonceStr = params[@"nonceStr"];
//    chooseReq.signType = @"SHA1";
//    chooseReq.timeStamp = [params[@"timestamp"] integerValue];
//    [WXApi sendReq:chooseReq];
}

@end
