//
//  CallHistoryCell.m
//  GPhone
//
//  Created by 杨正锋 on 2017/12/24.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "CallHistoryCell.h"

@implementation CallHistoryCell

+ (id)loadNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"CallHistoryCell" owner:nil options:nil]lastObject];
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
