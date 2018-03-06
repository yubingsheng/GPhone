

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (nonatomic, assign) int msgId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger messageType;
@property (nonatomic, strong) NSString *phone;

- (instancetype)initWithMsgId:(int)msgId text:(NSString *)text date:(NSDate *)date msgType:(NSInteger)msgType phone:(NSString *)phone;


@end
