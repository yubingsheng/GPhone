//
//  RelayListViewController.m
//  GPhone
//
//  Created by 郁兵生 on 2018/1/24.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "RelayListViewController.h"
#import "RelayStatusModel.h"
#import "GPhoneCallService.h"

@interface RelayListViewController ()<GPhoneCallServiceDelegate>
@property (strong, nonatomic) GPhoneCallService *gphoneCallService;
@end

@implementation RelayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _gphoneCallService = GPhoneCallService.sharedManager;
    _gphoneCallService.delegate = self;
    unsigned int relaySN = 0x11223344;
    [_gphoneCallService relayStatus:relaySN];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - GPhoneServiceDelegate
-(void)relayStatusWith:(RelayStatusModel *)statusModel {
    
}

@end
