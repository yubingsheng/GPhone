//
//  CallController.h
//  MyCall
//
//  Created by Mason on 2016/10/12.
//  Copyright © 2016年 Mason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

@interface CallController : NSObject

- (void)startCallWithHandle:(NSString*)handle;
- (void)endCall;

@property (nonatomic, strong) NSUUID* outCallUUID;
//@property (nonatomic, strong) NSString* currentHandle;
@end
