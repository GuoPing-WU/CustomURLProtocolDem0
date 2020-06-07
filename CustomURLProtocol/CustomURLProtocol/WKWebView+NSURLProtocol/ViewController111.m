//
//  ViewController.m
//  NSURLProtocol+WebKitSupport
//
//  Created by yeatse on 2016/10/11.
//  Copyright © 2016年 Yeatse. All rights reserved.
//

#import "ViewController111.h"
#import <WebKit/WebKit.h>
#import "CustomURLSchemeHandler.h"

@interface ViewController111 ()<WKNavigationDelegate, UIWebViewDelegate>

@property (nonatomic) __kindof UIView* webView;

@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation ViewController111
#pragma clang diagnostic pop
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.webView];
    [(UIWebView*)self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSSet* types = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:types modifiedSince:[NSDate dateWithTimeIntervalSince1970:0] completionHandler:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if ([result isKindOfClass:[NSString class]]) {
            self.title = result;
        }
    }];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

#pragma mark - Getters

- (UIView *)webView {
    if (!_webView) {
        
        if (@available(iOS 11.0, *)) {
            WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
            CustomURLSchemeHandler *handler = [CustomURLSchemeHandler new];
            //支持https和http的方法1  这个需要去hook +[WKwebview handlesURLScheme]的方法,可以去看WKWebView+Custome类的实现
            [configuration setURLSchemeHandler:handler forURLScheme:@"https"];
            [configuration setURLSchemeHandler:handler forURLScheme:@"http"];
            
                //hook系统的方法2   xcode11可能会运行直接崩溃,因为用到了私有变量
            //    NSMutableDictionary *handlers = [configuration valueForKey:@"_urlSchemeHandlers"];
            //    handlers[@"https"] = handler;//修改handler,将HTTP和HTTPS也一起拦截
            //    handlers[@"http"] = handler;
            
            _webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:configuration];
        }else{
            _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        }
        
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if ([_webView respondsToSelector:@selector(setNavigationDelegate:)]) {
            [_webView setNavigationDelegate:self];
        }
        
        if ([_webView respondsToSelector:@selector(setDelegate:)]) {
            [_webView setDelegate:self];
        }
    }
    return _webView;
}


@end
