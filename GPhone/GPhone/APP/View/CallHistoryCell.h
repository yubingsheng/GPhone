//
//  CallHistoryCell.h
//  GPhone
//
//  Created by 杨正锋 on 2017/12/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *relayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

+ (id)loadNib;
@end
