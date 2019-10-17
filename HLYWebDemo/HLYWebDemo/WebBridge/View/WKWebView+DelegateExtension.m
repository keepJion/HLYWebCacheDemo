//
//  WKWebView+DelegateExtension.m
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/14.
//  Copyright © 2019 HAND. All rights reserved.
//

#import "WKWebView+DelegateExtension.h"
#import <objc/runtime.h>
#import "WKWebView+ReusableExtension.h"

@interface _WKDelegateDispatcher : NSObject<WKNavigationDelegate,WKUIDelegate>

@property (nonatomic, weak) id<WKNavigationDelegate> mainNavigationDelegate;
@property (nonatomic, strong) NSHashTable *weakNavigationDelegates;

- (void)addNavigationDelegate:(id <WKNavigationDelegate>)delegate;
- (void)deleteNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (BOOL)containNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)removeAllNavigationDelegates;
@end

@implementation _WKDelegateDispatcher


- (instancetype)init
{
    if (self = [super init]) {
        _weakNavigationDelegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

- (void)addNavigationDelegate:(id <WKNavigationDelegate>)delegate {
    if (!delegate && ![self.weakNavigationDelegates containsObject:delegate]) {
        [self.weakNavigationDelegates addObject:delegate];
    }
}

- (void)deleteNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    if (delegate) {
        [self.weakNavigationDelegates removeObject:delegate];
    }
}

- (BOOL)containNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    return delegate ? [self.weakNavigationDelegates containsObject:delegate] : false;
}

- (void)removeAllNavigationDelegates {
    
    [_weakNavigationDelegates removeAllObjects];
}

//MARK: WKNavigationDelegate
- (void)                    webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    __block BOOL isResponse = NO;
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        isResponse = YES;
    }else {
        for (id<WKNavigationDelegate>delegate in _weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
                isResponse = YES;
            }
        }
    }
    if (!isResponse) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)                    webView:(WKWebView *)webView
  decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                    decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)                    webView:(WKWebView *)webView
                didCommitNavigation:(WKNavigation *)navigation {
    id<WKNavigationDelegate>mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didCommitNavigation:navigation];
    }else {
        for (id<WKNavigationDelegate>delegate in _weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView didCommitNavigation:navigation];
            }
        }
    }
}

- (void)                    webView:(WKWebView *)webView
      didStartProvisionalNavigation:(WKNavigation *)navigation {
    id<WKNavigationDelegate>mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didStartProvisionalNavigation:navigation];
    }else {
        for (id<WKNavigationDelegate>delegate in _weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView didStartProvisionalNavigation:navigation];
            }
        }
    }
}

- (void)                    webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    id<WKNavigationDelegate>mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }else {
        for (id<WKNavigationDelegate>delegate in _weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
            }
        }
    }
}

- (void)                        webView:(WKWebView *)webView
                    didFinishNavigation:(WKNavigation *)navigation {
    
    id<WKNavigationDelegate>mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFinishNavigation:navigation];
    }else {
        for (id<WKNavigationDelegate>delegate in _weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView didFinishNavigation:navigation];
            }
        }
    }
}

- (void)                    webView:(WKWebView *)webView
                  didFailNavigation:(WKNavigation *)navigation
                          withError:(NSError *)error {
    id<WKNavigationDelegate>mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFailNavigation:navigation withError:error];
    }else {
        for (id<WKNavigationDelegate>delegate in _weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView didFailNavigation:navigation withError:error];
            }
        }
    }
}

- (void)                    webView:(WKWebView *)webView
       didFailProvisionalNavigation:(WKNavigation *)navigation
                          withError:(NSError *)error {
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFailProvisionalNavigation:navigation withError:error];
        }
    }
}

- (void)                    webView:(WKWebView *)webView
  didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    __block BOOL isResponse = NO;
    id<WKNavigationDelegate>mainDelegate = self.mainNavigationDelegate;
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
        isResponse = YES;
    }else {
        for (id<WKNavigationDelegate>delegate in self.weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
                isResponse = YES;
            }
        }
    }
    if (!isResponse) {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    if (@available(iOS 9.0,*)) {
        id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
        if ([mainDelegate respondsToSelector:_cmd]) {
            [mainDelegate webViewWebContentProcessDidTerminate:webView];
        }
        for (id delegate in self.weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webViewWebContentProcessDidTerminate:webView];
            }
        }
    }
}

//MARK: WKUIDelegate
- (BOOL)_canShowPanelWithWebView:(WKWebView *)webView {
    if ([webView.holderObject isKindOfClass:[UIViewController class]]) {
        UIViewController *ctrl = (UIViewController *)webView.holderObject;
        if (ctrl.isBeingDismissed || ctrl.isBeingPresented || ctrl.isMovingToParentViewController || ctrl.isMovingFromParentViewController) {
            return false;
        }
    }
    return true;
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.mainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    if (![self _canShowPanelWithWebView:webView]) {
        completionHandler();
        return;
    }
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    if ([self _topPresentedViewController].presentingViewController) {
        completionHandler();
    }else {
        [[self _topPresentedViewController] presentViewController:alertCtrl animated:YES completion:nil];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    if (![self _canShowPanelWithWebView:webView]) {
        completionHandler(false);
        return;
    }
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(true);
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(false);
    }]];
    if ([self _topPresentedViewController].presentingViewController) {
        completionHandler(false);
    }else {
        [[self _topPresentedViewController] presentViewController:alertCtrl animated:true completion:nil];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    if (![self _canShowPanelWithWebView:webView]) {
        completionHandler(nil);
        return;
    }
    NSString *sender = [NSString stringWithFormat:@"%@",webView.URL.host];
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:prompt message:sender preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (alertCtrl.textFields && alertCtrl.textFields.count > 0) {
            UITextField *textfield = alertCtrl.textFields.firstObject;
            if (textfield.text && textfield.text.length > 0) {
                completionHandler(textfield.text);
            }
        }
        completionHandler(nil);
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(false);
    }]];
    
    if ([self _topPresentedViewController].presentingViewController) {
        completionHandler(nil);
    }else {
        [[self _topPresentedViewController] presentViewController:alertCtrl animated:true completion:nil];
    }
}

//MARK: -
- (UIViewController *)_topPresentedViewController {
    UIViewController *viewCtrl = [[UIApplication sharedApplication] keyWindow].rootViewController;
    while (viewCtrl.presentedViewController) {
        viewCtrl = viewCtrl.presentedViewController;
    }
    return viewCtrl;
}

@end

@implementation WKWebView (DelegateExtension)

- (_WKDelegateDispatcher *)delegateDispatcher {
    return objc_getAssociatedObject(self, @selector(delegateDispatcher));
}

- (void)setDelegateDispatcher:(_WKDelegateDispatcher *)delegateDispatcher {
    objc_setAssociatedObject(self, @selector(delegateDispatcher), delegateDispatcher, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)getUseDefaultUIDelegate {
    NSNumber *useDefault = objc_getAssociatedObject(self, @selector(getUseDefaultUIDelegate));
    return [useDefault boolValue];
}

- (void)setUseDefaultUIDelegate:(BOOL)useDefault {
    objc_setAssociatedObject(self, @selector(getUseDefaultUIDelegate), @(useDefault), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)useExternalNavigationDelegateAndWithDefaultUIDelegate:(BOOL)useDefaultUIDelegate {
    if ([self getUseDefaultUIDelegate] && [self delegateDispatcher]) return;
    [self setDelegateDispatcher:[[_WKDelegateDispatcher alloc] init]];
    [self setNavigationDelegate:[self delegateDispatcher]];
    if (useDefaultUIDelegate) {
        [self setUIDelegate:[self delegateDispatcher]];
    }
    [self setUseDefaultUIDelegate:true];
}

- (void)setMainNavigationDelegate:(NSObject<WKNavigationDelegate> *)mainDelegate {
    [[self delegateDispatcher] setMainNavigationDelegate:mainDelegate];
}

- (void)addSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)secondaryDelegate {
    [[self delegateDispatcher] addNavigationDelegate:secondaryDelegate];
}


- (void)removeSecondaryNavigationDelegate:(NSObject<WKNavigationDelegate> *)secondaryDelegate {
    [[self delegateDispatcher] deleteNavigationDelegate:secondaryDelegate];
}

- (void)removeAllSecondaryNavigationDelegates {
    [[self delegateDispatcher] removeAllNavigationDelegates];
}

@end
