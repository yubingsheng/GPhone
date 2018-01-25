//
//  RelayListTableViewCell.m
//  GPhone
//
//  Created by 郁兵生 on 2018/1/25.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "RelayListTableViewCell.h"

@implementation RelayListTableViewCell

+ (id)loadNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"RelayListTableViewCell" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
