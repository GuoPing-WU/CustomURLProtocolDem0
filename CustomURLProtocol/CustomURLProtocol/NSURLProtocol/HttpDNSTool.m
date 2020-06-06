//
//  HttpDNSTool.m
//  CustomURLProtocol
//
//  Created by WGP on 2020/6/6.
//  Copyright © 2020 WGP. All rights reserved.
//

#import "HttpDNSTool.h"
#include <netdb.h>
#include <arpa/inet.h>

@implementation HttpDNSTool

+ (HttpDNSTool *)shareInstance {
    static HttpDNSTool *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[HttpDNSTool alloc] init];
    });
    return _shareInstance;
}

//MARK: -  通过hostname获取ip列表 DNS解析地址
/**
 * 通过hostname获取ip列表 DNS解析地址
 */
- (NSArray *)getDNSsWithDormain:(NSString *)hostName{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *IPV4DNSs = [self getIPV4DNSWithHostName:hostName];
    if (IPV4DNSs && IPV4DNSs.count > 0) {
        [result addObjectsFromArray:IPV4DNSs];
    }
    
    //由于在IPV6环境下不能用IPV4的地址进行连接监测
    //所以只返回IPV6的服务器DNS地址
    NSArray *IPV6DNSs = [self getIPV6DNSWithHostName:hostName];
    if (IPV6DNSs && IPV6DNSs.count > 0) {
        [result removeAllObjects];
        [result addObjectsFromArray:IPV6DNSs];
    }
    
    return [NSArray arrayWithArray:result];
}
//ipv4
- (NSArray *)getIPV4DNSWithHostName:(NSString *)hostName
{
    const char *hostN = [hostName UTF8String];
    struct hostent *phost;
    
    @try {
        phost = gethostbyname(hostN);
    } @catch (NSException *exception) {
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int j = 0;
    while (phost && phost->h_addr_list && phost->h_addr_list[j]) {
        struct in_addr ip_addr;
        memcpy(&ip_addr, phost->h_addr_list[j], 4);
        char ip[20] = {0};
        inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
        
        NSString *strIPAddress = [NSString stringWithUTF8String:ip];
        [result addObject:strIPAddress];
        j++;
    }
    
    return [NSArray arrayWithArray:result];
}

//ipv6
- (NSArray *)getIPV6DNSWithHostName:(NSString *)hostName
{
    const char *hostN = [hostName UTF8String];
    struct hostent *phost;
    
    @try {
        /**
         * 只有在IPV6的网络下才会有返回值
         */
        phost = gethostbyname2(hostN, AF_INET6);
    } @catch (NSException *exception) {
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int j = 0;
    while (phost && phost->h_addr_list && phost->h_addr_list[j]) {
        struct in6_addr ip6_addr;
        memcpy(&ip6_addr, phost->h_addr_list[j], sizeof(struct in6_addr));
        NSString *strIPAddress = [self formatIPV6Address: ip6_addr];
        [result addObject:strIPAddress];
        j++;
    }
    
    return [NSArray arrayWithArray:result];
}

- (NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

@end
