//
//  CustomURLProtocol.h
//  WeakDemo
//
//  Created by WGP on 2020/6/6.
//  Copyright © 2020 WGP. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomURLProtocol : NSURLProtocol

//开始监听
+(void)startMonitor;

//停止监听
+ (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
