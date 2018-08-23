//
//  ViewController.h
//  gphone
//
//  Created by lixs on 2017/8/21.
//  Copyright © 2017年 lixs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *display;

@property (weak, nonatomic) IBOutlet UITextField *calledNumber;

@property (weak, nonatomic) IBOutlet UITextField *sms;

- (IBAction)dial:(id)sender;

- (IBAction)hangup:(id)sender;

- (IBAction)sms:(id)sender;

- (IBAction)login:(id)sender;

- (IBAction)getRelayStatus:(id)sender;

- (IBAction)answer:(id)sender;
@end

