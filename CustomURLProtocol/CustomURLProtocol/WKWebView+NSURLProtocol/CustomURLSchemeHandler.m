//
//  CustomURLSchemeHandler.m
//  CustomURLProtocol
//
//  Created by WGP on 2020/6/6.
//  Copyright © 2020 WGP. All rights reserved.
//

#import "CustomURLSchemeHandler.h"
#import "AFHTTPSessionManager.h"
#import "AFURLSessionManager.h"

static AFHTTPSessionManager *manager ;

@interface CustomURLSchemeHandler ()

@property(nonatomic,assign)BOOL isCancel;

@end

@implementation CustomURLSchemeHandler

//这里拦截到URLScheme为customScheme的请求后，根据自己的需求,返回结果，并返回给WKWebView显示
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask{
    
    NSURLRequest *request = urlSchemeTask.request;
    NSLog(@"request = %@",request);
    
    NSString* extension = request.URL.pathExtension;
    BOOL isImage = [@[@"png", @"jpeg", @"gif", @"jpg"] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isImage = [extension compare:obj options:NSCaseInsensitiveSearch] == NSOrderedSame;
        return isImage;
    }] != NSNotFound;
    if (isImage) {
                //如果是返回本地资源的话
        UIImage *image = [UIImage imageNamed:@"image.png"];
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSURLResponse *response1 = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response1];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
        return ;
    }
    
    //如果是我们替对方去处理请求的时候
    if (!manager) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:config];
        //这个acceptableContentTypes类型自己补充,demo不写太多
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/html", nil];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!self.isCancel) {
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:responseObject];
            [urlSchemeTask didFinish];
        }
    }];
    
    [task resume];
}

- (void)webView:(WKWebView *)webVie stopURLSchemeTask:(id)urlSchemeTask {
    self.isCancel = YES;
    NSLog(@"stop = %@",urlSchemeTask);
}
@end
