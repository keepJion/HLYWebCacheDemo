//
//  WKWebView+DelegateExtension.h
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/14.
//  Copyright © 2019 HAND. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (DelegateExtension)

//设置Navigation Delegate 、 useDefaultUIDelegate 是否使用默认代理
- (void)useExternalNavigationDelegateAndWithDefaultUIDelegate:(BOOL)useDefaultUIDelegate;
//设置Navigation Delegate
- (void)setMainNavigationDelegate:(NSObject <WKNavigationDelegate> *)mainDelegate;

- (void)addSecondaryNavigationDelegate:(NSObject <WKNavigationDelegate> *)secondaryDelegate;

- (void)removeSecondaryNavigationDelegate:(NSObject <WKNavigationDelegate> *)secondaryDelegate;

- (void)removeAllSecondaryNavigationDelegates;

@end

NS_ASSUME_NONNULL_END
