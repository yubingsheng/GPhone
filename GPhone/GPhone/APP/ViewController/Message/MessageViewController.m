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

@property (strong, nonatomic) UITextField* phoneTextField;

@end

@implementation MessageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super  viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relaodData:) name:@"relaodData" object:nil];
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"relaodData" object:nil];
    _contactModel.messageList = _messageArray;
    if (_messageBlock) {
        _messageBlock(_contactModel);
    }
}
- (void)relaodData:(NSNotification *)notification {
    MessageModel *model =   [[MessageModel alloc] initWithMsgId:[notification.userInfo[@"id"] intValue] text:notification.userInfo[@"title"] date:[NSDate date] msgType:[notification.userInfo[@"messageType"] intValue] phone:notification.userInfo[@"phone"]];
    [_messageArray addObject:model];
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
//    [GPhoneHandel messageTabbarItemBadgeValue:_contactModel.unread];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.title = _contactModel.fullName ? _contactModel.fullName : @"新消息";
    self.delegate = self;
    self.dataSource = self;
    _messageArray = [NSMutableArray arrayWithArray:_contactModel.messageList];
    [GPhoneHandel messageTabbarItemBadgeValue:_contactModel.unread];
    _contactModel.unread = 0;
    self.tabBarController.tabBar.hidden = YES;
    if (_isNew) {
        [self.phoneTextField becomeFirstResponder];
    }
    self.phoneTextField.userInteractionEnabled = _isNew;
    self.phoneTextField.text = _contactModel.phoneNumber;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messageArray.count;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text{
    _contactModel.phoneNumber = self.phoneTextField.text;
    NSString* phoneNumber = _contactModel.phoneNumber;
    if (phoneNumber.length <= 0) {
        [[[[iToast makeText:@"请输入正确手机号"] setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
        return;
    }
    MessageModel *message = [[MessageModel alloc] initWithMsgId:rand() text:text date:[NSDate date] msgType:JSBubbleMessageTypeOutgoing phone:phoneNumber];
    __block MessageViewController *vc = self;
    [GPhoneCallService.sharedManager sendMsgWith:message];
    
    GPhoneCallService.sharedManager.messageBlock = ^(BOOL succeed){
        dispatch_sync(dispatch_get_main_queue(), ^(){
            if (succeed) {
                [vc.messageArray addObject:message];
                vc.contactModel.messageList = vc.messageArray;
                vc.contactModel.creatTime = [GPhoneHandel dateToStringWith:[NSDate date]];
                [GPhoneHandel mergeMessageArrayContainWith:vc.contactModel];
            }else {
                [[[[iToast makeText:@"发送失败，重新发送！"] setGravity:iToastGravityCenter] setDuration:iToastDurationNormal] show];
            }
             [vc finishSend:!succeed];
        });
    };
   
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
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *message = self.messageArray[indexPath.row];
    return message.text;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath{
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
