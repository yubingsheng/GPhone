//
//  CallHistoryViewController.h
//  GPhone
//
//  Created by 郁兵生 on 2017/12/28.
//  Copyright © 2017年 郁兵生. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface RTCButton : UIButton

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName isVideo:(BOOL)isVideo;

+ (instancetype)rtcButtonWithTitle:(NSString *)title imageName:(NSString *)imageName isVideo:(BOOL)isVideo;

- (instancetype)initWithTitle:(NSString *)title noHandleImageName:(NSString *)noHandleImageName;

+ (instancetype)rtcButtonWithTitle:(NSString *)title noHandleImageName:(NSString *)noHandleImageName;

@end
