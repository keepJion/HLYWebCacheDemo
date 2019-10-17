//
//  WKWebView+ReusableExtension.m
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/10.
//  Copyright © 2019 HAND. All rights reserved.
//

#import "WKWebView+ReusableExtension.h"
#import <objc/runtime.h>

@interface HLYWeakWrapper : NSObject

@property (nonatomic, weak) NSObject *holderObj;

@end

@implementation HLYWeakWrapper

@end

@implementation WKWebView (ReusableExtension)

- (void)setHolderObject:(NSObject *)holderObject {
    HLYWeakWrapper *wrapper = objc_getAssociatedObject(self, @selector(holderObject));
    if (!wrapper) {
        wrapper = [[HLYWeakWrapper alloc] init];
        wrapper.holderObj = holderObject;
        objc_setAssociatedObject(self, @selector(holderObject), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else {
        wrapper.holderObj = holderObject;
    }
}

- (NSObject *)holderObject {
    HLYWeakWrapper *wrapper = objc_getAssociatedObject(self, @selector(holderObject));
    return wrapper.holderObj;
}



//执行 js 代码
- (void)safeEvaluateJavaScript:(NSString *)script {
    [self safeEvaluateJavaScript:script completionBlock:nil];
}

- (void)safeEvaluateJavaScript:(NSString *)script completionBlock:(_HLYCompletionBlock)completion {
    if (!script || script.length <= 0) {
        if (completion) {
            completion(@"");
        }
        return;
    }
    
    [self evaluateJavaScript:script completionHandler:^(id result, NSError * _Nullable error) {
        //retain self
        __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain = self;
        if (!error) {
            NSObject *backResult = @"";
            if (!result && [result isKindOfClass:[NSNull class]]) {
                backResult = @"";
            }else if (!result && [result isKindOfClass:[NSNumber class]]) {
                backResult = ((NSNumber *)result).stringValue;
            }else if (!result && [result isKindOfClass:[NSObject class]]) {
                backResult = result;
            }else {
                NSLog(@"evaluate back class:%@, value:%@",NSStringFromClass([result class]),result);
            }
            completion(backResult);
        } else {
            NSLog(@"evaluate error : %@, and js : %@",error.description,script);
            completion(@"");
        }
    }];
}

- (NSMutableDictionary *)cookieDicInfo {
    return objc_getAssociatedObject(self, @selector(cookieDicInfo));
}

- (void)setCookieDicInfo:(NSMutableDictionary *)dicInfo {
    objc_setAssociatedObject(self, @selector(cookieDicInfo), dicInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//设置cookie
- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expriesDate:(NSDate *)expriesDate
          completionBlcok:(_HLYCompletionBlock)completion {
    if (!name || name.length <= 0) return;
    
    NSMutableString *cookieString = [[NSMutableString alloc] init];
    [cookieString appendFormat:@"document.cookie='%@=%@;",name,value];
    if (domain && domain.length > 0) {
        [cookieString appendFormat:@"domain=%@;",domain];
    }
    if (path && path.length > 0) {
        [cookieString appendFormat:@"path=%@;",path];
    }
    
    if (![self cookieDicInfo]) {
        self.cookieDicInfo = @{}.mutableCopy;
    }
    [[self cookieDicInfo] setValue:cookieString.copy forKey:name];
    
    if (expriesDate && [expriesDate timeIntervalSince1970] != 0) {
        [cookieString appendFormat:@"expires='+(new Date(%@).toUTCString());",@([expriesDate timeIntervalSince1970] * 1000)];
    }else {
        [cookieString appendFormat:@"'"];
    }
    
    [cookieString appendFormat:@"\n"];
    
    [self safeEvaluateJavaScript:cookieString completionBlock:completion];
}

//根据name删除对应cookie
- (void)deleteCookieWithName:(NSString *)name
             completionBlock:(_HLYCompletionBlock)completionBlock {
    if (!name || name.length <= 0) return;
    
    if (![[[self cookieDicInfo] allKeys] containsObject:name]) return;
    
    NSMutableString *cookieStr = [[NSMutableString alloc] init];
    [cookieStr appendFormat:@"document.cookie='expires='+(new Date(%@).toUTCString());\n",@(0)];
    
    [[self cookieDicInfo] removeObjectForKey:name];
    
    [self safeEvaluateJavaScript:name completionBlock:completionBlock];
}

//获取所有自定义cookie name
- (NSSet <NSString *> *)getAllCustomCookieNames {
    return [[self cookieDicInfo] allKeys].copy;
}

//删除所有自定义cookie
- (void)deleteAllCustomCookies {
    for (NSString *name in [[self cookieDicInfo] allKeys]) {
        [self deleteCookieWithName:name completionBlock:nil];
    }
}

//设置自定义 UA
+ (void)configCustomUAWithType:(HLYUAConfigType)type UAString:(NSString *)UAString {
    if (!UAString || UAString.length <= 0) return;
    
    if (type == kHLYUAConfigTypeReplace) {
        NSDictionary *uadic = [NSDictionary dictionaryWithObjectsAndKeys:UAString, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:uadic];
    }else if (type == kHLYUAConfigTypeAppend) {
        NSString *originUserAgent;
        WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectZero];
        SEL privateUA = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@",@"_",@"user",@"Agent"]);
        if ([webview respondsToSelector:privateUA]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            originUserAgent = [webview performSelector:privateUA];
#pragma clang diagnostic pop
        }
        
        //优先使用wkwebview 防止iOS12 uiwebview crash
        if (!originUserAgent || originUserAgent.length <= 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            UIWebView *webView;
            @try {
                webView = [[UIWebView alloc] initWithFrame:CGRectZero];
#pragma clang diagnostic pop
            } @catch (NSException *exception) {
                
            }
            originUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        }
        NSString *appUserAgent = [NSString stringWithFormat:@"%@-%@",originUserAgent,UAString];
        NSDictionary *uaDic = [NSDictionary dictionaryWithObjectsAndKeys:appUserAgent,@"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:uaDic];
    }else {
        NSLog(@"unsupport useragent type");
    }
}

static inline void clearWebViewCacheFolderByType(NSString *type) {
    static NSDictionary *cacheMapPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *storageFileBasePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"WebKit/%@/WebsiteData/",bundleId]];
        cacheMapPath = @{
                         @"WKWebsiteDataTypeCookies":[libraryPath stringByAppendingPathComponent:@"Cookies/Cookies.binarycookies"],
                         @"WKWebsiteDataTypeLocalStorage":[storageFileBasePath stringByAppendingPathComponent:@"LocalStorage"],
                         @"WKWebsiteDataTypeIndexedDBDatabases":[storageFileBasePath stringByAppendingPathComponent:@"IndexedDB"],
                         @"WKWebsiteDataTypeWebSQLDatabases":[storageFileBasePath stringByAppendingPathComponent:@"WebSQL"],
                         };
    });
    
    NSString *filePath = [cacheMapPath objectForKey:type];
    if (filePath && filePath.length > 0) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
}

//删除缓存
+ (void)safeClearAllCacheIncludeiOS8:(BOOL)included {
    
    if (@available(iOS 9.0, *)) {
        NSSet *dataType = [NSSet setWithObjects:
                           WKWebsiteDataTypeCookies,
                           WKWebsiteDataTypeSessionStorage,
                           WKWebsiteDataTypeMemoryCache,
                           WKWebsiteDataTypeDiskCache,
                           WKWebsiteDataTypeOfflineWebApplicationCache,
                           WKWebsiteDataTypeLocalStorage,
                           WKWebsiteDataTypeIndexedDBDatabases,
                           WKWebsiteDataTypeWebSQLDatabases,
                           nil];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:dataType modifiedSince:[NSDate dateWithTimeIntervalSince1970:0] completionHandler:^{
            
        }];
    } else {
        if (included) {
            NSSet *cacheTypes = [NSSet setWithArray:@[
                                                      @"WKWebsiteDataTypeCookies",
                                                      @"WKWebsiteDataTypeLocalStorage",
                                                      @"WKWebsiteDataTypeIndexedDBDatabases",
                                                      @"WKWebsiteDataTypeWebSQLDatabases"
                                                      ]];
            for (NSString *type in cacheTypes) {
                clearWebViewCacheFolderByType(type);
            }
        }
    }
}

//fix webview 页面menuItem
+ (void)fixWKWebViewMenuItems {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@",@"W",@"K",@"Content",@"View"]);
        if (cls) {
            SEL fixSel = @selector(canPerformAction:withSender:);
            Method method = class_getInstanceMethod(cls, fixSel);
            
            NSAssert(method != NULL, @"selector %@ not found in %@ methods of class %@",NSStringFromSelector(fixSel),class_isMetaClass(cls)?@"class":@"instance",cls);
            
            IMP originIMP = method_getImplementation(class_getInstanceMethod(cls, fixSel));
            BOOL (*originalImplemention_)(__unsafe_unretained id, SEL, SEL, id);
            
            IMP newIMP = imp_implementationWithBlock(^BOOL(__unsafe_unretained id self, SEL action, id sender) {
                if (action == @selector(copy:) || action == @selector(cut:) || action == @selector(paste:) || action == @selector(delete:)) {
                    return ((__typeof(originalImplemention_))originIMP)(self, fixSel, action, sender);
                }else {
                    return NO;
                }
            });
            class_replaceMethod(cls, fixSel, newIMP, method_getTypeEncoding(method));
        }else {
            NSLog(@"not found class %@.",cls);
        }
    });
}

//禁用webview 双击事件
+ (void)disableWebviewDoubleClick {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString([NSString stringWithFormat:@"%@%@%@%@",@"W",@"K",@"Content",@"View"]);
        if (cls) {
            SEL fixSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@",@"_non",@"Blocking",@"DoubleTap",@"Recognized:"]);
            Method method = class_getInstanceMethod(cls, fixSel);
            
            NSAssert(NULL != method, @"selector %@ not found in %@ method of class %@.",NSStringFromSelector(fixSel),class_isMetaClass(cls) ? @"class" : @"instance", cls);
            
            IMP newIMP = imp_implementationWithBlock( ^void(id _self, UITapGestureRecognizer *gestureRecognizer){
                //do nothing
            });
            
            class_replaceMethod(cls, fixSel, newIMP, method_getTypeEncoding(method));
        }else {
            NSLog(@"no found class.");
        }
    });
}

//清理webview页面堆栈
- (void)clearAllBackForwardList {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL backForwardSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@",@"_re",@"moveA",@"llIt",@"ems"]);
    if ([self.backForwardList respondsToSelector:backForwardSel]) {
        [self.backForwardList performSelector:backForwardSel];
    }
#pragma clang diagnostic pop
}


@end
