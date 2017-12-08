//
//  GPKeypadViewController.m
//  GPhone
//
//  Created by Dylan on 2017/12/8.
//  Copyright © 2017年 郁兵生. All rights reserved.
//

#import "GPKeypadViewController.h"
#import "JCDialPad.h"

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

- (BOOL)dialPad:(JCDialPad *)dialPad shouldInsertText:(NSString *)text forButtonPress:(JCPadButton *)button {
    
    NSLog(@"%@",text);
    return YES;
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
