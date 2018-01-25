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
    unsigned int relaySN = 0x11223344;
//    NSLog(@"%@", [NSString stringWithFormat:@"%d",relaySN]);
    [_gphoneCallService relayStatus:relaySN];
    // Do any additional setup after loading the view from its nib.
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
        [_tableView reloadData];
    });
    
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    cell.signalStrengthLabel.text = [NSString stringWithFormat:@"signal: %d", model.signalStrength];
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
@end
