# HLYWebCacheDemo
HLYWebCacheDemo

> 白屏主要原因：1.web进程crash 2.webview渲染出错。检测方案：iOS9之后对应白屏的回调函数；还有通过判断 url/title 是否为空；通过视图树对比（WKCompsitingView）

> cookie同步问题：APP共用一个ProcessPool 因为webkit 和 nshttpcookiestorage 不同步 如果存在request中需要手动添加到head中去

> 通讯方式：通过系统或私有方法获取当前webview当中的context，基于JSCore的函数通信；创建自定义Scheme的iframe Dom,在客户端进行拦截。

> 热更新 & 跨平台：context注册block回调，以及JSExport。context evaluate js + runtime (替换，执行前，执行后)

> web优化：
1.网络层：DNS/CDN技术减少网络延迟，通过各种HTTP缓存技术减少网络请求次数，通过资源压缩和合并减少请求内容；
2.渲染层：精简和优化业务代码、按需加载、防止阻塞、调整加载顺序优化 
3.web复用&预热 预热就是在APP启动是就创建一个webview 
复用分两种 
1>常驻一个空webview在内存 
2>不销毁打开过的webview,直接缓存在内存
