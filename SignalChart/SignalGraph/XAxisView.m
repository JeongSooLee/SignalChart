//
//  XAxisView.m
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import "XAxisView.h"
#import "CoreSignalGraphView.h"

@implementation XAxisView

- (void)drawGuidelinesWithContext:(CGContextRef)context {
    if (self.signalGraph == nil)
        return;
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);

    NSDictionary *attributes = @{NSFontAttributeName:self.textFont};
    
    CGFloat normal[1]={1};
    CGContextSetLineDash(context,0,normal,0);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);

    CGFloat x = self.frame.size.width + self.signalGraph.parent.offsetx;
    CGFloat g = 0;

    int index = self.signalGraph.tailIndex - self.signalGraph.offsetIndex;
    if (index >= 0) {
        int i;
        
        for (i = index; i >= 0; i -= self.signalGraph.skipIndex) {
            g += self.main.stepWidth;
            if (g >= 40) {
                double time = (double)(self.signalGraph.times[i] - self.main.firstTime) / 1000.0;
                if (time < 0.0)
                    time = 0.0;
                
                NSString* label = [NSString stringWithFormat:@"%.2lf", time];
                
                CGSize labelSize = [label sizeWithAttributes:attributes];
                CGRect labelRect = CGRectMake(x - (labelSize.width)/2,
                                              8,
                                              labelSize.width,
                                              labelSize.height);
                
                [label drawInRect:labelRect withAttributes:attributes];
                g = 0;
            }
            
            if (x < 0)
                goto endPath;

            x -= self.main.stepWidth;
        }
        
        // i는 반드시 0보다 작거나 같다.
        for (int j = self.signalGraph.quota + i - 1; j >= (self.signalGraph.tailIndex + 1); j -= self.signalGraph.skipIndex) {
            g += self.main.stepWidth;
            if (g >= 40) {
                double time = (double)(self.signalGraph.times[j] - self.main.firstTime) / 1000.0;
                if (time < 0.0)
                    time = 0.0;
                
                NSString* label = [NSString stringWithFormat:@"%.2lf", time];
                
                CGSize labelSize = [label sizeWithAttributes:attributes];
                CGRect labelRect = CGRectMake(x - (labelSize.width)/2,
                                              8,
                                              labelSize.width,
                                              labelSize.height);
                
                [label drawInRect:labelRect withAttributes:attributes];
                g = 0;
            }

            if (x < 0)
                goto endPath;

            x -= self.main.stepWidth;
        }
    } else {
        for (int i = self.signalGraph.quota + index; i >= (self.signalGraph.tailIndex + 1); i -= self.signalGraph.skipIndex) {
            g += self.main.stepWidth;
            if (g >= 40) {
                double time = (double)(self.signalGraph.times[i] - self.main.firstTime) / 1000.0;
                if (time < 0.0)
                    time = 0.0;
                
                NSString* label = [NSString stringWithFormat:@"%.2lf", time];
                
                CGSize labelSize = [label sizeWithAttributes:attributes];
                CGRect labelRect = CGRectMake(x - (labelSize.width)/2,
                                              8,
                                              labelSize.width,
                                              labelSize.height);
                
                [label drawInRect:labelRect withAttributes:attributes];
                g = 0;
            }
            
            if (x < 0)
                goto endPath;

            x -= self.main.stepWidth;
        }
    }

endPath:
    
    CGContextStrokePath(context);
}

@end
