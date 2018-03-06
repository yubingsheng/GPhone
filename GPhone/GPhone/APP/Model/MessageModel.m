 

#import "MessageModel.h"

@implementation MessageModel

- (instancetype)initWithMsgId:(int)msgId text:(NSString *)text date:(NSDate *)date msgType:(NSInteger)msgType phone:(NSString *)phone {
    self = [super init];
    if (self) {
        _msgId = msgId;
        _text = text;
        _date = date;
        _messageType = msgType;
        _phone = phone;
    }
    return self;
}

@end
