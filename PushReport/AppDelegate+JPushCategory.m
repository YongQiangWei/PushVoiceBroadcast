//
//  AppDelegate+JPush.m
//  JPUSH
//
//  Created by Yongqiang Wei on 2017/6/22.
//  Copyright © 2017年 YongQiangWei. All rights reserved.
//
#import "AppDelegate+JPushCategory.h"

@interface AppDelegate ()<JPUSHRegisterDelegate>


@end

@implementation AppDelegate (JPush)
- (void)JPushapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }

    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:JPush_AppKey channel:@"JPush" apsForProduction:YES advertisingIdentifier:nil];
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 10.0){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:UNAuthorizationOptionCarPlay | UNAuthorizationOptionSound | UNAuthorizationOptionBadge | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@" iOS 10 request notification success");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];
            }else{
                NSLog(@" iOS 10 request notification fail");
            }
        }];
    }
    else if (version >= 8.0)
    {
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert categories:nil];
        [application registerUserNotificationSettings:setting];
    }else
    {     //iOS <= 7.0
        UIRemoteNotificationType type = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:type];
    }
    
    //注册通知
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    
    NSString *content = [userInfo valueForKey:@"content"];
    
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    
    NSLog(@"自定义message:%@",userInfo);
    
    NSLog(@"推%@",content);
    
    NSLog(@"推%@",extras);
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    switch (state) {
        case UIApplicationStateActive:
        {
            [self playNewMessageSound];
            [self playVibration];
        }
            break;
        case UIApplicationStateInactive:
        {
            [self playNewMessageSound];
            [self playVibration];
        }
            break;
        case  UIApplicationStateBackground:
        {
            //发送本地推送
            if (NSClassFromString(@"UNUserNotificationCenter")) {
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                //                if (playSound) {
                content.sound = [UNNotificationSound defaultSound];
                //                }
                content.userInfo = userInfo;
                content.body =[NSString stringWithFormat:@"自定义推送消息:%@",[content.userInfo objectForKey:@"content"]];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notification.name content:content trigger:trigger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
            else {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate date]; //触发通知的时间
                notification.alertBody = [NSString stringWithFormat:@"自定义推送消息:%@",content];
                notification.alertAction = NSLocalizedString(@"open", @"Open");
                notification.timeZone = [NSTimeZone defaultTimeZone];
                //                if (playSound) {
                notification.soundName = UILocalNotificationDefaultSoundName;
                //                }
                notification.userInfo = userInfo;
                
                //发送通知
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
            break;
        default:
            break;
    }
}

void SystemSoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
    AudioServicesDisposeSystemSoundID(sound_id);
}

- (SystemSoundID)playNewMessageSound
{
    // Path for the audio file
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"caf"];
    NSURL *audioPath = [NSURL fileURLWithPath:path];
    
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioPath), &soundID);
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(soundID,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          SystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(soundID);
    
    return soundID;
}

- (void)playVibration
{
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          SystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"deviceToken--------- %@",deviceToken);
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    NSLog(@"ERROR ----------> %s__%d %@",__FUNCTION__,__LINE__,error);
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    //     指定系统如何提醒用户，有Badge、Sound、Alert三种类型可以设置
    //     如果不需提醒可传UNNotificationPresentationOptionNone
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", userInfo);
    }
    else {
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler();  // 系统要求执行这个方法
}


#ifdef __IPHONE_12_0
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    NSString *title = nil;
    if (notification) {
        title = @"从通知界面直接进入应用";
    }else{
        title = @"从系统设置界面进入应用";
    }
    UIAlertView *test = [[UIAlertView alloc] initWithTitle:title
                                                   message:@"pushSetting"
                                                  delegate:self
                                         cancelButtonTitle:@"yes"
                                         otherButtonTitles:nil, nil];
    [test show];
    
}
#endif
#pragma clang diagnostic pop

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PushNotificationReport object:userInfo];
    
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    [self addOperation:userInfo];
//    [self ttsReadPushNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}
- (void)applicationDidEnterBackground:(UIApplication *)application{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    application.applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}

@end
