//
//  GMobileTextFieldViewController.m
//  GPhone
//
//  Created by 郁兵生 on 2018/5/2.
//  Copyright © 2018年 郁兵生. All rights reserved.
//

#import "GMobileTextFieldViewController.h"

@interface GMobileTextFieldViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alertTitle;
@property (weak, nonatomic) IBOutlet UILabel *alertMessage;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) NSString *relaySN;
@property (strong, nonatomic) NSString *relayName;

@end

@implementation GMobileTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.alertTitle.text = @"提示";
    self.alertMessage.text = @"添加gMobile";
    self.nameTextField.placeholder = @" 请输入gMobile的序列号";
    self.passwordTextfield.placeholder = @" 请为此gMobile起一个昵称";
    [self.nameTextField becomeFirstResponder];
    
}

- (IBAction)leftButtonClick:(UIButton *)sender {
    _relaySN = self.nameTextField.text;
    _relayName = self.passwordTextfield.text;
    if (_relaySN.length ==0) {
        [self showToastWith:@"gMobil不能为空！"];
    }else if (_relayName.length ==0) {
        [self showToastWith:@"gMobil的昵称不能为空！"];
    }else {
        if (_comfireBlock) {
            _comfireBlock(_relaySN, _relayName);
        }
    }
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)rightButtonClick:(UIButton *)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
