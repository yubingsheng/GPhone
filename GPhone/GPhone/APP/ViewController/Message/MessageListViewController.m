//
//  MessageListViewController.m
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//
#import "MessageHistoryCell.h"
#import "MessageListViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>


@interface MessageListViewController () <UITableViewDelegate,UITableViewDataSource,CNContactPickerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messageHistoryArray;

@end

@implementation MessageListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)reloadData {
    _messageHistoryArray = GPhoneConfig.sharedManager.messageArray;
    [_tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self requestAuthorizationForAddressBook];
    // Do any additional setup after loading the view.
}

- (void)requestAuthorizationForAddressBook {
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"通讯录已授权");
            } else {
                NSLog(@"授权失败, error=%@", error);
            }
        }];
    }
}

#pragma mark - Action

- (IBAction)newConstructionMessageAction:(UIBarButtonItem *)sender {

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"通讯录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
        contactPicker.delegate = self;
        contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [self.navigationController presentViewController:contactPicker animated:YES completion:^{
            
        }];

    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"输入手机号" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            ContactModel *model = [[ContactModel alloc]init];
            [GPhoneHandel messageHistoryContainWith:model];
            MessageViewController *vc = [[MessageViewController alloc]init];
            vc.contactModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        NSLog(@"点击了取消");
        
    }];
    
    
    //把action添加到actionSheet里
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    [actionSheet addAction:action3];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
}
#pragma mark - CNContactViewControllerDelegate
// 选择某个联系人时调用
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    CNContact *contact = contactProperty.contact;
    NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    CNPhoneNumber *phoneValue= contactProperty.value;
    NSString *phoneNumber = [phoneValue.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    
    [self dismissViewControllerAnimated:YES completion:^{
        ContactModel *model = [[ContactModel alloc]initWithId:0 time:1 identifier:contact.identifier phoneNumber:phoneNumber fullName:name creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
        [GPhoneHandel messageHistoryContainWith:model];
        MessageViewController *vc = [[MessageViewController alloc]init];
        vc.contactModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    
}

#pragma mark - TableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageHistoryArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idf = @"callhistory";
    MessageHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:idf];
    if (!cell) {
        cell = [MessageHistoryCell loadNib];
    }
    ContactModel *model = _messageHistoryArray[indexPath.row];
    cell.nameLabel.text = model.fullName;
    cell.timeLabel.text = [GPhoneHandel friendlyTime:model.creatTime];
    MessageModel *messgaeModel = model.messageList.lastObject;
    cell.messageLabel.text = messgaeModel.text;
    cell.unreadView.hidden = model.unread <= 0;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageViewController *vc = [[MessageViewController alloc]init];
    vc.contactModel = _messageHistoryArray[indexPath.row];
     __block MessageListViewController *weakSelf=self;
    vc.messageBlock = ^(ContactModel *model){
        [weakSelf.messageHistoryArray replaceObjectAtIndex:indexPath.row withObject:model];
        GPhoneConfig.sharedManager.messageArray = weakSelf.messageHistoryArray;
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ContactModel *model = _messageHistoryArray[indexPath.row];
        [GPhoneHandel messageTabbarItemBadgeValue:model.unread];
        [_messageHistoryArray removeObjectAtIndex:indexPath.row];
        GPhoneConfig.sharedManager.messageArray = _messageHistoryArray;
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
