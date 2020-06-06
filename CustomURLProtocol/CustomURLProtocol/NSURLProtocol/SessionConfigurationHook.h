//
//  SessionConfigurationHook.h
//  WeakDemo
//
//  Created by WGP on 2020/6/6.
//  Copyright © 2020 WGP. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionConfigurationHook : NSObject
//是否交换方法
@property (nonatomic,assign) BOOL isExchanged;

+ (SessionConfigurationHook *)defaultConfiguration;
// 交换掉NSURLSessionConfiguration的 protocolClasses方法
- (void)performExchange;
// 还原初始化
- (void)unExchange;

@end

NS_ASSUME_NONNULL_END
