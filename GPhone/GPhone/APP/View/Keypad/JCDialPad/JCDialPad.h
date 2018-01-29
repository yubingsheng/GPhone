// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 发布代码于最专业的源码分享网站: Code4App.com


#import "JCDialPad.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class JCDialPad, JCPadButton;

@protocol JCDialPadDelegate <NSObject>

@optional
- (BOOL)dialPad:(JCDialPad *)dialPad shouldInsertText:(NSString *)text forButtonPress:(JCPadButton *)button;
- (void)dialingWith:(NSString*)phone;
- (void)hangUp;
@end

@interface JCDialPad : UIView

@property (nonatomic, strong) UIColor *mainColor UI_APPEARANCE_SELECTOR;

@property (strong, nonatomic) NSString *rawText;
@property (nonatomic) BOOL formatTextToPhoneNumber;

@property (nonatomic, strong) UIView* backgroundView;
@property (assign, nonatomic) BOOL showDeleteButton;

@property (nonatomic, strong) NSArray *buttons;

@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UITextField *digitsTextField;

@property (weak, nonatomic) id<JCDialPadDelegate> delegate;
@property (assign, nonatomic) BOOL isDialing;
@property (assign, nonatomic) BOOL isTint;
/**
 Standard cell phone buttons: 0-9, # and * buttons
 */
+ (NSArray *)defaultButtons;

- (id)initWithFrame:(CGRect)frame buttons:(NSArray *)buttons;

@end
