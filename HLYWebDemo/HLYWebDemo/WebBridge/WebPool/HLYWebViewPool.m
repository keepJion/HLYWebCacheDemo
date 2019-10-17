//
//  HLYWebViewPool.m
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/10.
//  Copyright © 2019 HAND. All rights reserved.
//

#import "HLYWebViewPool.h"
#import "WKWebView+ReusableExtension.h"

@interface HLYWebViewPool ()
// 多webview 缓存池
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet<HLYWebView *> *> *mutqueueWebViews;

//
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet<HLYWebView *> *> *dequeueWebViews;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet<HLYWebView *> *> *enqueueWebViews;

@property (nonatomic, strong) dispatch_semaphore_t lock;
@property (nonatomic, strong) HLYWebMessageHandle *msgHandle;
@end

@implementation HLYWebViewPool

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dequeueWebViews = @{}.mutableCopy;
        self.enqueueWebViews = @{}.mutableCopy;
        self.mutqueueWebViews = @{}.mutableCopy;
        self.globalProcessPool = [[WKProcessPool alloc] init];
        self.msgHandle = [[HLYWebMessageHandle alloc] init];
        self.webReuseLoadUrl = @"";
        _lock = dispatch_semaphore_create(1);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearAllReusableWebView)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dequeueWebViews removeAllObjects];
    [self.enqueueWebViews removeAllObjects];
    [self.mutqueueWebViews removeAllObjects];
    self.dequeueWebViews = nil;
    self.enqueueWebViews = nil;
    self.mutqueueWebViews = nil;
}

+ (HLYWebViewPool *)shareInstance {
    static HLYWebViewPool *webPool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webPool = [[HLYWebViewPool alloc] init];
    });
    return webPool;
}

//多webview缓存 通过webkey 唯一key来获取对应webview
- (HLYWebView *)dequeueWebViewWithKey:(NSString *)webKey webViewClass:(Class)webViewClass webHolder:(NSObject *)webHolder {
    if (!webKey || webKey.length <= 0) {
        return nil;
    }
    HLYWebView *webView = [self _getMutCacheWebViewWithKey:webKey webviewClass:webViewClass];
    webView.holderObject = webHolder;
    return webView;
}

//从缓存池中获取webview
- (HLYWebView *)dequeueWebViewWithClass:(Class)webViewClass webHolder:(NSObject *)webHolder {
    if (![webViewClass isSubclassOfClass:HLYWebView.class]) {
        return nil;
    }
    //销毁已经没有被持有的webview
    [self _tryCompactWeakHolderOfWebView];
    HLYWebView *webview = [self _getWebViewWithClass:webViewClass];
    webview.holderObject = webHolder;
    return webview;
}

//回收可复用的webview
- (void)enqueueWebView:(HLYWebView *)webView {
    if (!webView) {
        return;
    }
    //FIXME: -如果缓存池中webview过多需要做限制就不放入缓存池
//    [self removeReusableWebView:webView];
    //如果缓存池中webview个数没有超过限制 就放入缓存池中
    [self _recycleWebView:webView];
}

//清除复用池中 指定class的webview
- (void)clearReusableWebViewWithClass:(Class)webViewClass {
    NSString *classStr = NSStringFromClass(webViewClass);
    if (!classStr || classStr.length <= 0) {
        return;
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([self.enqueueWebViews.allKeys containsObject:classStr]) {
        [self.enqueueWebViews removeObjectForKey:classStr];
    }
    dispatch_semaphore_signal(_lock);
}

//销毁复用池中的webview
- (void)removeReusableWebView:(WKWebView *)webView {
    
    NSString *classStr = NSStringFromClass([webView class]);
    if (!classStr || classStr.length <= 0) {
        return;
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([self.dequeueWebViews.allKeys containsObject:classStr]) {
        NSMutableSet *viewSet = [self.dequeueWebViews objectForKey:classStr];
        [viewSet removeObject:webView];
    }
    if ([self.enqueueWebViews.allKeys containsObject:classStr]) {
        NSMutableSet *viewSet = [self.enqueueWebViews objectForKey:classStr];
        [viewSet removeObject:webView];
    }
    dispatch_semaphore_signal(_lock);
    
}

//清空所有可复用的webView
- (void)clearAllReusableWebView {
    [self _tryCompactWeakHolderOfWebView];
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.enqueueWebViews removeAllObjects];
    [self.mutqueueWebViews removeAllObjects];
    dispatch_semaphore_signal(_lock);
}

//MARK: -privates
//清除缓存池中已经不被持有的webview
- (void)_tryCompactWeakHolderOfWebView {
    NSDictionary<NSString *, NSMutableSet<HLYWebView *> *> *dequeueTemp = self.dequeueWebViews.copy;
    [dequeueTemp enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableSet<HLYWebView *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSSet *set = obj.copy;
        [set enumerateObjectsUsingBlock:^(HLYWebView * _Nonnull web, BOOL * _Nonnull stop) {
            if (!web.holderObject) {
                [self enqueueWebView:web];
            }
        }];
    }];
}

//
- (void)_recycleWebView:(HLYWebView *)webView {
    if (!webView) {
        return;
    }
    if ([webView respondsToSelector:@selector(webViewWillEnterPool)]) {
        [webView webViewWillEnterPool];
    }
    
    NSString *classStr = NSStringFromClass([webView class]);
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([self.dequeueWebViews.allKeys containsObject:classStr]) {
        NSMutableSet *viewSet = [self.dequeueWebViews objectForKey:classStr];
        [viewSet removeObject:webView];
    } else {
        dispatch_semaphore_signal(_lock);
    }
    
    if ([self.enqueueWebViews.allKeys containsObject:classStr]) {
        NSMutableSet *viewSet = [self.enqueueWebViews objectForKey:classStr];
        [viewSet addObject:webView];
    } else {
        NSMutableSet *viewSet = [[NSMutableSet alloc] init];
        [viewSet addObject:webView];
        [self.enqueueWebViews setObject:viewSet forKey:classStr];
    }
    
    dispatch_semaphore_signal(_lock);
}

//获取缓存池中的webview
- (HLYWebView *)_getWebViewWithClass:(Class)webViewClass {
    
    NSString *classStr = NSStringFromClass(webViewClass);
    if (!classStr || classStr.length <= 0) {
        return nil;
    }
    
    HLYWebView *webView;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if ([self.enqueueWebViews.allKeys containsObject:classStr]) {
        NSMutableSet *set = [self.enqueueWebViews objectForKey:classStr];
        if (set && set.count > 0) {
            webView = [set anyObject];
            if (![webView isMemberOfClass:webViewClass]) {
                return nil;
            }
            [set removeObject:webView];
        }
    }else {
        dispatch_semaphore_signal(_lock);
    }
    
    if (webView == nil) {
        webView = [[webViewClass alloc] initWithFrame:CGRectZero configuration:[self configWebView]];
    }
    
    if ([self.dequeueWebViews.allKeys containsObject:classStr]) {
        NSMutableSet *viewSet = [self.dequeueWebViews objectForKey:classStr];
        [viewSet addObject:webView];
    } else {
        NSMutableSet *viewSet = [[NSMutableSet alloc] init];
        [viewSet addObject:webView];
        [self.dequeueWebViews setObject:viewSet forKey:classStr];
    }
    dispatch_semaphore_signal(_lock);
    
    if ([webView respondsToSelector:@selector(webViewWillLeavePool)]) {
        [webView webViewWillLeavePool];
    }
    
    return webView;
}

//通过key获取多缓存中的webview
- (HLYWebView *)_getMutCacheWebViewWithKey:(NSString *)webKey webviewClass:(Class)webViewClass {
    
    if ([self.mutqueueWebViews.allKeys containsObject:webKey]) {
        NSMutableSet *viewSet = [self.mutqueueWebViews objectForKey:webKey];
        return [viewSet anyObject];
    } else {
        if (self.mutqueueWebViews.allKeys.count > self.maxCacheCount) {
            NSString *firstKey = self.mutqueueWebViews.allKeys.firstObject;
            [self.mutqueueWebViews removeObjectForKey:firstKey];
        }
        NSMutableSet *webSet = [[NSMutableSet alloc] init];
        HLYWebView *webView = [[webViewClass alloc] initWithFrame:CGRectZero configuration:[self configWebView]];
        [webSet addObject:webView];
        [self.mutqueueWebViews setObject:webSet forKey:webKey];
        return webView;
    }
}

- (NSString *)evaluateJSString {
    NSString *jsPath = [[NSBundle mainBundle] pathForResource:@"HLYEventHandler.js" ofType:nil];
    NSString *jsStr = [NSString stringWithContentsOfFile:jsPath encoding:kCFStringEncodingUTF8 error:nil];
    jsStr = [jsStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return jsStr;
}

- (WKWebViewConfiguration *)configWebView {
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    //偏好设置
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    //web内容处理池  共享
    config.processPool = [HLYWebViewPool shareInstance].globalProcessPool;
    
    //
    WKUserScript *baseScript = [[WKUserScript alloc] initWithSource:[self evaluateJSString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:false];
    config.userContentController = [[WKUserContentController alloc] init];
    [config.userContentController addUserScript:baseScript];
    [config.userContentController addScriptMessageHandler:self.msgHandle name:kMessageHandleName];
    //    [config setURLSchemeHandler:<#(nullable id<WKURLSchemeHandler>)#> forURLScheme:<#(nonnull NSString *)#>]
    return config;
}

@end
