//
//  PhoneSignalView.h
//  CAReplicatorLayer_demo
//
//  Created by Dylan on 2018/1/24.
//  Copyright © 2018年 Dylan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhoneSignalView : UIView

/**
 数量
 */
@property (nonatomic, readonly) NSInteger numberOfStar;

/**
 间距
 */
@property (nonatomic)CGFloat spacing;

/**
 宽度
 */
@property (nonatomic)CGFloat lineWidth;

/**
 信号强度  0 - 5
 */
@property (nonatomic)NSInteger signalStrength;


/**
 信号的颜色
 */
@property (nonatomic,strong)UIColor* signalColor;

/**
 信号的颜色
 */
@property (nonatomic,strong)UIColor* defaultSignalColor;


/**
 无信号的颜色
 */
@property (nonatomic,strong)UIColor* notSignalColor;



@end
