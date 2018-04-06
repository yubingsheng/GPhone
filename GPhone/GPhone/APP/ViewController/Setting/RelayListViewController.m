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
    self.title = @"GMobile列表";
    _tableView.tableFooterView = [UIView new];
    _gphoneCallService = GPhoneCallService.sharedManager;
    _gphoneCallService.delegate = self;
    for (int i = 0; i < [GPhoneConfig.sharedManager.relaysNArray count] ; i++) {
        RelayModel *model = GPhoneConfig.sharedManager.relaysNArray[i];
        [_gphoneCallService relayStatus:model.relaySN relayName:model.relayName];
    }
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addRelay)];
    self.navigationItem.rightBarButtonItem = bar;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)addRelay {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"添加GMobile" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = _relaySN;
    }];
    alert.textFields[0].placeholder = @"GMobile";
    alert.textFields[0].text = _relaySN;
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = _relayName;
    }];
    alert.textFields[1].placeholder = @"昵称";
    alert.textFields[1].text = _relayName;
    [alert addAction:[UIAlertAction actionWithTitle:@"以后添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _relaySN = alert.textFields[0].text;
        _relayName = alert.textFields[1].text;
        if (_relaySN.length ==0) {
            [self showToastWith:@"GMobil不能为空！"];
        }else if (_relayName.length ==0) {
            [self showToastWith:@"GMobil的昵称不能为空！"];
        }else {
            NSNumber *relaySN = [NSNumber numberWithInteger:alert.textFields[0].text.integerValue];
            _relaySN = @"";
            _relayName = @"";
            [GPhoneCallService.sharedManager relayLoginWith:[relaySN unsignedIntValue] relayName:alert.textFields[1].text];
        }
    }]];
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
    [self.relayArray addObject:statusModel];
     [_gphoneCallService hiddenWith:@""];
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
