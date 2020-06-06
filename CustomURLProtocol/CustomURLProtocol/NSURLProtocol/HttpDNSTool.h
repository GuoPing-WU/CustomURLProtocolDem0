//
//  HttpDNSTool.h
//  CustomURLProtocol
//
//  Created by WGP on 2020/6/6.
//  Copyright © 2020 WGP. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpDNSTool : NSObject

+ (HttpDNSTool *)shareInstance;
- (NSArray *)getDNSsWithDormain:(NSString *)hostName;

@end

NS_ASSUME_NONNULL_END
