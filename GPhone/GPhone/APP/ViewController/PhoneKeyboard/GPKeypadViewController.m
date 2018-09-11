//
//  GPKeypadViewController.m
//  GPhone
//
//  Created by Dylan on 2017/12/8.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPKeypadViewController.h"

@interface GPKeypadViewController ()<JCDialPadDelegate>

@end

@implementation GPKeypadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.view setBackgroundColor:[UIColor yellowColor]];
    
    JCDialPad *pad = [[JCDialPad alloc] initWithFrame:self.view.bounds];
//    [pad setBackgroundColor:[UIColor lightGrayColor]];
    pad.formatTextToPhoneNumber = YES;
    pad.buttons = [JCDialPad defaultButtons];
    pad.delegate = self;
    [self.view addSubview:pad];

}

#pragma mark - JCDialPadDelegate
-(void)dialingWith:(NSString *)phone {
     NSLog(@"---%@",phone);
    if(![phone isEqualToString:@""]){
//        ContactModel *model = [[ContactModel alloc]initWithId:0 time:1 identifier:@"" phoneNumber:phone fullName:@"" creatTime:[GPhoneHandel dateToStringWith:[NSDate date]]];
//        [GPhoneCallService.sharedManager dialWith:model];
    }

}

-(void)hangUp {
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
