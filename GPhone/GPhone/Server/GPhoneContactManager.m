//
//  GPhoneContactManage.m
//  GPhone
//
//  Created by 郁兵生 on 2018/9/12.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GPhoneContactManager.h"
#import "LJPerson.h"
#import "LJContactManager.h"

@implementation GPhoneContactManager
+ (GPhoneContactManager *)sharedManager {
    static dispatch_once_t predicate;
    static GPhoneContactManager * gPhoneContactManager;
    dispatch_once(&predicate, ^{
        gPhoneContactManager = [[GPhoneContactManager alloc] init];
    });
    return gPhoneContactManager;
}

- (void)updateAllContact {
     dispatch_queue_t queue = dispatch_queue_create("updateContact",  NULL);
    dispatch_async(queue, ^{
        [[LJContactManager sharedInstance] accessContactsComplection:^(BOOL succeed, NSArray<LJPerson *> *contacts) {
            NSMutableArray *personArray = [[NSMutableArray alloc]init];
            for (LJPerson *person in contacts) {
                GPhoneContactModel *contactModel = [[GPhoneContactModel alloc]init];
                contactModel.fullName = person.fullName;
                for (LJPhone *phone in person.phones) {
                    [contactModel.phoneArray addObject:phone.phone];
                }
                [personArray addObject:contactModel];
            }
            [GPhoneCacheManager.sharedManager archiveObject:personArray forKey:CONTACTS];
        }];
    });
}

- (NSString *) getContactInfoWith:(NSString*)phoneNumber {
    NSArray *personArray = [GPhoneCacheManager.sharedManager unarchiveObjectforKey:CONTACTS];
    NSString *name = phoneNumber;
    for (NSInteger i = 0; i< personArray.count; i++) {
        GPhoneContactModel *contactModel = personArray[i];
        BOOL isContain = NO;
        for (NSString *phone in contactModel.phoneArray) {
            if ([phone isEqualToString:phoneNumber]) {
                NSLog(@"phone == %@",phone);
                isContain = YES;
                i = personArray.count -1;
                name = contactModel.fullName;
            }
        }
    }
    personArray = nil;
    return name;
}

+ (BOOL)checkPhone:(NSString *)phoneNumber {
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0-9])|(17[0-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:phoneNumber];
    NSLog(@"phone === %@", phoneNumber);
    if (!isMatch){
        return NO;
    }
    return YES;
}

@end
