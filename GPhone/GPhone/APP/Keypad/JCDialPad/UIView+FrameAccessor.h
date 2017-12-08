//
//  UIView+FrameAccessor.h
//  FrameAccessor
//
//  Created by Alex Denisov on 18.03.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>

@interface UIView (FrameAccessor)

- (CGPoint)origin;
- (void)setOrigin:(CGPoint)newOrigin;
- (CGSize)size;
- (void)setSize:(CGSize)newSize;

- (CGFloat)x;
- (void)setX:(CGFloat)newX;
- (CGFloat)y;
- (void)setY:(CGFloat)newY;

- (CGFloat)height;
- (void)setHeight:(CGFloat)newHeight;
- (CGFloat)width;
- (void)setWidth:(CGFloat)newWidth;

- (CGFloat)bottom;
- (void)setBottom:(CGFloat)newBottom;
- (CGFloat)right;
- (void)setRight:(CGFloat)newRight;

@end
