//
//  UIView+UIView_.m
//  OFFWAY
//
//  Created by 郁兵生 on 2018/9/13.
//  Copyright © 2018年 XWQ. All rights reserved.
//

#import "UIView+UIView_.h"
IB_DESIGNABLE
@implementation UIView (UIView_)
@dynamic cornerRadius;
@dynamic borderColor;
@dynamic borderWidth;

- (void)setCornerRadius:(CGFloat)cornerRadius{
    self.cornerRadius = cornerRadius;
    self.layer.cornerRadius  = self.cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.borderColor = borderColor;
    self.layer.borderColor = self.borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.borderWidth = borderWidth;
    self.layer.borderWidth = self.borderWidth;
}
@end
