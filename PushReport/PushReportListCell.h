//
//  PushReportListCell.h
//  PushReport
//
//  Created by Yongqiang Wei on 2018/11/14.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PushReportModel;
NS_ASSUME_NONNULL_BEGIN

@interface PushReportListCell : UITableViewCell

@property (nonatomic, readwrite, strong) PushReportModel *pushModel;


+ (PushReportListCell *)cellWithTableView:(UITableView *)tableView identifire:(NSString *)identifire;

@end

NS_ASSUME_NONNULL_END
