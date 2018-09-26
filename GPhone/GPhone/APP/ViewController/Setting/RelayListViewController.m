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
#import <MJRefresh.h>

@interface RelayListViewController ()<GPhoneCallServiceDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) GPhoneCallService *gphoneCallService;
@property (strong, nonatomic) NSMutableArray *relayArray;
@property (strong, nonatomic) NSString *relaySN;
@property (strong, nonatomic) NSString *relayName;
@property (assign, nonatomic) NSInteger isUsed;
@property (assign, nonatomic) BOOL isSuccessed;
@property (strong, nonatomic) NSIndexPath *selectedDndexPath;
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
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
         _isSuccessed = NO;
        if ( [GPhoneConfig.sharedManager.relaysNArray count] == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"gMobile暂未添加，需要立即去j添加新的gMobile吗？" preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(self) weakSelf = self;
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler: nil]];
            [alert addAction:[UIAlertAction actionWithTitle:@"去添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf addRelay];
            }]];
            [_tableView.mj_header endRefreshing];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
            return ;
        }
        [self.relayArray removeAllObjects];
        [self reloadRelaysStatus];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            if (!_isSuccessed) {
                 [_tableView.mj_header endRefreshing];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"gMobile状态刷新失败，下拉重新刷新"  preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil]];
                [self.navigationController presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
    [_tableView.mj_header beginRefreshing];
    
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
    __weak RelayListViewController *vc = self;
    alert.comfireBlock = ^(NSString *sn, NSString *name){
        NSNumber *relaySN = [NSNumber numberWithInteger:sn.integerValue];
        if (relaySN.integerValue == GPhoneConfig.sharedManager.relaySN.integerValue) {
            [vc showToastWith:@"该gPhone已存在，请勿重复添加"];
//            return ;
        }
        [GPhoneCallService.sharedManager relayLoginWith:[relaySN unsignedIntValue] relayName:name];
        GPhoneCallService.sharedManager.addRelayBlock = ^(BOOL success){
            [vc reloadRelaysStatus];
        };
        GPhoneCallService.sharedManager.addRelayFailedBlock = ^(NSInteger errorCode) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"gMobile不在线"  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil]];
            [vc.navigationController presentViewController:alert animated:YES completion:nil];
        };
    };
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)delayMethod {
    [_tableView.mj_header endRefreshing];
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
    __weak typeof(self) weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^(){
        if (_selectedDndexPath) {
            [weakSelf.relayArray replaceObjectAtIndex:weakSelf.selectedDndexPath.row withObject:statusModel];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[weakSelf.selectedDndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (statusModel.netWorkStatus == 0) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"gMobile不在线"  preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    weakSelf.selectedDndexPath = nil;
                }]];
                [self.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }else {
            _isSuccessed = YES;
            [_tableView reloadData];
            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.1];
        }
    });
    if (_relayArray.count == [GPhoneConfig.sharedManager.relaysNArray count]) {
        
    }
}

#pragma mark - TableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block RelayStatusModel * model = [_relayArray objectAtIndex:indexPath.row];
    if (model.relaySN == GPhoneConfig.sharedManager.relaySN.integerValue && [model.relayName isEqualToString:GPhoneConfig.sharedManager.relayName]) {
    }
   
    [_gphoneCallService relayStatus:model.relaySN relayName:model.relayName];
    _selectedDndexPath = indexPath;
//    [GPhoneCallService.sharedManager relayLoginWith:model.relaySN relayName:model.relayName];
//
//    __block RelayListViewController *weakSelf = self;
//    GPhoneCallService.sharedManager.loginBlock = ^(BOOL succeed) {
//        weakSelf.isUsed = indexPath.row;
//        dispatch_sync(dispatch_get_main_queue(), ^(){
//            [weakSelf.tableView reloadData];
//        });
//    };
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
    cell.relayLabel.text = [NSString stringWithFormat:@"%d",model.relaySN];
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
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray: GPhoneConfig.sharedManager.relaysNArray];
        RelayStatusModel * model = [_relayArray objectAtIndex:indexPath.row];
        if (model.relaySN == GPhoneConfig.sharedManager.relaySN.integerValue && [model.relayName isEqualToString:GPhoneConfig.sharedManager.relayName])  {
            [GPhoneCacheManager.sharedManager cleanWithKey:RELAYSN];
            [GPhoneCacheManager.sharedManager cleanWithKey:RELAYNAME];
        }
        [tmpArray removeObjectAtIndex:indexPath.row];
        GPhoneConfig.sharedManager.relaysNArray = tmpArray;
        [_relayArray removeObjectAtIndex:indexPath.row];
        [_tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
@end
