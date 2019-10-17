//
//  WKWebView+ReusableExtension.h
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/10.
//  Copyright © 2019 HAND. All rights reserved.
//

#import <WebKit/WebKit.h>



typedef void(^_HLYCompletionBlock)(NSObject *obj);

typedef NS_ENUM(NSInteger,HLYUAConfigType) {
    kHLYUAConfigTypeReplace,
    kHLYUAConfigTypeAppend
};

@interface WKWebView (ReusableExtension)

@property (nonatomic, weak) NSObject *holderObject;
//是否启用缓存
//@property (nonatomic, assign) BOOL invalid;

//执行 js 代码
- (void)safeEvaluateJavaScript:(NSString *)script;
- (void)safeEvaluateJavaScript:(NSString *)script completionBlock:(_HLYCompletionBlock)completion;

//设置cookie
- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expriesDate:(NSDate *)expriesDate
          completionBlcok:(_HLYCompletionBlock)completion;
//根据name删除对应cookie
- (void)deleteCookieWithName:(NSString *)name
             completionBlock:(_HLYCompletionBlock)completionBlock;

//获取所有自定义cookie name
- (NSSet <NSString *> *)getAllCustomCookieNames;

//删除所有自定义cookie
- (void)deleteAllCustomCookies;

//设置自定义 UA
+ (void)configCustomUAWithType:(HLYUAConfigType)type UAString:(NSString *)UAString;

//删除缓存
+ (void)safeClearAllCacheIncludeiOS8:(BOOL)included;

//fix webview 页面menuItem
+ (void)fixWKWebViewMenuItems;

//禁用webview 双击事件
+ (void)disableWebviewDoubleClick;

//清理webview页面堆栈
- (void)clearAllBackForwardList;

@end


