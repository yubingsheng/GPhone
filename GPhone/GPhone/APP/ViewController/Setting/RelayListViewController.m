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
#import "RelayListTableViewCell.h"

@interface RelayListViewController ()<GPhoneCallServiceDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GPhoneCallService *gphoneCallService;
@property (strong, nonatomic) NSMutableArray *relayArray;
@end

@implementation RelayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RelayStatus";
    _tableView.tableFooterView = [UIView new];
    _gphoneCallService = GPhoneCallService.sharedManager;
    _gphoneCallService.delegate = self;
     NSNumber *relaySN = [NSNumber numberWithInteger:GPhoneConfig.sharedManager.relaySN.integerValue];
    [_gphoneCallService relayStatus:relaySN.unsignedIntValue];
    
    
    // Do any additional setup after loading the view from its nib.
}


- (void)delayMethod {
    [_tableView reloadData];
}
#pragma mark - LazyLoading

- (NSMutableArray *)relayArray {
    if (_relayArray==nil) {
        _relayArray = [[NSMutableArray alloc]init];
    }
    return _relayArray;
}

#pragma mark - GPhoneServiceDelegate

-(void)relayStatusWith:(RelayStatusModel *)statusModel {
    dispatch_sync(dispatch_get_main_queue(), ^(){
        [self.relayArray addObject:statusModel];
        [self.relayArray addObject:statusModel];
        [self.relayArray addObject:statusModel];
        [_tableView reloadData];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.1];
    });
    
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView reloadData];
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _relayArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idf = @"list";
    RelayListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idf];
    if (cell==nil) {
        cell = [RelayListTableViewCell loadNib];
    }
    RelayStatusModel * model = [_relayArray objectAtIndex:indexPath.row];
    cell.relayNameLabel.text =  [NSString stringWithFormat:@"%d", model.relaySN];
    cell.netWorkLabel.text = [NSString stringWithFormat:@"NetWork: %d", model.netWorkStatus];
//    cell.signalStrengthLabel.text = [NSString stringWithFormat:@"signal: %d", model.signalStrength];
    cell.phoneSignalView.signalStrength = model.signalStrength;
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
@end
