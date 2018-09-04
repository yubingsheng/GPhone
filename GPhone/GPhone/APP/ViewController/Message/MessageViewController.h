//
//  MessageViewController.h
//  GPhone
//
//  Created by 郁兵生 on 2017/11/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
typedef void (^CommonBlock)(ContactModel *object); //普通block

@interface MessageViewController : JSMessagesViewController
@property (strong, nonatomic) ContactModel *contactModel;
@property (copy, nonatomic) CommonBlock messageBlock;
@property (assign, nonatomic) BOOL isNew;
@end
