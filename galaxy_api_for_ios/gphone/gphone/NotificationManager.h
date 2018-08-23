//
//  gphone
//
//  Created by lixs on 2017/8/21.
//  Copyright © 2017年 lixs. All rights reserved.
//

@interface NotificationManager : NSObject
+ (NotificationManager *)sharedClient;

- (void)initWithServer;
@end
