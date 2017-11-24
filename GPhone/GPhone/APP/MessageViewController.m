//
//  MessageViewController.m
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageModel.h"

@interface MessageViewController () <JSMessagesViewDelegate, JSMessagesViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *messageArray;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ChatMessage";
    self.delegate = self;
    self.dataSource = self;
    self.messageArray = [NSMutableArray array];
    MessageModel *message1 = [[MessageModel alloc] initWithMsgId:@"0001" text:@"This is a Chat Demo like iMessage.app" date:[NSDate date] msgType:JSBubbleMessageTypeIncoming mediaType:JSBubbleMediaTypeText img:nil];
    
    [self.messageArray addObject:message1];
    
    MessageModel *message2 = [[MessageModel alloc] initWithMsgId:@"0002" text:nil date:[NSDate date] msgType:JSBubbleMessageTypeOutgoing mediaType:JSBubbleMediaTypeImage img:@"demo1.jpg"];
    
    [self.messageArray addObject:message2];
    
    MessageModel *message3 = [[MessageModel alloc] initWithMsgId:@"0003" text:@"Up-to-date for iOS 6.0 and ARC (iOS 5.0+ required) Universal for iPhone Allows arbitrary message (and bubble) sizes Copy & paste text message && Save image message " date:[NSDate date] msgType:JSBubbleMessageTypeOutgoing mediaType:JSBubbleMediaTypeText img:nil];
    
    [self.messageArray addObject:message3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
    int value = arc4random() % 1000;
    NSString *msgId = [NSString stringWithFormat:@"%d",value];
    
    JSBubbleMessageType msgType;
    if((self.messageArray.count - 1) % 2){
        msgType = JSBubbleMessageTypeOutgoing;
        [JSMessageSoundEffect playMessageSentSound];
    }else{
        msgType = JSBubbleMessageTypeIncoming;
        [JSMessageSoundEffect playMessageReceivedSound];
    }
    
    MessageModel *message = [[MessageModel alloc] initWithMsgId:msgId text:text date:[NSDate date] msgType:msgType mediaType:JSBubbleMediaTypeText img:nil];
    
    [self.messageArray addObject:message];
    
    [self finishSend:NO];
}



#pragma mark -- UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        case 1:{
            int value = arc4random() % 1000;
            NSString *msgId = [NSString stringWithFormat:@"%d",value];
            
            JSBubbleMessageType msgType;
            if((self.messageArray.count - 1) % 2){
                msgType = JSBubbleMessageTypeOutgoing;
                [JSMessageSoundEffect playMessageSentSound];
            }else{
                msgType = JSBubbleMessageTypeIncoming;
                [JSMessageSoundEffect playMessageReceivedSound];
            }
            
            MessageModel *message = [[MessageModel alloc] initWithMsgId:msgId text:nil date:[NSDate date] msgType:msgType mediaType:JSBubbleMediaTypeImage img:@"demo1.jpg"];
            
            [self.messageArray addObject:message];
            
            [self finishSend:YES];
        }
            break;
    }
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *message = self.messageArray[indexPath.row];
    return message.messageType;
}

- (JSBubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JSBubbleMessageStyleFlat;
}

- (JSBubbleMediaType)messageMediaTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageModel *message = self.messageArray[indexPath.row];
    return message.mediaType;
}

- (UIButton *)sendButton
{
    return [UIButton defaultSendButton];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    /*
     JSMessagesViewTimestampPolicyAll = 0,
     JSMessagesViewTimestampPolicyAlternating,
     JSMessagesViewTimestampPolicyEveryThree,
     JSMessagesViewTimestampPolicyEveryFive,
     JSMessagesViewTimestampPolicyCustom
     */
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    /*
     JSMessagesViewAvatarPolicyIncomingOnly = 0,
     JSMessagesViewAvatarPolicyBoth,
     JSMessagesViewAvatarPolicyNone
     */
    return JSMessagesViewAvatarPolicyBoth;
}

- (JSAvatarStyle)avatarStyle
{
    /*
     JSAvatarStyleCircle = 0,
     JSAvatarStyleSquare,
     JSAvatarStyleNone
     */
    return JSAvatarStyleNone;
}

- (JSInputBarStyle)inputBarStyle
{
    /*
     JSInputBarStyleDefault,
     JSInputBarStyleFlat
     
     */
    return JSInputBarStyleFlat;
}

//  Optional delegate method
//  Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

#pragma mark - Messages view data source
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MessageModel *message = self.messageArray[indexPath.row];
    return message.text;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *message = self.messageArray[indexPath.row];
    return message.date;
}

- (UIImage *)avatarImageForIncomingMessage
{
    return [UIImage imageNamed:@"demo-avatar-jobs"];
}

- (SEL)avatarImageForIncomingMessageAction
{
    return @selector(onInComingAvatarImageClick);
}

- (void)onInComingAvatarImageClick
{
    NSLog(@"__%s__",__func__);
}

- (SEL)avatarImageForOutgoingMessageAction
{
    return @selector(onOutgoingAvatarImageClick);
}

- (void)onOutgoingAvatarImageClick
{
    NSLog(@"__%s__",__func__);
}

- (UIImage *)avatarImageForOutgoingMessage
{
    return [UIImage imageNamed:@"demo-avatar-woz"];
}

- (id)dataForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageModel *message = self.messageArray[indexPath.row];
    return [UIImage imageNamed:message.img];
}

@end
