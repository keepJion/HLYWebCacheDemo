//
//  HLYWebView.h
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/10.
//  Copyright © 2019 HAND. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "WKWebView+ReusableExtension.h"
#import "WKWebView+DelegateExtension.h"
//#define kMessageHandleName @"HLYWebKitHandle"
#define kMessageHandleName @"HandBridge"

@protocol HLYWebReusableProtocol <NSObject>

@optional
- (void)webViewWillLeavePool; //即将离开复用池
- (void)webViewWillEnterPool; //即将进入复用池

@end

@interface HLYWebView : WKWebView


@end

@interface HLYWebView (HLYReusable) <HLYWebReusableProtocol>

@end


@interface HLYWebMessageHandle : NSObject <WKScriptMessageHandler>

@end


