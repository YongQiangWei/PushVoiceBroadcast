//
//  PushReportModel.h
//  PushReport
//
//  Created by Yongqiang Wei on 2018/11/14.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PushReportModel : JSONModel

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSString *subtitle;
@property (nonatomic, readwrite, copy) NSString *body;
@property (nonatomic, readwrite, copy) NSString *pushTime;

+ (PushReportModel *) pushReportModelValueForKeyWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
