
//
//  NetworkRequestHelper.m
//  SchoolClient
//
//  Created by Yongqiang Wei on 2017/5/19.
//  Copyright © 2017年 Yongqiang Wei. All rights reserved.
//

#import "NetworkRequestHelper.h"
/** JSON 解析 */
#define JSON(data) [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingAllowFragments|NSJSONReadingMutableLeaves) error:nil]
@implementation NetworkRequestHelper
+ (void)GetRequestURL:(NSString *)urlString Parameter:(NSDictionary *)parameter WaitString:(NSString *)waitString showWaitProgress:(BOOL)showWait WaitController:(UIViewController *)waitVC success:(void (^)(NSDictionary *))success Failure:(void (^)(NSError *))errorBlock{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    manager.requestSerializer.timeoutInterval = 20;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if (showWait) {
//        [waitVC showHudWithTitle:waitString];
    }
    [manager GET:urlString parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        [waitVC hideHud];
        if (responseObject) {
            NSDictionary *result = JSON(responseObject);
            success(result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [waitVC hideHud];
//        [waitVC showHint:@"服务器繁忙"];
        errorBlock(error);
    }];
}
+(void)PostRequestURL:(NSString *)urlString Parameter:(NSDictionary *)parameter WaitString:(NSString *)waitString showWaitProgress:(BOOL)showWait WaitController:(UIViewController *)waitVC success:(void (^)(NSDictionary *))success Failure:(void (^)(NSError *))errorBlock{
    
    NSLog(@"request url is : %@",urlString);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    manager.requestSerializer.timeoutInterval = 20;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (showWait) {
//        [waitVC showHudWithTitle:waitString];
    }
    
    [manager POST:urlString parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        [waitVC hideHud];
        if (responseObject) {
            NSDictionary *result = JSON(responseObject);
            success(result);
            NSLog(@"request return json result ---> %@",result);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [waitVC hideHud];
//        [waitVC showHint:@"服务器繁忙"];
        NSLog(@"%@",error.description);
        errorBlock(error);
    }];
}

@end
