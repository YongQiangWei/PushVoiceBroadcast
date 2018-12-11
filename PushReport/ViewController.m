//
//  ViewController.m
//  PushReport
//
//  Created by Yongqiang Wei on 2018/11/9.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import "ViewController.h"
#import "NetworkRequestHelper.h"

/** 屏幕宽度 */
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

/** 屏幕高度 */
#define ScreenHeigh [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, readwrite, strong) UITableView *tableView;
@property (nonatomic, readwrite, copy) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"推送记录";
    [self.view addSubview:self.tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPushReport:) name:PushNotificationReport object:nil];
    [NetworkRequestHelper GetRequestURL:@"http://127.0.0.1/test" Parameter:@{} WaitString:@"" showWaitProgress:NO WaitController:self success:^(NSDictionary *resultDict) {
        if (resultDict) {
            NSLog(@"localHost ---> %@",resultDict);
        }
    } Failure:^(NSError *error) {
        NSLog(@"localHost Error ==== %@",error.localizedDescription);
    }];
 }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PushReportListCell *cell = [PushReportListCell cellWithTableView:tableView identifire:@"cell"];
    if (self.dataSource.count > 0) {
        cell.pushModel = self.dataSource[indexPath.section];
    }
    return cell;
}
- (void) addPushReport:(NSNotification *) notification{
    NSDictionary *userInfo = notification.object;
    [self.dataSource addObject:[PushReportModel pushReportModelValueForKeyWithDictionary:userInfo[@"aps"][@"alert"]]];
    [self. tableView reloadData];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeigh) style:(UITableViewStyleGrouped)];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 70;
    }
    return _tableView;
}
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
@end
