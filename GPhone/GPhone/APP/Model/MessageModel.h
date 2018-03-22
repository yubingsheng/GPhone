

#import <Foundation/Foundation.h>
#import "GPhoneBaseModel.h"

@interface MessageModel : GPhoneBaseModel

@property (nonatomic, assign) int msgId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger messageType;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) BOOL unRead;

- (instancetype)initWithMsgId:(int)msgId text:(NSString *)text date:(NSDate *)date msgType:(NSInteger)msgType phone:(NSString *)phone;


@end
