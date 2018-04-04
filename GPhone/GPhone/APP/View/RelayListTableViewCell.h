//
//  RelayListTableViewCell.h
//  GPhone
//
//  Created by 郁兵生 on 2018/1/25.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSignalView.h"

@interface RelayListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *relayNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *netWorkLabel;
@property (weak, nonatomic) IBOutlet UIView *signalStrengthBGView;
@property (weak, nonatomic) IBOutlet UILabel *usedView;

@property (nonatomic,strong)PhoneSignalView* phoneSignalView;

+ (id)loadNib;

@end
