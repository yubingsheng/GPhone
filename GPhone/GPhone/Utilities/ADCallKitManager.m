//
//  ADCallKitManager.m
//  Copyright © 2018 Appdios Inc. All rights reserved.
//

#import "ADCallKitManager.h"
#import <Intents/Intents.h>
#import "AudioPlayer.h"
#import "AudioRecorder.h"

#import "AudioPlayerClient.h"
#import "AudioRecorderClient.h"

NS_ASSUME_NONNULL_BEGIN

@implementation CXTransaction (ADPrivateAdditions)

+ (CXTransaction *)transactionWithActions:(NSArray <CXAction *> *)actions {
    CXTransaction *transcation = [[CXTransaction alloc] init];
    for (CXAction *action in actions) {
        [transcation addAction:action];
    }
    return transcation;
}

@end

@interface ADCallKitManager() <CXProviderDelegate,AudioControllerDelegate>
@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, copy) ADCallKitActionNotificationBlock actionNotificationBlock;
@property (nonatomic, strong) AudioPlayer* currentPlayer;
@property (nonatomic, strong) AudioRecorder* currentRecorder;
@property (nonatomic, strong) AudioPlayerClient* currentClientPlayer;
@property (nonatomic, strong) AudioRecorderClient* currentClientRecorder;
@end

@implementation ADCallKitManager

static const NSInteger ADDefaultMaximumCallsPerCallGroup = 1;
static const NSInteger ADDefaultMaximumCallGroups = 1;

+ (ADCallKitManager *)sharedInstance {
    static ADCallKitManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[super allocWithZone:nil] init];
        instance.audioController = [[AudioController alloc]init];
        
        instance.audioController = [[AudioController alloc] init];
        instance.audioController.delegate = self;
        [instance.audioController setup];
    });
    return instance;
}

- (void)setupWithAppName:(NSString *)appName supportsVideo:(BOOL)supportsVideo actionNotificationBlock:(ADCallKitActionNotificationBlock)actionNotificationBlock {
    CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    configuration.maximumCallGroups = ADDefaultMaximumCallGroups;
    configuration.maximumCallsPerCallGroup = ADDefaultMaximumCallsPerCallGroup;
    configuration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
    configuration.supportsVideo = supportsVideo;
    
    self.provider = [[CXProvider alloc] initWithConfiguration:configuration];
    [self.provider setDelegate:self queue:self.completionQueue ? self.completionQueue : dispatch_get_main_queue()];
    
    self.callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    self.actionNotificationBlock = actionNotificationBlock;
}

- (void)setCompletionQueue:(dispatch_queue_t)completionQueue {
    _completionQueue = completionQueue;
    if (self.provider) {
        [self.provider setDelegate:self queue:_completionQueue];
    }
}

- (NSUUID *)reportIncomingCallWithContact:(id<ADContactProtocol>)contact completion:(ADCallKitManagerCompletion)completion {
    NSUUID *callUUID = [NSUUID UUID];
    
    CXCallUpdate *callUpdate = [[CXCallUpdate alloc] init];
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:[contact phoneNumber]];
    callUpdate.remoteHandle = handle;
    callUpdate.localizedCallerName = [contact displayName];
    [self.provider reportNewIncomingCallWithUUID:callUUID update:callUpdate completion:completion];
    return callUUID;
}

- (NSUUID *)reportOutgoingCallWithContact:(id<ADContactProtocol>)contact completion:(ADCallKitManagerCompletion)completion {
    NSUUID *callUUID = [NSUUID UUID];
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:[contact phoneNumber]];
    
    CXStartCallAction *action = [[CXStartCallAction alloc] initWithCallUUID:callUUID handle:handle];
    action.contactIdentifier = [callUUID UUIDString];
    
    [self.callController requestTransaction:[CXTransaction transactionWithActions:@[action]] completion:completion];
    return callUUID;
}

- (void)updateCall:(NSUUID *)callUUID state:(ADCallState)state {
    if (callUUID) {
        switch (state) {
            case ADCallStateConnecting:
                [self.provider reportOutgoingCallWithUUID:callUUID startedConnectingAtDate:nil];
                break;
            case ADCallStateConnected:
                [self.provider reportOutgoingCallWithUUID:callUUID connectedAtDate:nil];
                break;
            case ADCallStateEnded:
                [self.provider reportCallWithUUID:callUUID endedAtDate:nil reason:CXCallEndedReasonRemoteEnded];
                break;
            case ADCallStateEndedWithFailure:
                [self.provider reportCallWithUUID:callUUID endedAtDate:nil reason:CXCallEndedReasonFailed];
                break;
            case ADCallStateEndedUnanswered:
                [self.provider reportCallWithUUID:callUUID endedAtDate:nil reason:CXCallEndedReasonUnanswered];
                break;
            default:
                break;
        }
    }
}

- (void)mute:(BOOL)mute callUUID:(NSUUID *)callUUID completion:(ADCallKitManagerCompletion)completion {
    CXSetMutedCallAction *action = [[CXSetMutedCallAction alloc] initWithCallUUID:callUUID muted:mute];
    [self.callController requestTransaction:[CXTransaction transactionWithActions:@[action]] completion:completion];
}

- (void)hold:(BOOL)hold callUUID:(NSUUID *)callUUID completion:(ADCallKitManagerCompletion)completion {
    CXSetHeldCallAction *action = [[CXSetHeldCallAction alloc] initWithCallUUID:callUUID onHold:hold];
    [self.callController requestTransaction:[CXTransaction transactionWithActions:@[action]] completion:completion];
    self.isOutgoingCall = YES;
}

- (void)endCall:(NSUUID *)callUUID completion:(ADCallKitManagerCompletion)completion {
    if (callUUID) {
        CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:callUUID];
        [self.callController requestTransaction:[CXTransaction transactionWithActions:@[action]] completion:completion];
    }
}

#pragma mark - CXProviderDelegate
- (void)provider:(CXProvider *)provider performAnswerCallAction:(nonnull CXAnswerCallAction *)action {
    if (self.actionNotificationBlock) {
        self.actionNotificationBlock(action, ADCallActionTypeAnswer);
    }
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(nonnull CXEndCallAction *)action {
    [self.audioController stop];
    self.isOutgoingCall = NO;
    if (self.actionNotificationBlock) {
        self.actionNotificationBlock(action, ADCallActionTypeEnd);
    }
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performStartCallAction:(nonnull CXStartCallAction *)action {
    if (self.actionNotificationBlock) {
        self.actionNotificationBlock(action, ADCallActionTypeStart);
    }
    if (action.handle.value) {
        [action fulfill];
    } else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(nonnull CXSetMutedCallAction *)action {
    if (self.actionNotificationBlock) {
        self.actionNotificationBlock(action, ADCallActionTypeMute);
    }
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(nonnull CXSetHeldCallAction *)action {
    if (self.actionNotificationBlock) {
        self.actionNotificationBlock(action, ADCallActionTypeHeld);
    }
    [action fulfill];
}

- (void)providerDidReset:(CXProvider *)provider {
    
}
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession{
    [self.audioController start];
    NSLog(@"session has activate");
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession{
    
}
#pragma mark - AudioControllerDelegate
/*!
 * callback function, when engine running, engine pull play data from you
 */
- (NSData* _Nonnull)audioEnginePlayCallback:(NSInteger)length{
    if (self.isOutgoingCall) {
        if (self.currentPlayer&&self.currentPlayer.isRunning) {
            return [self.currentPlayer readAudioData:length];
        }
    } else {
        if (self.currentClientPlayer && self.currentClientPlayer.isRunning) {
            return [self.currentClientPlayer readAudioData:length];
        }
    }
    return NULL;
}

/*!
 * callback function, when engine running, engine push record data to you
 */
- (void)audioEngineRecordCallback:(NSData* _Nonnull)audioBuffer{
    if (self.isOutgoingCall) {
        if (self.currentRecorder&&self.currentRecorder.isRunning) {
            [self.currentRecorder writeAudioData:audioBuffer];
        }
    } else {
        if (self.currentClientRecorder&&self.currentClientRecorder.isRunning) {
            [self.currentClientRecorder writeAudioData:audioBuffer];
        }
    }
}
@end
NS_ASSUME_NONNULL_END
