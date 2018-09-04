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
    
    [self inputPhoneNumber];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _contactModel.messageList = _messageArray;
    
    if (_messageBlock) {
        _messageBlock(_contactModel);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)inputPhoneNumber {
    UIView* inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 44)];
    [inputView setBackgroundColor:[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f]];
    [self.view addSubview:inputView];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    label.text = @"手机号：";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor =[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
    label.textAlignment = NSTextAlignmentCenter;
    [inputView addSubview:label];
    
    _phoneTextField = [[UITextField alloc]initWithFrame:CGRectMake(80, 0, [UIScreen mainScreen].bounds.size.width - 80, 44)];
    _phoneTextField.text=_contactModel.phoneNumber;
    [inputView addSubview:_phoneTextField];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messageArray.count;
}

#pragma mark - Messages view delegate
- (void)sendPressed:(UIButton *)sender withText:(NSString *)text{
    
    NSString* phoneNumber = _contactModel.phoneNumber ? _contactModel.phoneNumber : _phoneTextField.text;
    
    MessageModel *message = [[MessageModel alloc] initWithMsgId:rand() text:text date:[NSDate date] msgType:JSBubbleMessageTypeOutgoing phone:phoneNumber];
    __block MessageViewController *vc = self;
    [GPhoneCallService.sharedManager sendMsgWith:message];
    GPhoneCallService.sharedManager.messageBlock = ^(BOOL succeed){
        dispatch_sync(dispatch_get_main_queue(), ^(){
            if (succeed) {
                [vc.messageArray addObject:message];
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
