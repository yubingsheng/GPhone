//
//  AppDelegate.h
//  GPhone
//
//  Created by 郁兵生 on 2017/11/7.
//  Copyright © 2017年 郁兵生. All rights reserved.
//
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>
#import "CallKitHandel.h"
#import "GPhoneCallController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) CallKitHandel *callKitHandel;
@property (nonatomic, strong) GPhoneCallController *callController;
@property (strong, nonatomic) UIWindow *window;


@end

