//
//  PushReportModel.m
//  PushReport
//
//  Created by Yongqiang Wei on 2018/11/14.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import "PushReportModel.h"

@implementation PushReportModel

+ (PushReportModel *)pushReportModelValueForKeyWithDictionary:(NSDictionary *)dict{
    PushReportModel *model = [[PushReportModel alloc] init];
    [model setValuesForKeysWithDictionary:dict];
    model.pushTime = [model getSystemTimeInterval];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (NSString *)getSystemTimeInterval{
    NSDate *nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:nowDate];
}

@end
