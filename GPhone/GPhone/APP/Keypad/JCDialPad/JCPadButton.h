// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 发布代码于最专业的源码分享网站: Code4App.com


/**
 A pin button designed to look like a telephone number button displaying the number, letters and handling it's
 own animation
 */

#import "JCPadButton.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface JCPadButton : UIButton

- (instancetype)initWithMainLabel:(NSString *)main subLabel:(NSString *)sub;
- (instancetype)initWithInput:(NSString *)input iconView:(UIView *)iconView subLabel:(NSString *)sub;

@property (strong, nonatomic) NSString *input;
@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *subLabel;

@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *hightlightedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *mainLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *subLabelFont UI_APPEARANCE_SELECTOR;

@end

extern CGFloat const JCPadButtonHeight;
extern CGFloat const JCPadButtonWidth;
