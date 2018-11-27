//
//  WKWebViewViewController.m
//  NOTE
//
//  Created by 卢腾达 on 2018/11/27.
//  Copyright © 2018 卢腾达. All rights reserved.
//

#import "WKWebViewViewController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewViewController ()<WKNavigationDelegate,WKUIDelegate>

///WKWebView进度条
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, nonnull, strong) WKWebView *webView;

@end

@implementation WKWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [self.view addSubview:self.webView];
    [self.webView addSubview:self.progressView];
    NSString *urlString = @"https://baidu.com";
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [self.webView loadRequest:request];
}

- (WKWebView *)webView{
    if (!_webView) {
        
        WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
        // 设置偏好设置
        webConfig.preferences = [[WKPreferences alloc] init];
        webConfig.preferences.minimumFontSize = 10;
        webConfig.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        webConfig.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        // web内容处理池
        webConfig.processPool = [[WKProcessPool alloc] init];
        // 将所有cookie以document.cookie = 'key=value';形式进行拼接
#warning 然而这里的单引号一定要注意是英文的
        NSString *cookieValue = @"";
        
        // 加cookie给h5识别，表明在ios端打开该地址
        WKUserContentController* userContentController = WKUserContentController.new;
        WKUserScript * cookieScript = [[WKUserScript alloc]
                                       initWithSource: cookieValue
                                       injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:cookieScript];
        webConfig.userContentController = userContentController;
        
        
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height)configuration:webConfig];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}
- (UIProgressView *)progressView{
    
    if (!_progressView){
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 2)];
        _progressView.backgroundColor = [UIColor blueColor];
        _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
        _progressView.progressTintColor = [UIColor redColor];
        [self.view addSubview:self.progressView];
    }
    return _progressView;
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView stopLoading];
    [_webView setNavigationDelegate:nil];
    [self clearCache];
    [self cleanCacheAndCookie];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1)
        {
            //            WeakSelfDeclare
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^
             {
                 weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
             }
                             completion:^(BOOL finished)
             {
                 weakSelf.progressView.hidden = YES;
             }];
        }
    }
}

#pragma mark - WKNavigationDelegate
/*
 
 //判断链接是否允许跳转
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
 
 }
 */
/*
 //拿到响应后决定是否允许跳转
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
 
 }
 */

//链接开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:self.progressView];
    
}
//收到服务器重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}
//加载错误时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
    self.progressView.hidden = YES;
    //    [self.navigationItem setTitleWithCustomLabel:@"加载失败"];
}
//当内容开始到达主帧时被调用（即将完成）
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}
//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    self.progressView.hidden = YES;
    
    NSString *titleHtmlInfo = webView.title;
    if ([titleHtmlInfo rangeOfString:@"-"].location !=NSNotFound) {
        NSRange range;
        range = [titleHtmlInfo rangeOfString:@"-"];
        NSLog(@"found at location = %lu, length = %lu",(unsigned long)range.location,(unsigned long)range.length);
        NSString *ok = [titleHtmlInfo substringToIndex:range.location];
    }else{
        
    }
}
//在提交的主帧中发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
    if(error.code==NSURLErrorCancelled)
    {
        [self webView:webView didFinishNavigation:navigation];
    }
    else
    {
        self.progressView.hidden = YES;
    }
    
}
/*
 //当webView需要响应身份验证时调用(如需验证服务器证书)
 - (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge    completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable   credential))completionHandler{
 
 }
 */


//当webView的web内容进程被终止时调用。(iOS 9.0之后)
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)){
    
}
#pragma mark - WKUIDelegate
//在JS端调用alert函数时，会触发此代理方法。JS端调用alert时所传的数据可以通过message拿到。在原生得到结果后，需要回调JS，是通过completionHandler回调。
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    NSLog(@"message = %@",message);
}
//JS端调用confirm函数时，会触发此方法，通过message可以拿到JS端所传的数据，在iOS端显示原生alert得到YES/NO后，通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"message = %@",message);
}
//JS端调用prompt函数时，会触发此方法,要求输入一段文本,在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", prompt);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField)
     {
         textField.textColor = [UIColor redColor];
     }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                      {
                          completionHandler([[alert.textFields lastObject] text]);
                      }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - JS交互实现流程
/*
 
 JS调iOS
 
 使用WKWebView，JS调iOS-JS端必须使用window.webkit.messageHandlers.JS_Function_Name.postMessage(null)，其中JS_Function_Name是iOS端提供个JS交互的Name。
 例：
 function iOSCallJsAlert()
 {
 alert('弹个窗，再调用iOS端的JS_Function_Name');
 window.webkit.messageHandlers.JS_Function_Name.postMessage({body: 'paramters'});
 }
 
 在注入JS交互Handler之后会用到[userContentController addScriptMessageHandler:self name:JS_Function_Name]。释放使用到[userContentController removeScriptMessageHandlerForName:JS_Function_Name]
 
 我们JS呼叫iOS通过上面的Handler在iOS本地会有方法获取到。获取到之后我们可以根据iOS和JS之间定义好的协议，来做出相应的操作
 
 - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
 NSLog(@"JS调iOS  name : %@    body : %@",message.name,message.body);
 }
 
 处理简单的操作，可以让JS打开新的web页面，在WKWebView的WKNavigationDelegate协议中,判断要打开的新的web页面是否是含有你需要的东西，如果有需要就截获，不打开并且进行本地操作
 
 比如:
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
 {
 NSString * url = navigationAction.request.URL.absoluteString;
 if ([url hasPrefix:@"alipays://"] || [url hasPrefix:@"alipay://"])
 {
 
 if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL])
 {
 [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
 if(decisionHandler)
 {
 decisionHandler(WKNavigationActionPolicyCancel);
 }
 }
 }
 }
 
 
 iOS调JS
 
 iOS端调用JS中的函数只需要知道在JS中的函数名称和函数需要传递的参数。通过原生的方法呼叫JS
 iOSCallJsAlert()是JS端的函数名称，如果有参数iOS端写法iOSCallJsAlert('p1','p2')
 [webView evaluateJavaScript:@"iOSCallJsAlert()" completionHandler:nil]
 */

#pragma mark - JS和iOS注意的地方

/*
 ①. 上面提到[userContentController addScriptMessageHandler:self name:JS_Function_Name]是注册JS的MessageHandler，但是WKWebView在多次调用loadRequest，会出现JS无法调用iOS端。我们需要在loadRequest和reloadWebView的时候需要重新注入。（在注入之前需要移除再注入，避免造成内存泄漏)
 
 如果message.body中没有参数，JS代码中需要传null防止iOS端不会接收到JS的交互。
 
 window.webkit.messageHandlers.kJS_Login.postMessage(null)
 
 ②. 在WKWebView中点击没有反应的时候，可以参考一下处理
 
 -(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
 
 if (!navigationAction.targetFrame.isMainFrame)
 {
 [webView loadRequest:navigationAction.request];
 }
 return nil;
 }
 
 ③. HTML中不能通过<a href="tel:123456789">拨号</a>来拨打iOS的电话。需要在iOS端的WKNavigationDelegate中截取电话在使用原生进行调用拨打电话。其中的[navigationAction.request.URL.scheme isEqualToString:@"tel"]中的@"tel"是JS中的定义好，并iOS端需要知道的。发送请求前决定是否跳转，并在此拦截拨打电话的URL
 
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
 {
 /// <a href="tel:123456789">拨号</a>
 if ([navigationAction.request.URL.scheme isEqualToString:@"tel"])
 {
 decisionHandler(WKNavigationActionPolicyCancel);
 NSString * mutStr = [NSString stringWithFormat:@"telprompt://%@",navigationAction.request.URL.resourceSpecifier];
 if ([[UIApplication sharedApplication] canOpenURL:mutStr.URL])
 {
 if (iOS10())
 {
 [[UIApplication sharedApplication] openURL:mutStr.URL options:@{} completionHandler:^(BOOL success) {}];
 }
 else
 {
 [[UIApplication sharedApplication] openURL:mutStr.URL];
 }
 }
 }
 else
 {
 decisionHandler(WKNavigationActionPolicyAllow);
 }
 }
 
 ④. 在执行goBack或reload或goToBackForwardListItem之后请不要马上执行loadRequest，使用延迟加载。
 
 ⑤在使用中JS端：H5、DOM绑定事件。每一次JS方法调用iOS方法的时候，我都为这个JS方法绑定一个对应的callBack方法，这样的话，同时在发送的消息中告诉iOS需要回调，iOS方法就可以执行完相关的方法后，直接回调相应的callBack方法，并携带相关的参数，这样就可以完美的进行交互了。这是为了在JS调用iOS的时候,在
 - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
 获取到信息后，iOS端调用
 [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {}];
 给JS发送消息，保证JS在获取相关返回值时，一定能拿到值。
 
 ⑥根据需求清楚缓存和Cookie
 
 */
#pragma mark - WKWebview加载远程JS文件和本地JS文件
/*
 在页面请求成功 页面加载完成之后调用
 
 (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
 completionHandler中JS是可以再收到调用之后给webView回调。
 
 
 WKWebView远程网页加载远程JS文件
 
 - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
 {
 [self.webView evaluateJavaScript:@"var script = document.createElement('script');"
 "script.type = 'text/javascript';"
 "script.src = 'http://www.ohmephoto.com/test.js';"
 "document.getElementsByTagName('head')[0].appendChild(script);"
 completionHandler:^(id _Nullable object, NSError * _Nullable error)
 {
 NSLog(@"------error = %@ object = %@",error,object);
 }];
 }
 
 WKWebView远程网页加载本地JS
 在xcode中新建找到Other->Empty，确定文件名XXX.js
 一般需要在本地加载的JS都会很小，用原生JS直接加载就可以了
 题外：看到网友是自定义NSURLProtocol类 - 高端大气上档次，请自行查阅
 - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
 {
 NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"XXX" ofType:@"js"];
 NSString * data = [NSString stringWithContentsOfFile:plistPath encoding:NSUTF8StringEncoding error:nil];//  [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
 
 [self.webView evaluateJavaScript:[NSString stringWithFormat:@"javascript:%@",data]
 completionHandler:^(id _Nullable object, NSError * _Nullable error)
 {
 
 }];
 }
 */

//第三方库WebViewJavascriptBridge

#pragma mark - WKWebView进度条
/*
 声明属性
 
 @property (nonatomic, strong) UIProgressView *progressView;
 
 进度条初始化
 - (UIProgressView *)progressView{
 if (!_progressView)
 {
 
 _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 2)];
 _progressView.backgroundColor = [UIColor blueColor];
 _progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
 _progressView.progressTintColor = [UIColor app_color_yellow_eab201];
 [self.view addSubview:self.progressView];
 }
 return _progressView;
 }
 
 给ViewController中添加Observer
 [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
 
 在dealloc找那个删除Observer
 [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
 
 在observeValueForKeyPath中添加对progressView的进度显示操作
 - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
 {
 if ([keyPath isEqualToString:@"estimatedProgress"])
 {
 self.progressView.progress = self.webView.estimatedProgress;
 if (self.progressView.progress == 1)
 {
 WeakSelfDeclare
 [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^
 {
 weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
 }
 completion:^(BOOL finished)
 {
 weakSelf.progressView.hidden = YES;
 }];
 }
 }
 }
 
 
 显示progressView
 - (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
 {
 self.progressView.hidden = NO;
 self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
 [self.view bringSubviewToFront:self.progressView];
 }
 
 隐藏progressView
 - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
 {
 self.progressView.hidden = YES;
 }
 - (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
 {
 if(error.code==NSURLErrorCancelled)
 {
 [self webView:webView didFinishNavigation:navigation];
 }
 else
 {
 self.progressView.hidden = YES;
 }
 }
 
 - (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
 {
 self.progressView.hidden = YES;
 [self.navigationItem setTitleWithCustomLabel:@"加载失败"];
 }
 
 
 */

#pragma mark - WKWebView清除缓存
- (void)clearCache
{
    /* 取得Library文件夹的位置*/
    NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES)[0];
    /* 取得bundle id，用作文件拼接用*/ NSString *bundleId = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    /* * 拼接缓存地址，具体目录为App/Library/Caches/你的APPBundleID/fsCachedData */
    NSString *webKitFolderInCachesfs = [NSString stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
    NSError *error;
    /* 取得目录下所有的文件，取得文件数组*/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:webKitFolderInCachesfs error:&error];
    /* 遍历文件组成的数组*/
    for(NSString * fileName in fileList)
    {
        /* 定位每个文件的位置*/
        NSString * path = [[NSBundle bundleWithPath:webKitFolderInCachesfs] pathForResource:fileName ofType:@""];
        /* 将文件转换为NSData类型的数据*/
        NSData * fileData = [NSData dataWithContentsOfFile:path];
        /* 如果FileData的长度大于2，说明FileData不为空*/
        if(fileData.length >2)
        {
            /* 创建两个用于显示文件类型的变量*/
            int char1 =0;
            int char2 =0;
            [fileData getBytes:&char1 range:NSMakeRange(0,1)];
            [fileData getBytes:&char2 range:NSMakeRange(1,1)];
            /* 拼接两个变量*/ NSString *numStr = [NSString stringWithFormat:@"%i%i",char1,char2];
            /* 如果该文件前四个字符是6033，说明是Html文件，删除掉本地的缓存*/
            if([numStr isEqualToString:@"6033"])
            {
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",webKitFolderInCachesfs,fileName]error:&error]; continue;
                
            }
        }
    }
}

- (void)cleanCacheAndCookie
{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records)
     {
         for (WKWebsiteDataRecord *record  in records)
         {
             
             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                       forDataRecords:@[record]
                                                    completionHandler:^
              {
                  NSLog(@"Cookies for %@ deleted successfully",record.displayName);
              }];
         }
     }];
    
}
#pragma mark - WKWebView修改userAgent
/*
 在项目中我们游戏直接使用以下方式写入userAgent，出现了URL可以加载，但是URL里面的资源无法加载问题。但是在微信和外部Safari是可以的。后来查出，不要去直接整个修改掉userAgent。要在原有的userAgent加上你需要的userAgent字符串，进行重新注册就可以了。（具体原因可能是外部游戏引擎，会默认取系统的userAgent来做他们的处理，你改掉整个会出现问题）。
 
 
 [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":@"CustomUserAgent"}];
 [[NSUserDefaults standardUserDefaults] synchronize];
 [self.webView setCustomUserAgent:newUserAgent];
 
 使用下面的修改userAgent
 使用NSUserDefaults修改本地的userAgent
 使用WKWebView的setCustomUserAgent修改网络userAgent
 
 [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error)
 {
 NSString * userAgent = result;
 NSString * newUserAgent = [userAgent stringByAppendingString:@"CustomUserAgent"];
 [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":newUserAgent}];
 [[NSUserDefaults standardUserDefaults] synchronize];
 [self.webView setCustomUserAgent:newUserAgent];
 }];
 
 
 WKWebView时间显示Nan问题 (js时间处理)
 var regTime = result.RegTime;
 var dRegTime = new Date(regTime);
 var regHtml = dRegTime.getFullYear() + "年" + dRegTime.getMonth() + "月";
 
 
 在iOS系统下，JS需要正则把-替换成/
 var regTime = result.RegTime.replace(/-/g, "/");
 
 
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
