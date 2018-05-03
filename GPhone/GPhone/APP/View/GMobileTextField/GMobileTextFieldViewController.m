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


@end

@implementation GMobileTextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.alertTitle.text = @"提示";
    self.alertMessage.text = @"添加gMobile";
    self.nameTextField.placeholder = @"请输入gMobile的序列号";
    self.passwordTextfield.placeholder = @"请输入gMobile起一个昵称";
    
}

- (IBAction)leftButtonClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)rightButtonClick:(UIButton *)sender {
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
