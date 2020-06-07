//
//  ReplacingImageURLProtocol.m
//  NSURLProtocol+WebKitSupport
//
//  Created by yeatse on 2016/10/11.
//  Copyright © 2016年 Yeatse. All rights reserved.
//

#import "ReplacingImageURLProtocol.h"

#import <UIKit/UIKit.h>

static NSString* const FilteredKey = @"FilteredKey";

@implementation ReplacingImageURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString* extension = request.URL.pathExtension;
    BOOL isImage = [@[@"png", @"jpeg", @"gif", @"jpg"] indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isImage = [extension compare:obj options:NSCaseInsensitiveSearch] == NSOrderedSame;
        return isImage;
    }] != NSNotFound;
    
    
    
    
    NSLog(@"isImage = %d",isImage);
    NSLog(@"keyValue = %@",[NSURLProtocol propertyForKey:FilteredKey inRequest:request]);
    BOOL canInit = [NSURLProtocol propertyForKey:FilteredKey inRequest:request] == nil && isImage;
    NSLog(@"canInit = %d",canInit);
    return canInit;
}
- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    
    NSLog(@"self.request = %@",self.request);
    NSLog(@"self.cacheURLResponse = %@",self.cachedResponse);
//    NSMutableURLRequest* request = self.request.mutableCopy;
//    [NSURLProtocol setProperty:@YES forKey:FilteredKey inRequest:request];
    
    NSData* data = UIImagePNGRepresentation([UIImage imageNamed:@"image"]);
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:nil];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
    
}

- (void)stopLoading {
    NSURLCache *cache = [NSURLCache sharedURLCache];
    NSLog(@"self.cacheURLResponse = %@",self.cachedResponse);
    [cache storeCachedResponse:self.cachedResponse forRequest:self.request];
}

@end
