//
//  NotificationService.m
//  NotificationExtension
//
//  Created by Yongqiang Wei on 2018/11/13.
//  Copyright © 2018 Yongqiang Wei. All rights reserved.
//

#import "NotificationService.h"
#import <AVFoundation/AVFoundation.h>
#import "BDSSpeechSynthesizer.h"

//NSString *BaiDu_APP_ID = @"14762480";
//NSString *BaiDu_API_Key  = @"GKYXOqKTWwui9Zj5MEDAtEZW";
//NSString *BaiDu_Secret_Key  = @"nAN6I5hGzVgQf20bIOUNDs80idwMdkGm";


NSString *BaiDu_APP_ID = @"14771752";
NSString *BaiDu_API_Key  = @"rwM8OBGTGScc0CbX3Mtt0PXI";
NSString *BaiDu_Secret_Key  = @"UPqDu4a8ELKOMiNCNM14TUkPQnrNplQp";
@interface NotificationService ()<AVSpeechSynthesizerDelegate,BDSSpeechSynthesizerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, strong) AVSpeechSynthesisVoice *synthesisVoice;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    [self configureTTSSDK];
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
//    [self playVoiceWithContent:self.bestAttemptContent.userInfo];
    [self ttsReadPushNotification:self.bestAttemptContent.userInfo];
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    [[BDSSpeechSynthesizer sharedInstance] cancel];
    self.contentHandler(self.bestAttemptContent);
}
// 新增语音播放代理函数，在语音播报完成的代理函数中，我们添加下面的一行代码
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    //    [self playVoice:@"调用了播放完成函数"];
    
    // 每一条语音播放完成后，我们调用此代码，用来呼出通知栏
    self.contentHandler(self.bestAttemptContent);
}
- (void)playVoiceWithContent:(NSDictionary *)userInfo {
    NSLog(@"NotificationExtension content : %@",userInfo);
    NSString *title = userInfo[@"aps"][@"alert"][@"title"];
    NSString *subTitle = userInfo[@"aps"][@"alert"][@"subtitle"];
    NSString *subMessage = userInfo[@"aps"][@"alert"][@"body"];
    NSString *message = [NSString stringWithFormat:@"%@%@%@",title,subTitle,subMessage];
    if ([userInfo[@"isLogin"] isEqualToString:@"Y"] && [userInfo[@"isRead"] isEqualToString:@"Y"]) {
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:message];
        [self.synthesizer stopSpeakingAtBoundary:(AVSpeechBoundaryImmediate)];
        utterance.rate = 0.5;
        utterance.voice = self.synthesisVoice;
        [self.synthesizer speakUtterance:utterance];
    }
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
        _synthesizer.delegate = self;
    }
    return _synthesizer;
}

#pragma mark ------ TTS

-(void)configureTTSSDK{
    NSLog(@"TTS version info: %@", [BDSSpeechSynthesizer version]);
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_DEBUG];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
//    [self configureOnlineTTS];
    [self configureOfflineTTS];
    
}


-(void)configureOnlineTTS{
    
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:BaiDu_API_Key withSecretKey:BaiDu_Secret_Key];
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_DYY) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    //    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(10) forKey:BDS_SYNTHESIZER_PARAM_ONLINE_REQUEST_TIMEOUT];
    
}

-(void)configureOfflineTTS{
    
    NSError *err = nil;
    // 在这里选择不同的离线音库（请在XCode中Add相应的资源文件），同一时间只能load一个离线音库。根据网络状况和配置，SDK可能会自动切换到离线合成。
    
    NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:@"Chinese_Speech_Female" ofType:@"dat"];
    
    NSString* offlineChineseAndEnglishTextData = [[NSBundle mainBundle] pathForResource:@"Chinese_Text" ofType:@"dat"];
    
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
        NSLog(@"TTSFlage -------%ld",(long)flag);
        
    }
}

@end
