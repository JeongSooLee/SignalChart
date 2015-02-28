//
//  SignalGraph.m
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import "SignalGraph.h"

@implementation SignalGraph

- (id)initWithFrame:(CGRect)frame min:(float)min max:(float)max unit:(NSString*)unit quota:(int)quota {
    self = [super init];
    if (self) {
        _frame = frame;
        _quota = quota;
        _dataLength = 0;
        _offsetIndex = 0;
        _tailIndex = -1;
        _skipIndex = 1;
        _lastTime = -1;
        
        self.minValue = min;
        self.maxValue = max;
        self.unit = unit;

        self.gridColor = [UIColor grayColor];
        self.selected = NO;
        
        _values = malloc(_quota * sizeof(float));
        memset(_values, min, _quota * sizeof(float));

        _times = malloc(_quota * sizeof(int64_t));
        memset(_times, 0, _quota * sizeof(int64_t));

        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black

        self.color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    }
    
    return self;
}

- (void)drawWithContext:(CGContextRef)context {
    if (self.parent != NULL) {
        if (self.selected)
            [self drawGridWithContext:context];
        
        [self drawLineWithContext:context];
    }
}

- (void)drawGridWithContext:(CGContextRef)context {

    CGContextSetLineWidth(context, 0.2);
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);

    CGFloat dashPattern[]= {6.0, 5};
    CGContextSetLineDash(context, 0.0, dashPattern, 2);

    int mx = (int)(self.parent.offsetx / self.parent.stepWidth);
    int my = (int)(self.parent.offsety / self.parent.stepHeight);
    
    // draw vertical grid line
    CGFloat x = _frame.size.width + self.parent.offsetx - mx * self.parent.stepWidth;
    CGFloat y = _frame.size.height + self.parent.offsety - my * self.parent.stepHeight;
    CGFloat g = 0;
    
    while (x >= 0) {
        g += self.parent.stepWidth;
        if (g >= 20) {
            CGContextMoveToPoint(context, x, 0);
            CGContextAddLineToPoint(context, x, y);
            g = 0;
        }
        
        x -= self.parent.stepWidth;
    }
    
    // draw horizontal grid line
    x = _frame.size.width + self.parent.offsetx - mx * self.parent.stepWidth;
    y = _frame.size.height + self.parent.offsety - my * self.parent.stepHeight;
    
    while (y >= 0) {
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, x, y);

        int subCount = self.parent.stepHeight / self.parent.minStepHeight;
        CGFloat subStep = self.parent.stepHeight / subCount;
        for (int i = 1; i < subCount; i++) {
            CGFloat subY = y - i * subStep;
            CGContextMoveToPoint(context, 0, subY);
            CGContextAddLineToPoint(context, x, subY);
        }
        
        y -= self.parent.stepHeight;
    }

    CGContextStrokePath(context);
}

- (void)drawLineWithContext:(CGContextRef)context {
    if (self.selected)
        CGContextSetLineWidth(context, 3);
    else
        CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);

    CGFloat normal[1]={1};
    CGContextSetLineDash(context,0,normal,0);

    CGFloat x = _frame.size.width + self.parent.offsetx;
    
    int index = _tailIndex - _offsetIndex;
    
    if (index >= 0) {
        int i;
        
        for (i = index; i >= 0; i -= _skipIndex) {
            CGFloat y = [self getPixelY:_values[i]];
            
            if (i == index)
                CGContextMoveToPoint(context, x, y);
            else
                CGContextAddLineToPoint(context, x, y);
            
            if (x < 0)
                goto endPath;

            x -= self.parent.stepWidth;
        }
        
        // i는 반드시 0보다 작거나 같다.
        for (int j = _quota + i - 1; j >= (_tailIndex + 1); j -= _skipIndex) {
            CGFloat y = [self getPixelY:_values[j]];
            
            CGContextAddLineToPoint(context, x, y);
            
            if (x < 0)
                goto endPath;
            
            x -= self.parent.stepWidth;
        }
    } else {
        for (int i = _quota + index; i >= (_tailIndex + 1); i -= _skipIndex) {
            CGFloat y = [self getPixelY:_values[i]];
            
            if (i == (_quota + index))
                CGContextMoveToPoint(context, x, y);
            else
                CGContextAddLineToPoint(context, x, y);
            
            if (x < 0)
                goto endPath;
            
            x -= self.parent.stepWidth;
        }
    }
    
endPath:
    
    CGContextStrokePath(context);
}

- (CGFloat)getPixelY:(float)value {
    CGFloat y = (value - _minValue) / (_maxValue - _minValue) * (self.parent.stepHeight * self.parent.denominator);
    return self.parent.frame.size.height - (y - self.parent.offsety);
}

- (void)queue:(float)value time:(int64_t)time {
    // U 모델의 경우, 필터가 디폴트로 5개로 선택되어 있음에도 불구하고 총 6개의 데이터가 날라오고
    // 이중 2개는 냉각수온도(ceshi_6_8로 naming됨)로 중복된 데이터이다. 이로 인해 냉각수온도의 graph만 한번에 두칸씩 이동하는 문제가 있다.
    // 데이터의 중복도 해결해야 하지만 우선은 queueByName 메소드가 중복된 데이터를 삽입할 수 없도록 보완한다.
    if (_lastTime == time)
        return;
    
    if (value > _maxValue)
        value = _maxValue;
    
    if (value < _minValue)
        value = _minValue;

    _tailIndex++;
    
    if (_tailIndex > (_quota - 1))
        _tailIndex = 0;
    else
        _dataLength++;

    _values[_tailIndex] = value;
    _times[_tailIndex] = time;

    _lastTime = time;
}

- (void)offsetIndex:(int)offset { // (-) scroll to left, (+) scroll to right
    _offsetIndex += offset;
    
    if (_offsetIndex < 0)
        _offsetIndex = 0;
    
    if (_offsetIndex > _quota)
        _offsetIndex = _quota;
}

- (void)scroll:(CGSize)offset {
    
}

@end
