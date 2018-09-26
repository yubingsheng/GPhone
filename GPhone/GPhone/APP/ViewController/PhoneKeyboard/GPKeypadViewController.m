//
//  GPKeypadViewController.m
//  GPhone
//
//  Created by Dylan on 2017/12/8.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPKeypadViewController.h"

@interface GPKeypadViewController ()<JCDialPadDelegate>
@property (strong,nonatomic) JCDialPad *pad;
@end

@implementation GPKeypadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.view setBackgroundColor:[UIColor yellowColor]];
    
    _pad = [[JCDialPad alloc] initWithFrame:self.view.bounds];
//    [pad setBackgroundColor:[UIColor lightGrayColor]];
    _pad.formatTextToPhoneNumber = YES;
    _pad.buttons = [JCDialPad defaultButtons];
    _pad.delegate = self;
    [self.view addSubview:_pad];

}
- (void)addRelay {
    GMobileTextFieldViewController *alert = [[GMobileTextFieldViewController alloc]initWithNibName:@"GMobileTextFieldViewController" bundle:nil];
    alert.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    alert.modalPresentationStyle= UIModalPresentationCustom;
    __weak typeof(self) weakSelf = self;
    alert.comfireBlock = ^(NSString *sn, NSString *name){
        NSNumber *relaySN = [NSNumber numberWithInteger:sn.integerValue];
        if (relaySN.integerValue == GPhoneConfig.sharedManager.relaySN.integerValue) {
            [weakSelf showToastWith:@"该gPhone已存在，请勿重复添加"];
            return ;
        }
        [GPhoneCallService.sharedManager relayLoginWith:[relaySN unsignedIntValue] relayName:name];
        GPhoneCallService.sharedManager.addRelayBlock = ^(BOOL success){
            [weakSelf showToastWith:@"添加成功，可正常拨打电话了"];
        };
        GPhoneCallService.sharedManager.addRelayFailedBlock = ^(NSInteger errorCode) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"gMobile不在线"  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil]];
            [weakSelf.navigationController presentViewController:alert animated:YES completion:nil];
        };
    };
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}
#pragma mark - JCDialPadDelegate
-(void)dialingWith:(NSString *)phone {
    if (_relaySN == 0) {
        _pad.isDialing = !_pad.isDialing;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"gMobile不在线"  preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler: nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"去添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf addRelay];
        }]];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (![GPhoneContactManager checkPhone:phone]) {
//        [self showToastWith:@"请输入正确的手机号"];
//        return;
    }
    if(![phone isEqualToString:@""]){
        ContactModel *model = [[ContactModel alloc]initWithId:0 time:1 identifier:@"" phoneNumber:phone fullName:_pad.nameLabel.text creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
        [GPhoneCallService.sharedManager dialWith:model];
        __weak typeof(self) weakSelf = self;
        GPhoneCallService.sharedManager.relayStatusBlock = ^(BOOL succeed) {
            if (!succeed) {
                dispatch_sync(dispatch_get_main_queue(), ^(){
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat: @"gMobile‘%@’鉴权失败，请在gMobile管理里删除此gMobile并重新添加。",[GPhoneConfig.sharedManager relayName]]  preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler: nil]];
                    [weakSelf.navigationController presentViewController:alert animated:YES completion:nil];
                });
               
            }
        };
    }

}
- (BOOL)dialPad:(JCDialPad *)dialPad shouldInsertText:(NSString *)text forButtonPress:(JCPadButton *)button {
    _pad.nameLabel.text = [GPhoneContactManager.sharedManager getContactInfoWith:dialPad.rawText];
    return YES;
}
-(void)hangUp{
         [GPhoneCallService.sharedManager hangup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
