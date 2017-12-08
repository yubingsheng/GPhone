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

@interface CallHistoryViewController ()<CNContactPickerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation CallHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_segmentedControl addTarget:self action:@selector(indexDidChangeForSegmentedControl:) forControlEvents:UIControlEventValueChanged];
    [self requestAuthorizationForAddressBook];
}

- (void)requestAuthorizationForAddressBook {
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"已授权");
            } else {
                NSLog(@"授权失败, error=%@", error);
            }
        }];
    }
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
    NSLog(@"%@--%@",name, phoneNumber);
}

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
