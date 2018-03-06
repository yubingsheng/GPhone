//
//  MessageViewController.m
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageModel.h"

@interface MessageViewController () <JSMessagesViewDelegate, JSMessagesViewDataSource>

@property (strong, nonatomic) NSMutableArray *messageArray;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.title = @"ChatMessage";
    self.delegate = self;
    self.dataSource = self;
    self.messageArray = [NSMutableArray array];
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
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text{
    MessageModel *message = [[MessageModel alloc] initWithMsgId:0 text:text date:[NSDate date] msgType:JSBubbleMessageTypeOutgoing phone:@"18016388248"];
    [self.messageArray addObject:message];
    [GPhoneCallService.sharedManager sendMsgWith:message];
    [self finishSend:NO];
}

#pragma mark -- UIActionSheet Delegate

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
    return 0;
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
    return nil;
}

@end
