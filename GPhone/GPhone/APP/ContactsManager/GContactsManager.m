//
//  GContactsManager.m
//  GPhone
//
//  Created by Dylan on 2017/11/23.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GContactsManager.h"
#import <Contacts/Contacts.h>
#import "GContact.h"

@implementation GContactsManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self authorization];
        if (self.authorizationStatus) {
            [self getContactList];
        }
        
    }
    return self;
}

+ (instancetype)contactsManager {
    return [[self alloc]init];
}

/**
 获取权限
 */
- (void)authorization {
    
    // 1. 判断当前的授权状态
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //   授权成功
                _authorizationStatus = YES;
            } else {
                //  授权失败
                _authorizationStatus = NO;
            }
        }];
    }else{
        _authorizationStatus = YES;
    }
}



/**
 获取通讯录列表
 */
- (void)getContactList {
    
//    //  判断授权状态
//    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] != CNAuthorizationStatusAuthorized) {
//        NSLog(@"请授权");
//        return ;
//    }
    
    // 2. 获取联系人仓库
    CNContactStore *store = [[CNContactStore alloc] init];
    
    // 3. 创建联系人信息的请求对象
    NSArray *keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    
    // 4. 根据请求Key, 创建请求对象
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    
    // 5. 发送请求
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        
        GContact* gContact = [[GContact alloc]init];
        // 6.1 获取姓名
        NSString *givenName = contact.givenName;  // 名字
        NSString *familyName = contact.familyName;  // 姓氏
        gContact.contactName = [NSString stringWithFormat:@"%@%@",familyName, givenName];
        gContact.contactNamePY = [self pinYinForString:gContact.contactName];
        
        // 6.2 获取电话
        NSArray *phoneArray = contact.phoneNumbers;
        for (CNLabeledValue *labelValue in phoneArray) {
            
            CNPhoneNumber *phoneNumber = labelValue.value;
            gContact.contactMobile = [NSString stringWithFormat:@"%@",phoneNumber];
            
        }
        [self.contacts addObject:gContact];
    }];
}



- (NSString*)pinYinForString:(NSString*)string {
    NSMutableString * pinYin = [[NSMutableString alloc]initWithString:string];
    //1.先转换为带声调的拼音
    if(CFStringTransform((__bridge CFMutableStringRef)pinYin, NULL, kCFStringTransformMandarinLatin, NO)) {
        //2.再转换为不带声调的拼音
        if (CFStringTransform((__bridge CFMutableStringRef)pinYin, NULL, kCFStringTransformStripDiacritics, NO)) {
            NSString *uppercase = [pinYin uppercaseString];
            return uppercase;
        }
    }
    return nil;
}

- (NSMutableArray*)contacts {
    if (!_contacts) {
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}


@end
