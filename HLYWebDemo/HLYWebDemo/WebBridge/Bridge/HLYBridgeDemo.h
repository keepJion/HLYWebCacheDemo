//
//  HLYBridgeDemo.h
//  HLYWebDemo
//
//  Created by codesign on 2019/10/15.
//  Copyright © 2019 codesign. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HLYBridgeDemo : NSObject

@end

@interface NSObject (CtrlTool)

- (UIViewController *)getCurrentViewController:(UIViewController *)viewCtrl;

@end

@interface ToolBarBridge : NSObject

//设置导航title
- (void)changeToolBar:(id)params :(void(^)(id responses))successBack :(void(^)(id response))failureBack;

@end

@interface WebViewBridge : NSObject

- (void)close_webview:(id)params :(void(^)(id response))successBack :(void(^)(id response))failureBack;

- (void)new_webView:(id)params :(void(^)(id response))successBack :(void(^)(id response))failureBack;
@end


//获取微信电子票
@interface WeixinBridge : NSObject

- (void)chooseInvoiceTicket:(id)params :(void(^)(id responses))successBack :(void(^)(id response))failureBack;

@end
