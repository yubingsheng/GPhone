//
//  GMobileTextFieldViewController.h
//  GPhone
//
//  Created by 郁兵生 on 2018/5/2.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ComfireBlock)(NSString *sn, NSString *name); //普通block

@interface GMobileTextFieldViewController : BaseViewController
@property (copy,nonatomic) ComfireBlock comfireBlock;
@end
