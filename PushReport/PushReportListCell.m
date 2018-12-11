//
//  PushReportListCell.m
//  PushReport
//
//  Created by Yongqiang Wei on 2018/11/14.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import "PushReportListCell.h"

@interface PushReportListCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation PushReportListCell
+ (PushReportListCell *)cellWithTableView:(UITableView *)tableView identifire:(NSString *)identifire{
    PushReportListCell * customCell = [tableView dequeueReusableCellWithIdentifier:identifire];
    if (customCell == nil) {
        customCell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].lastObject;
    }
    customCell.selectionStyle = UITableViewCellEditingStyleNone;
    return customCell;
}

- (void)setPushModel:(PushReportModel *)pushModel{
    _pushModel = pushModel;
    _titleLabel.text = pushModel.title;
    _subTitle.text = pushModel.subtitle;
    _contentLabel.text = pushModel.body;
    _timeLabel.text = pushModel.pushTime;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
