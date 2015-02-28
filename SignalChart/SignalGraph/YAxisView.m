//
//  YAxisView.m
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import "YAxisView.h"
#import "CoreSignalGraphView.h"

@implementation YAxisView

- (void)drawGuidelinesWithContext:(CGContextRef)context {
    if (self.signalGraph != NULL) {
        CGContextSetLineWidth(context, 0.5);
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        
        CGFloat normal[1]={1};
        CGContextSetLineDash(context,0,normal,0);
        
        CGContextMoveToPoint(context, self.frame.size.width, 0);
        CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
        
        NSDictionary *attributes = @{NSFontAttributeName:self.textFont};

        CGFloat step = (self.signalGraph.maxValue - self.signalGraph.minValue) / self.signalGraph.parent.denominator;
        CGFloat v = self.signalGraph.minValue;
        
        for (int i = 0; i < self.main.denominator; i++) {
            CGFloat y = [self.signalGraph getPixelY:v];
            
            if (y < 0)
                break;

            NSString* label = [NSString stringWithFormat:@"%.0f", v];
            
            CGSize labelSize = [label sizeWithAttributes:attributes];
            CGRect labelRect = CGRectMake(self.frame.size.width - 8 - labelSize.width,
                                          y - labelSize.height / 2,
                                          labelSize.width,
                                          labelSize.height);

            if (CGRectContainsRect(self.frame, labelRect)) {
                CGContextMoveToPoint(context, self.frame.size.width - 5, y);
                CGContextAddLineToPoint(context, self.frame.size.width, y);
            }
            
            [label drawInRect:labelRect withAttributes:attributes];

            int subCount = self.main.stepHeight / self.main.minStepHeight;
            CGFloat subStep = self.main.stepHeight / subCount;
            for (int i = 1; i < subCount; i++) {
                CGFloat subY = y - i * subStep;
                CGFloat subValue = v + subStep * i;
                NSString* label = [NSString stringWithFormat:@"%.0f", subValue];
                
                CGSize labelSize = [label sizeWithAttributes:attributes];
                CGRect labelRect = CGRectMake(self.frame.size.width - 8 - labelSize.width,
                                              subY - labelSize.height / 2,
                                              labelSize.width,
                                              labelSize.height);
                if (CGRectContainsRect(self.frame, labelRect)) {
                    CGContextMoveToPoint(context, self.frame.size.width - 5, subY);
                    CGContextAddLineToPoint(context, self.frame.size.width, subY);
                }
                
                [label drawInRect:labelRect withAttributes:attributes];
            }

            v += step;
        }
        
    endPath:
        CGContextStrokePath(context);
    }
}

@end
