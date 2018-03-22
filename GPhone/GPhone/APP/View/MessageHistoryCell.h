//
//  MessageHistoryCell.h
//  GPhone
//
//  Created by 郁兵生 on 2018/3/20.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
+ (id)loadNib;
@end
