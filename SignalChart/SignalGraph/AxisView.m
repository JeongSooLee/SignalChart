//
//  AxisView.m
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 5..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import "AxisView.h"

@implementation AxisView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.lineColor = [UIColor grayColor];
        self.textColor = [UIColor grayColor];
        self.textFont = [UIFont systemFontOfSize:10];
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.main != NULL) {
        CGContextSetShouldAntialias(context, YES );
        CGColorSpaceRef linecolorspace = CGColorSpaceCreateDeviceRGB();
        CGContextSetStrokeColorSpace(context, linecolorspace);
        
        [self drawGuidelinesWithContext:context];
        
        CGColorSpaceRelease(linecolorspace);
    }
}

- (void)drawGuidelinesWithContext:(CGContextRef)context {
}

@end
