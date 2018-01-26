//
//  PhoneSignalView.m
//  CAReplicatorLayer_demo
//
//  Created by Dylan on 2018/1/24.
//  Copyright © 2018年 Dylan. All rights reserved.
//

#import "PhoneSignalView.h"

#define kDEFAULT_NUMBER 5

#define UIColorFromRGB(rgbValue)         [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PhoneSignalView ()

@end

@implementation PhoneSignalView


- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame numberOfStar:kDEFAULT_NUMBER];
}

- (instancetype)initWithFrame:(CGRect)frame numberOfStar:(NSInteger)numberOfStar
{
    self = [super initWithFrame:frame];
    if (self) {
        if (numberOfStar > 10) {
            _numberOfStar = 10;
        }else if (numberOfStar<=0){
            numberOfStar = 1;
        }
        _numberOfStar = numberOfStar;
        
        [self resetFrame];
    }
    return self;
}

// 重设自身的宽度
- (void)resetFrame {
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), (_lineWidth+self.spacing)*_numberOfStar, _lineWidth + _lineWidth*0.5 + (_lineWidth * 0.8) * (_numberOfStar - 1))];
}

- (void)setSpacing:(CGFloat)spacing {
    _spacing = spacing;
    [self resetFrame];
}

-(void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self resetFrame];
}


- (UIColor*)signalColor{
    if (!_signalColor) {
        return UIColorFromRGB(0x00FF00);
    }
    return _signalColor;
}


- (UIColor*)defaultSignalColor {
    if (!_defaultSignalColor) {
        return UIColorFromRGB(0xeeeeee);
    }
    return _defaultSignalColor;
}

- (UIColor*)notSignalColor {
    if (!_notSignalColor) {
        return UIColorFromRGB(0x999999);
    }
    return _notSignalColor;
}

-(void)setSignalStrength:(NSInteger)signalStrength {
    
    [[self.layer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CAShapeLayer* shapeLayer = (CAShapeLayer*)obj;
        if (idx + 1 <= signalStrength) {
            shapeLayer.strokeColor = self.signalColor.CGColor;
        }else if (idx + 1 > signalStrength && idx + 1 <= _numberOfStar){
            shapeLayer.strokeColor = UIColorFromRGB(0xeeeeee).CGColor;
        } else if (idx + 1 > _numberOfStar) {
            if (signalStrength == 0) {
                shapeLayer.strokeColor = UIColorFromRGB(0x999999).CGColor;
            } else {
                shapeLayer.strokeColor = [UIColor clearColor].CGColor;
            }
        }
    }];
    
    _signalStrength = signalStrength;
}



- (void)drawRect:(CGRect)rect {
    
    CGFloat startY = rect.size.height;
    
    // Y轴终点的位置
    CGFloat endY = startY - _lineWidth - _lineWidth * 0.5;
    //循环创建柱状图
    for (int i = 0; i<_numberOfStar; i++) {
        
        UIBezierPath *Polyline = [UIBezierPath bezierPath];
        //设置起点
        [Polyline moveToPoint:CGPointMake(i*(_lineWidth+self.spacing)+_lineWidth/2, startY)];
        //设置终点
        [Polyline addLineToPoint:CGPointMake(i*(_lineWidth+self.spacing)+_lineWidth/2,endY)];
        //设置颜色
        [[UIColor clearColor] set];
        
        //添加到画布
        [Polyline stroke];
        
        //添加CAShapeLayer
        CAShapeLayer *shapeLine = [[CAShapeLayer alloc]init];
        //设置颜色

        shapeLine.strokeColor = UIColorFromRGB(0xeeeeee).CGColor;
        shapeLine.cornerRadius = _lineWidth/2;
        //设置宽度
        shapeLine.lineWidth = _lineWidth;
        //把CAShapeLayer添加到当前视图CAShapeLayer
        [self.layer addSublayer:shapeLine];
        //把Polyline的路径赋予shapeLine
        shapeLine.path = Polyline.CGPath;
        
        
        endY = endY - _lineWidth * 0.8  ;
        
    }
    
    
    CGFloat selfWidth = (_lineWidth + _spacing) * _numberOfStar;
    CGFloat selfHeight = _lineWidth + _lineWidth*0.5 + (_lineWidth * 0.8) * (_numberOfStar - 1);
    
    CGFloat tempWidth = selfWidth/4;
    CGFloat tempHeight = selfHeight/4;
    
    [self addNotSignalLayerWithStartX:tempWidth startY:tempHeight endX:selfWidth - tempWidth endY:selfHeight - tempHeight];
    [self addNotSignalLayerWithStartX:tempWidth startY:selfHeight - tempHeight endX:selfWidth - tempWidth endY:tempHeight];
    
}


- (void)addNotSignalLayerWithStartX:(CGFloat)startX startY:(CGFloat)startY endX:(CGFloat)endX endY:(CGFloat)endY {
    
    UIBezierPath *Polyline = [UIBezierPath bezierPath];
    //设置起点
    [Polyline moveToPoint:CGPointMake(startX, startY)];
    //设置终点
    [Polyline addLineToPoint:CGPointMake(endX, endY)];
    //设置颜色
    [[UIColor clearColor] set];
    //添加到画布
    [Polyline stroke];
    
    //添加CAShapeLayer
    CAShapeLayer *shapeLine = [[CAShapeLayer alloc]init];
    //设置颜色
    shapeLine.strokeColor = [UIColor clearColor].CGColor;
    
//    shapeLine.cornerRadius = _lineWidth/2;
    //设置宽度
    shapeLine.lineWidth = _lineWidth/2;
    //把CAShapeLayer添加到当前视图CAShapeLayer
    [self.layer addSublayer:shapeLine];
    //把Polyline的路径赋予shapeLine
    shapeLine.path = Polyline.CGPath;
    
}



//        //开始添加动画
//        [CATransaction begin];
//        //创建一个strokeEnd路径的动画
//        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        //动画时间
//        pathAnimation.duration = 2.0;
//        //添加动画样式
//        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        //动画起点
//        pathAnimation.fromValue = @0.0f;
//        //动画停止位置
//        pathAnimation.toValue   = @1.0f;
//        //把动画添加到CAShapeLayer
//        [shapeLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
//        //动画终点
//        shapeLine.strokeEnd = 1.0;
//        //结束动画
//        [CATransaction commit];








@end
