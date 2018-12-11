//
//  AppDelegate.h
//  PushReport
//
//  Created by Yongqiang Wei on 2018/11/9.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


- (void)addOperation:(NSDictionary *)userInfo;

- (void)ttsReadPushNotification:(NSDictionary *)userInfo;
@end

