//
//  HLYHybridController.h
//  HuiLianYiPlatform
//
//  Created by codesign on 2019/10/11.
//  Copyright © 2019 HAND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLYWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HLYHybridController : UIViewController

@property (nonatomic, assign) BOOL isPopCtrl; //点击返回按钮是否直接返回
@property (nonatomic, assign) BOOL isHiddenNav; //是否隐藏导航栏
@property (nonatomic, assign) BOOL isEnableSwipe; //是否开启右滑webView返回

// 绑定url  isLocal：true: 本地链接 需要自己拼接localhost false: 在线页面链接
- (void)hly_bindWebViewLoadUrl:(NSString *)url isLocal:(BOOL)isLocal;

@end

@interface NSString (WebUrl)

- (NSDictionary *)urlSchemeParamsAnlisy;

@end

NS_ASSUME_NONNULL_END
