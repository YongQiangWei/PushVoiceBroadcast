//
//  AppDelegate.m
//  PushReport
//
//  Created by Yongqiang Wei on 2018/11/9.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import "AppDelegate.h"
NSString *BaiDu_APP_ID = @"14762480";
NSString *BaiDu_API_Key  = @"GKYXOqKTWwui9Zj5MEDAtEZW";
NSString *BaiDu_Secret_Key  = @"nAN6I5hGzVgQf20bIOUNDs80idwMdkGm";
@interface AppDelegate ()<UNUserNotificationCenterDelegate,BDSSpeechSynthesizerDelegate>
@property (nonatomic, strong) AVSpeechSynthesisVoice *synthesisVoice;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self JPushapplication:application didFinishLaunchingWithOptions:launchOptions];
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        
    }
    
    [session setActive:YES error:&error];
    
    if (error) {
        // Do some error handling
    }
    
    // 让app支持接受远程控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self configureTTSSDK];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // 开启后台处理多媒体事件
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    AVAudioSession *session=[AVAudioSession sharedInstance];
    
    [session setActive:YES error:nil];
    
    // 后台播放
    
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id，具体做法是：
    
    _backgroundTaskIdentifier=[AppDelegate backgroundPlayerID:_backgroundTaskIdentifier];
    
    // 其中的_bgTaskId是后台任务UIBackgroundTaskIdentifier _bgTaskId;
}
//实现一下backgroundPlayerID:这个方法:

+(UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId{
    
    //设置并激活音频会话类别
    
    AVAudioSession *session=[AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [session setActive:YES error:nil];
    
    //允许应用程序接收远程控制
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //设置后台任务ID
    
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid){
        
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
        
    }
    
    return newTaskId;
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -队列管理推送通知
- (void)addOperation:(NSDictionary *)userInfo {
    NSString *title = userInfo[@"aps"][@"alert"][@"title"];
    NSString *subTitle = userInfo[@"aps"][@"alert"][@"subtitle"];
    NSString *subMessage = userInfo[@"aps"][@"alert"][@"body"];
    NSString *message = [NSString stringWithFormat:@"%@%@%@",title,subTitle,subMessage];
    if ([userInfo[@"isLogin"] isEqualToString:@"Y"] && [userInfo[@"isRead"] isEqualToString:@"Y"]) {
        [[self mainQueue] addOperation:[self customOperation:message]];
    }
}

- (NSOperationQueue *)mainQueue {
    return [NSOperationQueue mainQueue];
}

- (NSOperation *)customOperation:(NSString *)content {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        AVSpeechUtterance *utterance = nil;
        @autoreleasepool {
            utterance = [AVSpeechUtterance speechUtteranceWithString:content];
            utterance.rate = 0.5;
        }
        utterance.voice = self.synthesisVoice;
        [self.synthesizer speakUtterance:utterance];
    }];
    return operation;
}

- (AVSpeechSynthesisVoice *)synthesisVoice {
    if (!_synthesisVoice) {
        _synthesisVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    }
    return _synthesisVoice;
}

- (AVSpeechSynthesizer *)synthesizer {
    if (!_synthesizer) {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _synthesizer;
}

#pragma mark ------ TTS

-(void)configureTTSSDK{
    NSLog(@"TTS version info: %@", [BDSSpeechSynthesizer version]);
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
//    [self configureOnlineTTS];
    [self configureOfflineTTS];
    
}


-(void)configureOnlineTTS{
    
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:BaiDu_API_Key withSecretKey:BaiDu_Secret_Key];
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    
}

-(void)configureOfflineTTS{
    
    NSError *err = nil;
    // 在这里选择不同的离线音库（请在XCode中Add相应的资源文件），同一时间只能load一个离线音库。根据网络状况和配置，SDK可能会自动切换到离线合成。
    
    NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Speech_Female" ofType:@"dat"];
    
    NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_And_English_Text" ofType:@"dat"];
    
    err = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineChineseAndEnglishTextData speechDataPath:offlineEngineSpeechData licenseFilePath:nil withAppCode:BaiDu_APP_ID];
    if(err){
        NSLog(@"offLineTTS configure error : %@",err.localizedDescription);
    }else{
        NSLog(@"offLineTTS success");
    }
}

- (void)ttsReadPushNotification:(NSDictionary *)userInfo{
    [[BDSSpeechSynthesizer sharedInstance] setPlayerVolume:5];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithInteger:7] forKey:BDS_SYNTHESIZER_PARAM_SPEED];
    NSString *title = userInfo[@"aps"][@"alert"][@"title"];
    NSString *subTitle = userInfo[@"aps"][@"alert"][@"subtitle"];
    NSString *subMessage = userInfo[@"aps"][@"alert"][@"body"];
    NSString *message = [NSString stringWithFormat:@"%@%@%@",title,subTitle,subMessage];
    if ([userInfo[@"isLogin"] isEqualToString:@"Y"] && [userInfo[@"isRead"] isEqualToString:@"Y"]) {
        NSInteger flag = [[BDSSpeechSynthesizer sharedInstance] speakSentence:message withError:nil];
        NSLog(@"TTSFlage -------%ld",flag);
        
    }
}
@end
