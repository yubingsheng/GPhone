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
@property (strong, nonatomic) NSString *relaySN;
@property (strong, nonatomic) NSString *relayName;
@property (assign, nonatomic) NSInteger isUsed;
@end

@implementation RelayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"gMobile列表";
    _tableView.tableFooterView = [UIView new];
    _gphoneCallService = GPhoneCallService.sharedManager;
    _gphoneCallService.delegate = self;
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addRelay)];
    self.navigationItem.rightBarButtonItem = bar;
    [self reloadRelaysStatus];
    // Do any additional setup after loading the view from its nib.
}

- (void)reloadRelaysStatus {
    for (int i = 0; i < [GPhoneConfig.sharedManager.relaysNArray count] ; i++) {
        RelayModel *model = GPhoneConfig.sharedManager.relaysNArray[i];
        [_gphoneCallService relayStatus:model.relaySN relayName:model.relayName];
    }
}

- (void)addRelay {
    GMobileTextFieldViewController *alert = [[GMobileTextFieldViewController alloc]initWithNibName:@"GMobileTextFieldViewController" bundle:nil];
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.modalPresentationStyle= UIModalPresentationCustom;
    __block RelayListViewController *vc = self;
    alert.comfireBlock = ^(NSString *sn, NSString *name){
        NSNumber *relaySN = [NSNumber numberWithInteger:sn.integerValue];
        [GPhoneCallService.sharedManager relayLoginWith:[relaySN unsignedIntValue] relayName:name];
        GPhoneCallService.sharedManager.addRelayBlock = ^(BOOL success){
            [vc reloadRelaysStatus];
        };
    };
    [self.navigationController presentViewController:alert animated:YES completion:nil];
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
    BOOL contain = NO;
    for (int i = 0; i < [self.relayArray count] ; i++) {
        RelayStatusModel *model = self.relayArray[i];
        if (model.relaySN == statusModel.relaySN && [model.relayName isEqualToString:statusModel.relayName]) {
            contain = YES;
        }
    }
    if (!contain) {
        [self.relayArray addObject:statusModel];
    }
    dispatch_sync(dispatch_get_main_queue(), ^(){
        [_tableView reloadData];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.1];
    });
    if (_relayArray.count == [GPhoneConfig.sharedManager.relaysNArray count]) {
        
    }
    
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    __block RelayStatusModel * model = [_relayArray objectAtIndex:indexPath.row];
    if (model.relaySN == GPhoneConfig.sharedManager.relaySN.integerValue && [model.relayName isEqualToString:GPhoneConfig.sharedManager.relayName]) {
        return;
    }
    [GPhoneCallService.sharedManager relayLoginWith:model.relaySN relayName:model.relayName];
    
    __block RelayListViewController *weakSelf = self;
    GPhoneCallService.sharedManager.loginBlock = ^(BOOL succeed) {
        weakSelf.isUsed = indexPath.row;
        dispatch_sync(dispatch_get_main_queue(), ^(){
            [weakSelf.tableView reloadData];
        });
    };
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
    cell.relayNameLabel.text = model.relayName;
    if (model.netWorkStatus == 0) {
          cell.phoneSignalView.signalStrength = 0;
    }else {
          cell.phoneSignalView.signalStrength = model.signalStrength;
    }
    
    if (model.relaySN == GPhoneConfig.sharedManager.relaySN.integerValue && [model.relayName isEqualToString:GPhoneConfig.sharedManager.relayName]) {
        cell.usedView.hidden = NO;
    } else {
        cell.usedView.hidden = YES;
    }
    return cell;
}

#pragma mark - TableViewDelegate

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_relayArray removeObjectAtIndex:indexPath.row];
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray: GPhoneConfig.sharedManager.relaysNArray];
        [tmpArray removeObjectAtIndex:indexPath.row];
        GPhoneConfig.sharedManager.relaysNArray = tmpArray;
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
@end
