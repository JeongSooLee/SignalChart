//
//  AxisView.h
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 5..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoreSignalGraphView;

@interface AxisView : UIView

@property UIColor* lineColor;
@property UIColor* textColor;
@property UIFont* textFont;
@property CoreSignalGraphView* main;

- (id)initWithFrame:(CGRect)frame;
- (void)drawGuidelinesWithContext:(CGContextRef)context;

@end
