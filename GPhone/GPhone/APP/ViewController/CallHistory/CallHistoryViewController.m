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
#import "GMobileTextFieldViewController.h"


@interface CallHistoryViewController ()<CNContactPickerDelegate,UITableViewDelegate,UITableViewDataSource,GPhoneCallServiceDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *callHistoryArray;
@end

@implementation CallHistoryViewController

- (void)viewWillAppear:(BOOL)animated {
    [super  viewWillAppear:animated];
    [self checkRelay];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reload) name:@"reload" object:nil];
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reload" object:self];
}
//实现监听方法
-(void)reload {
    _callHistoryArray = GPhoneConfig.sharedManager.callHistoryArray;
    [_tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_segmentedControl addTarget:self action:@selector(indexDidChangeForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    GPhoneCallService.sharedManager.delegate = self;
    [GPhoneCallService.sharedManager versionCheck];
}

- (void)checkRelay {
    if (!GPhoneConfig.sharedManager.relaySN) {
        GMobileTextFieldViewController *alert = [[GMobileTextFieldViewController alloc]initWithNibName:@"GMobileTextFieldViewController" bundle:nil];
        alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        alert.modalPresentationStyle= UIModalPresentationCustom;
        __weak typeof(self) weakSelf = self;
        alert.comfireBlock = ^(NSString *sn, NSString *name){
            NSNumber *relaySN = [NSNumber numberWithInteger:sn.integerValue];
            [GPhoneCallService.sharedManager relayLoginWith:[relaySN unsignedIntValue] relayName:name];
            GPhoneCallService.sharedManager.addRelayBlock = ^(BOOL success) {
                dispatch_sync(dispatch_get_main_queue(), ^(){
                    [weakSelf reload];
                });
            };
        };
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        //0x11223344 287454020
    }else {
        [self reload];
        
        //        NSNumber *relaySN = [NSNumber numberWithInteger:[GPhoneConfig.sharedManager relaySN].integerValue];
        //        NSLog(@"relaySn：%@ name: %@",relaySN,[GPhoneConfig.sharedManager relayName]);
        //        [GPhoneCallService.sharedManager relayLoginWith:[relaySN unsignedIntValue] relayName:[GPhoneConfig.sharedManager relayName]];
    }
}

- (void)dialingWith:(ContactModel *)contact {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"拨号" message:[NSString stringWithFormat:@"呼叫：%@ \n %@",contact.fullName,contact.phoneNumber] preferredStyle:UIAlertControllerStyleAlert];
    __weak CallHistoryViewController * weakSelf = self;
    __block ContactModel *tmpContact = contact;
    [alert addAction:[UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [GPhoneCallService.sharedManager dialWith: contact];
        GPhoneCallService.sharedManager.relayStatusBlock = ^(BOOL succeed) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"gMobil'%@'已下线，需要重新登录",GPhoneConfig.sharedManager.relayName] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSNumber *relaySN = [NSNumber numberWithInteger:GPhoneConfig.sharedManager.relaySN.integerValue];
                [GPhoneCallService.sharedManager relayLoginWith:[relaySN unsignedIntValue] relayName:GPhoneConfig.sharedManager.relayName];
                [weakSelf dialingWith:tmpContact];
                [weakSelf viewWillAppear:NO];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }]];
            [weakSelf.navigationController presentViewController:alert animated:YES completion:nil];
            
        };
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
        [GPhoneContactManager.sharedManager updateAllContact];
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
    NSString *phoneNumber = [phoneValue.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
    [self dismissViewControllerAnimated:YES completion:^{
        ContactModel *model = [[ContactModel alloc]initWithId:0 time:1 identifier:contact.identifier phoneNumber:phoneNumber fullName:name creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
        [self dialingWith:model];
    }];
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    
}

#pragma mark - GPhoneServiceDelegate

- (void)versionStatusWith:(int)status {
    //实际应用中，如果result返回2，也就是versionMustUpdate，应当立即弹出对话框，提示用户“应用必须升级到最新版本才能继续使用”，用户点击确认后，退出APP
    UIAlertController *alert;
    if (status == 2) {
        alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"应用必须升级到最新版本才能继续使用" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"立即升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
    }
    if (alert) {
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    }
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
    cell.relayLabel.text = model.relayName;
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

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
