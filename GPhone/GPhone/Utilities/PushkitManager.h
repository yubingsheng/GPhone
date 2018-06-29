#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PushkitManager : NSObject

+ (PushkitManager *)sharedClient;

- (void)initWithServer;

@end
