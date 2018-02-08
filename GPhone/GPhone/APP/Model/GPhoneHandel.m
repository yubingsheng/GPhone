//
//  GPHoneHandel.m
//  GPhone
//
//  Created by 郁兵生 on 2018/1/26.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GPhoneHandel.h"

@implementation GPhoneHandel

#pragma mark - Handel

+ (NSMutableArray *)callHistoryContainWith:(ContactModel *)contactModel {
    BOOL contain = NO;
    if (contactModel.fullName.length == 0) {
        contactModel.fullName = contactModel.phoneNumber;
    }
    contactModel.relaySN = GPhoneConfig.sharedManager.relaySN;
    contactModel.relayName = GPhoneConfig.sharedManager.relayName;
    NSMutableArray * history =  [NSMutableArray arrayWithArray:GPhoneConfig.sharedManager.callHistoryArray]; 
    for (NSInteger i = 0; i < history.count; i++) {
        ContactModel * tmpContact = history[i];
        if ([contactModel.phoneNumber isEqualToString:tmpContact.phoneNumber]) {
            contain = YES;
            tmpContact.time ++;
            contactModel = tmpContact;
            [history removeObjectAtIndex:i];
            i = history.count - 1;
        }
    }
    if (contain) {
        contactModel.creatTime = [GPhoneHandel dateToStringWith:[NSDate date]];
    }
    [history insertObject:contactModel atIndex:0];
    GPhoneConfig.sharedManager.callHistoryArray = history;
    return history;
}

#pragma mark - NSDate helpHandel

+ (NSString *)dateToStringWith:(NSDate *)date {
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    return currentDateString;
}
+ (NSString *)friendlyTime:(NSString *)datetime
{
    NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    }
    NSDate *date = [dateFormatter dateFromString:datetime];
    //1460710590 (7)
    //1460706990 (8)
    time_t createdAt = [date timeIntervalSince1970];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    createdAt=createdAt-(zone.secondsFromGMT-8*60*60);
    
    NSString *_timestamp;
    // Calculate distance time string
    //
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);
    if (distance < 0) distance = 0;
    if (distance<10)
    {
        _timestamp = @"刚刚";
    }
    else if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"秒前" : @"秒前"];
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    }
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"小时前" : @"小时前"];
    }
    else if(distance < 60 * 60 * 24*2)
    {
        //        distance = distance / 60 / 60 / 24;
        _timestamp = @"昨天";
    }
    else if(distance < 60 * 60 * 24*3)
    {
        //        distance = distance / 60 / 60 / 24;
        _timestamp = @"前天";
    }
//    else if (distance < 60 * 60 * 24 * 7) {
//        distance = distance / 60 / 60 / 24;
//        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"天前" : @"天前"];
//    }
    else{
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
        NSDateComponents *_comps = [calendar components:units fromDate:[NSDate date]];
        //        NSInteger nowmonth = [_comps month];
        NSInteger nowyear = [_comps year];
        //        NSInteger nowday = [_comps day];
        
        _comps = [calendar components:units fromDate:date];
        //        NSInteger oldmonth = [_comps month];
        NSInteger oldyear = [_comps year];
        //        NSInteger oldday = [_comps day];
        
        
        NSDate *dt = [dateFormatter dateFromString:datetime];
        if (oldyear < nowyear) {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        }else {
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            
        }
        _timestamp = [dateFormatter stringFromDate:dt];
    }
    return _timestamp;
}

#pragma mark - 10进制、16进制互转

- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}
- (unsigned int)getHexByDecimal:(NSInteger)decimal {
    
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    hex = [@"0x" stringByAppendingString:hex];
    unsigned int order = (unsigned int)[hex intValue];
    return order;
}
@end
