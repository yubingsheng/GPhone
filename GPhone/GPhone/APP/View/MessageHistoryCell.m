//
//  MessageHistoryCell.m
//  GPhone
//
//  Created by 郁兵生 on 2018/3/20.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "MessageHistoryCell.h"

@implementation MessageHistoryCell

+ (id)loadNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"MessageHistoryCell" owner:nil options:nil]lastObject];
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
