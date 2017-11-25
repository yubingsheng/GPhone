//
//  GContactsManager.h
//  GPhone
//
//  Created by Dylan on 2017/11/23.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GContactsManager : NSObject

@property (nonatomic, readonly) BOOL authorizationStatus;

@property (nonatomic, strong)NSMutableArray* contacts;


+ (instancetype)contactsManager;

@end
