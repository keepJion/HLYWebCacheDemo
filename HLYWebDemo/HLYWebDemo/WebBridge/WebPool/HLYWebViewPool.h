//
//  HLYWebViewPool.h
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/10.
//  Copyright © 2019 HAND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "HLYWebView.h"
NS_ASSUME_NONNULL_BEGIN

//@protocol HLYWebViewConfigProtocol <NSObject>
//
//
//@optional
////配置webview
//- (WKWebViewConfiguration *)configWebView;
//
//@end

@interface HLYWebViewPool : NSObject 

//多缓存最大容量 默认为6;
@property (nonatomic, assign) NSInteger maxCacheCount;

//共享web内容池
@property (nonatomic, strong) WKProcessPool *globalProcessPool;

//webview进入复用池前加载的url  reuseUrl
@property (nonatomic, strong) NSString *webReuseLoadUrl;

+ (HLYWebViewPool *)shareInstance;

//多webview缓存 通过webkey 唯一key来获取对应webview
- (HLYWebView *)dequeueWebViewWithKey:(NSString *)webKey webViewClass:(Class)webViewClass webHolder:(NSObject *)webHolder;

//从缓存池中获取webview
- (HLYWebView *)dequeueWebViewWithClass:(Class)webViewClass webHolder:(NSObject *)webHolder;

//回收可复用的webview
- (void)enqueueWebView:(HLYWebView *)webView;

//清空所有可复用的webView
- (void)clearAllReusableWebView;

//清除复用池中 指定class的webview
- (void)clearReusableWebViewWithClass:(Class)webViewClass;

//销毁复用池中的webview
- (void)removeReusableWebView:(HLYWebView *)webView;

@end

NS_ASSUME_NONNULL_END
