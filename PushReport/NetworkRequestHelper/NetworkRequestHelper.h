//
//  NetworkRequestHelper.h
//  SchoolClient
//
//  Created by Yongqiang Wei on 2017/5/19.
//  Copyright © 2017年 Yongqiang Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkRequestHelper : NSObject

+ (void) GetRequestURL:(NSString *)urlString Parameter:(NSDictionary *) parameter WaitString:(NSString *) waitString showWaitProgress:(BOOL) showWait WaitController:(UIViewController *) waitVC success:(void (^)(NSDictionary *resultDict)) success Failure:(void (^)(NSError *error)) errorBlock;

+ (void) PostRequestURL:(NSString *)urlString Parameter:(NSDictionary *) parameter WaitString:(NSString *) waitString showWaitProgress:(BOOL) showWait WaitController:(UIViewController *) waitVC success:(void (^)(NSDictionary *resultDict)) success Failure:(void (^)(NSError *error)) errorBlock;
@end
