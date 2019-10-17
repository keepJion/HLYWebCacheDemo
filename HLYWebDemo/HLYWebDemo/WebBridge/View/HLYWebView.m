//
//  HLYWebView.m
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/10.
//  Copyright © 2019 HAND. All rights reserved.
//

#import "HLYWebView.h"
#import "HLYWebViewPool.h"
#import "VKMsgSend.h"

@interface HLYWebMessageHandle ()

@property (nonatomic, strong) NSMutableDictionary *targetRetainList;

@end

@implementation HLYWebMessageHandle

- (NSMutableDictionary *)targetRetainList {
    if (_targetRetainList == nil) {
        _targetRetainList = [[NSMutableDictionary alloc] init];
    }
    return _targetRetainList;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kMessageHandleName]) {
        if (![message.body isKindOfClass:[NSDictionary class]]) return;
        NSDictionary *bodyInfo = (NSDictionary *)message.body;
        NSString* className = bodyInfo[@"className"];
        NSString *methodName = bodyInfo[@"methodName"];
        NSDictionary *params = bodyInfo[@"params"];
        NSString *callBackName = bodyInfo[@"callBackID"];
        NSString *failBackName = bodyInfo[@"failBackID"];
        __weak WKWebView *webView = [message webView];
        [self web_sendMsgWithClassName:className methodName:methodName params:params sucCallBack:^(id response) {
            [self web_evaluateCallBackWithID:callBackName response:response webView:webView];
        } failCallBack:^(id response) {
            [self web_evaluateCallBackWithID:failBackName response:response webView:webView];
        }];
    }
}

//发送消息给对应类
- (void)web_sendMsgWithClassName:(NSString *)clsName
                      methodName:(NSString *)methodName
                          params:(id)params
                   sucCallBack:(void(^)(id response))sucCallBack
                  failCallBack:(void(^)(id response))failCallBack {
    
    if (!clsName || clsName.length <= 0) return;
    
    id target = [self.targetRetainList objectForKey:clsName];
    if (!target) {
        Class cls = NSClassFromString(clsName);
        target = [[cls alloc] init];
        [self.targetRetainList setValue:target forKey:clsName];
    }
    NSError *error;
    NSString *selName = [NSString stringWithFormat:@"%@:::",methodName];
    [target VKCallSelector:NSSelectorFromString(selName) error:&error,params,sucCallBack,failCallBack];
}

//执行js回调函数
- (void)web_evaluateCallBackWithID:(NSString *)callId response:(id)response webView:(WKWebView *)webView {
    if ([response isKindOfClass:[NSDictionary class]] || [response isKindOfClass:NSArray.class]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
        response = [[NSString alloc] initWithData:data?:[NSData data] encoding:NSUTF8StringEncoding];
        response = [response stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    [webView safeEvaluateJavaScript:[NSString stringWithFormat:@"HandBridge.callBack('%@','%@')",callId,response] completionBlock:^(NSObject *obj) {

    }];
}

@end

@interface HLYWebView ()

@end

@implementation HLYWebView



@end


@implementation HLYWebView (HLYReusable)

- (void)webViewWillEnterPool {
    
    self.holderObject = nil;
    NSString *reuseLoadUrl = [HLYWebViewPool shareInstance].webReuseLoadUrl;
    if (reuseLoadUrl && reuseLoadUrl.length > 0) {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:reuseLoadUrl]]];
    }else {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    }
}

- (void)webViewWillLeavePool {
    
    [self clearAllBackForwardList];
}

@end
