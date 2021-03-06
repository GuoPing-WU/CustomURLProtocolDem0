//
//  CustomURLProtocol.m
//  WeakDemo
//
//  Created by WGP on 2020/6/6.
//  Copyright © 2020 WGP. All rights reserved.
//

#import "CustomURLProtocol.h"
#import "SessionConfigurationHook.h"
#import "HttpDNSTool.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface CustomURLProtocol () <NSURLSessionDelegate>

@property(nonatomic,strong)NSURLSession *session;

@end

@implementation CustomURLProtocol

// 开始监听
+ (void)startMonitor {
    SessionConfigurationHook *sessionConfiguration = [SessionConfigurationHook defaultConfiguration];
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    if (![sessionConfiguration isExchanged]) {
        [sessionConfiguration performExchange];
    }
}

// 停止监听
+ (void)stopMonitor {
    SessionConfigurationHook *sessionConfiguration = [SessionConfigurationHook defaultConfiguration];
    [NSURLProtocol unregisterClass:[CustomURLProtocol class]];
    if ([sessionConfiguration isExchanged]) {
        [sessionConfiguration unExchange];
    }
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    NSString * scheme = [[request.URL scheme] lowercaseString];
    
    //看看是否已经处理过了，防止无限循环 根据业务来截取
    if ([NSURLProtocol propertyForKey: URLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    
    if ([scheme isEqual:@"http"]) {
        return YES;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id <NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

//开始请求
- (void)startLoading
{
    NSURLRequest *bodyRequest = [self handlePostRequestBodyWithRequest:self.request];
    NSLog(@"***监听接口：%@ ***body: %@", self.request.URL.absoluteString,[[NSString alloc]initWithData:bodyRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //标示该request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    
    NSMutableURLRequest *mutableReq = [mutableReqeust mutableCopy];
    NSString *originalUrl = mutableReq.URL.absoluteString;
    NSURL *url = [NSURL URLWithString:originalUrl];
    
    /*
     同步接口获取IP地址，这里的获取ip，可以启动的时候服务器下发或者HTTPDNS解析获取
     */
    NSArray *ipArr = [[HttpDNSTool shareInstance] getDNSsWithDormain:url.host];
    NSString *ip = ipArr.firstObject;
    if (ip) {
        // 获取IP成功，进行URL替换和HOST头设置
        NSRange hostFirstRange = [originalUrl rangeOfString:url.host];
        if (NSNotFound != hostFirstRange.location) {
            
            NSString *ipURL = [mutableReq.URL.absoluteString stringByReplacingCharactersInRange:hostFirstRange withString:ip];
             mutableReq.URL = [NSURL URLWithString:ipURL];
            // 添加原始URL的host
            [mutableReq setValue:url.host forHTTPHeaderField:@"host"];
            // 添加originalUrl保存原始URL
            [mutableReq addValue:originalUrl forHTTPHeaderField:@"originalUrl"];
        }
    }
    
    //这个enableDebug随便根据自己的需求了，可以直接拦截到数据返回本地的模拟数据，进行测试
    BOOL enableDebug = NO;
    if (enableDebug) {
        
        NSString *str = @"测试数据";
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReq.URL
                                                            MIMEType:@"text/plain"
                                               expectedContentLength:data.length
                                                    textEncodingName:nil];
        [self.client URLProtocol:self
              didReceiveResponse:response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else {
        //使用NSURLSession继续把request发送出去
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:mainQueue];
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:mutableReq];
        [task resume];
    }
}

//结束请求
- (void)stopLoading {
    [self.session invalidateAndCancel];
    self.session = nil;
}

//MARK: - 处理POST请求，用HTTPBodyStream来处理body体
- (NSMutableURLRequest *)handlePostRequestBodyWithRequest:(NSURLRequest *)request {
    NSMutableURLRequest * req = [request mutableCopy];
    if ([request.HTTPMethod isEqualToString:@"POST"]) {
        if (!request.HTTPBody) {
            uint8_t d[1024] = {0};
            NSInputStream *stream = request.HTTPBodyStream;
            NSMutableData *data = [[NSMutableData alloc] init];
            [stream open];
            while ([stream hasBytesAvailable]) {
                NSInteger len = [stream read:d maxLength:1024];
                if (len > 0 && stream.streamError == nil) {
                    [data appendBytes:(void *)d length:len];
                }
            }
            req.HTTPBody = [data copy];
            [stream close];
        }
    }
    return req;
}

//MARK:－　评估当前serverTrust是否可信任
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

//MARK: - NSURLSessionDelegate


/*
 如果服务器要求验证客户端身份或向客户端提供其证书用于验证时，则会调用
 响应来自远程服务器的会话级别认证请求，从代理请求凭据。
 
 这种方法在两种情况下被调用：
 1、远程服务器请求客户端证书或Windows NT LAN Manager（NTLM）身份验证时，允许您的应用程序提供适当的凭据
 2、当会话首先建立与使用SSL或TLS的远程服务器的连接时，允许您的应用程序验证服务器的证书链
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if (!challenge) {
        return;
    }
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    /*
     * 获取原始域名信息。
     */
    NSString* host = [[self.request allHTTPHeaderFields] objectForKey:@"host"];
    if (!host) {
        host = self.request.URL.host;
    }
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    // 对于其他的challenges直接使用默认的验证方案
    completionHandler(disposition,credential);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    // 打印返回数据
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (dataStr) {
        NSLog(@"***截取数据***: %@", dataStr);
    }
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}
@end
