//
//  CallHistoryViewController.m
//  GPhone
//
//  Created by 郁兵生 on 2017/12/8.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "CallHistoryViewController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "CallHistoryCell.h"


@interface CallHistoryViewController ()<CNContactPickerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *callHistoryArray;
@end

@implementation CallHistoryViewController

- (void)viewWillAppear:(BOOL)animated {
    [super  viewWillAppear:animated];
    _callHistoryArray = GPhoneConfig.sharedManager.callHistoryArray;
    [_tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_segmentedControl addTarget:self action:@selector(indexDidChangeForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    [self requestAuthorizationForAddressBook];
//    unsigned int x = 0x11223344;
    
    NSNumber *relaySN = [NSNumber numberWithInteger:GPhoneConfig.sharedManager.relaySN.integerValue];
    NSLog(@"转换完的数字为：%@",relaySN);
    
    [GPhoneCallService.sharedManager relayLogin:[relaySN unsignedIntValue]];
    
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
- (void)dialingWith:(ContactModel *)contact {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"拨号" message:[NSString stringWithFormat:@"呼叫：%@ \n %@",contact.fullName,contact.phoneNumber] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GPhoneCallService.sharedManager dialWith:contact];
        [self viewWillAppear:NO];
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}
#pragma mark - Segment

-(void)indexDidChangeForSegmentedControl:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        CNContactPickerViewController *contactPicker = [[CNContactPickerViewController alloc] init];
        contactPicker.delegate = self;
        contactPicker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [self.navigationController presentViewController:contactPicker animated:YES completion:^{
            _segmentedControl.selectedSegmentIndex = 0;
        }];
    }else {
        
    }
    
}
#pragma mark - CNContactViewControllerDelegate
// 选择某个联系人时调用
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    CNContact *contact = contactProperty.contact;
    NSString *name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
    CNPhoneNumber *phoneValue= contactProperty.value;
    NSString *phoneNumber = phoneValue.stringValue;
    [self dismissViewControllerAnimated:YES completion:^{
        ContactModel *model = [[ContactModel alloc]initWithId:0 time:1 identifier:contact.identifier phoneNumber:phoneNumber fullName:name creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
        [self dialingWith:model];
    }];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    
}
#pragma mark - TableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _callHistoryArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idf = @"callhistory";
    CallHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:idf];
    if (!cell) {
        cell = [CallHistoryCell loadNib];
    }
    ContactModel *model = _callHistoryArray[indexPath.row];
    cell.fullNameLabel.text =[NSString stringWithFormat:@"%@(%d)",model.fullName,model.time];
    if (model.fullName.length > 0) {
        cell.numberLabel.text = model.phoneNumber;
    }else  cell.numberLabel.text = @"";
    cell.relayLabel.text = GPhoneConfig.sharedManager.relaySN;
    cell.dateLabel.text = [GPhoneHandel friendlyTime:model.creatTime];
    return cell;
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dialingWith:[_callHistoryArray objectAtIndex:indexPath.row]];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_callHistoryArray removeObjectAtIndex:indexPath.row];
        GPhoneConfig.sharedManager.callHistoryArray = _callHistoryArray;
        [_tableView reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
