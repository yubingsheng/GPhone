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
    
    [self.signalStrengthBGView addSubview:self.phoneSignalView];
    _usedView.layer.cornerRadius = 6;
    [super awakeFromNib];
}

- (PhoneSignalView*)phoneSignalView {
    if (!_phoneSignalView) {
        _phoneSignalView = [[PhoneSignalView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
        _phoneSignalView.spacing = 1;
        _phoneSignalView.lineWidth = 3;
        _phoneSignalView.backgroundColor = [UIColor clearColor];
        
    }
    return _phoneSignalView;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
