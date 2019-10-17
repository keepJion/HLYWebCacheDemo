//
//  HLYHybridController.m
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/11.
//  Copyright © 2019 HAND. All rights reserved.
//

#import "HLYHybridController.h"
#import "HLYWebViewPool.h"


@interface HLYHybridController ()<WKNavigationDelegate>

@property (nonatomic, strong) HLYWebView *webView;
@property (nonatomic, strong) NSString *webUrl;

@end

@implementation HLYHybridController

- (instancetype)init
{
    if (self = [super init]) {
        self.isEnableSwipe = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.webView];
    [self hly_layoutSubViews];
}

//布局子视图
- (void)hly_layoutSubViews {
    self.navigationController.navigationBar.hidden = self.isHiddenNav;
    CGFloat height = self.navigationController.navigationBar.frame.size.height;
    if (self.isHiddenNav) {
        height = 0.0;
    }
    self.webView.frame = CGRectMake(0, height, self.view.bounds.size.width, self.view.bounds.size.height-height);
    if (self.isEnableSwipe) {
        self.webView.allowsBackForwardNavigationGestures = true;
    }
}

//创建webview
- (void)hly_bindWebViewLoadUrl:(NSString *)url isLocal:(BOOL)isLocal {
    if (isLocal) {
        self.webUrl = [NSString stringWithFormat:@"http://localhost:8080/%@",url];
        NSDictionary *urlParams = [self.webUrl urlSchemeParamsAnlisy];
        if ([self hly_isInCacheList:urlParams[@"hash"]]) {
            self.webView = [[HLYWebViewPool shareInstance] dequeueWebViewWithKey:urlParams[@"hash"] webViewClass:HLYWebView.class webHolder:self];
        } else {
            self.webView = [[HLYWebViewPool shareInstance] dequeueWebViewWithClass:HLYWebView.class webHolder:self];
        }
    }else {
        self.webUrl = url;
        self.webView = [[HLYWebViewPool shareInstance] dequeueWebViewWithClass:[HLYWebView class] webHolder:self];
    }
    [self.webView useExternalNavigationDelegateAndWithDefaultUIDelegate:true];
    [self.webView setMainNavigationDelegate:self];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self.webView loadRequest:request];
}


//MARK: -
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (!navigationAction.targetFrame.mainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (BOOL)hly_isInCacheList:(NSString *)code {
    return [@[@"my-account",
              @"expense-report",
              @"workflow-list",
              @"applylist",
              @"zhenxuan"
              ] containsObject:[code lowercaseString]];
}


- (void)dealloc
{
    [[HLYWebViewPool shareInstance] enqueueWebView:self.webView];
}

@end


@implementation NSString (WebUrl)

- (NSDictionary *)urlSchemeParamsAnlisy {
    NSArray *paramlist = [self componentsSeparatedByString:@"?"];
    NSMutableDictionary *pdic = [NSMutableDictionary dictionary];
    if(paramlist.count == 2) {
        NSString *paramstr = [paramlist lastObject];
        NSArray *exparam = [paramstr componentsSeparatedByString:@"&"];
        for (NSInteger i=0; i<exparam.count; i++) {
            NSString *msparamstr = exparam[i];
            NSArray *mslist = [msparamstr componentsSeparatedByString:@"="];
            [pdic setObject:[mslist lastObject] forKey:[mslist firstObject]];
        }
    }else if (paramlist.count > 2){
        for (NSString *paramstr in paramlist) {
            NSArray *exparam = [paramstr componentsSeparatedByString:@"&"];
            for (NSInteger i=0; i<exparam.count; i++) {
                NSString *msparamstr = exparam[i];
                NSArray *mslist = [msparamstr componentsSeparatedByString:@"="];
                [pdic setObject:[mslist lastObject] forKey:[mslist firstObject]];
            }
        }
    }else{
        NSArray *exparam = [self componentsSeparatedByString:@"&"];
        for (NSInteger i=0; i<exparam.count; i++) {
            NSString *msparamstr = exparam[i];
            NSArray *mslist = [msparamstr componentsSeparatedByString:@"="];
            [pdic setObject:[mslist lastObject] forKey:[mslist firstObject]];
        }
    }
    return pdic;
}

@end
