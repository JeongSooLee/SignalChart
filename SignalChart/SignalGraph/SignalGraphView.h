//
//  SignalGraphView.h
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//@private CoreSignalGraphView* _graphView;


#import <UIKit/UIKit.h>

@class CoreSignalGraphView;
@class XAxisView;
@class YAxisView;
@class SignalGraph;

@interface SignalGraphView : UIView {
@private XAxisView* _xAxisView;
@private YAxisView* _yAxisView;
@private CoreSignalGraphView* _graphView;    
}

@property (readonly) CoreSignalGraphView *contentView;
@property int denominator;

- (void)addSignalGraph:(SignalGraph*)graph widthName:(NSString*)name;
- (void)addConcurrentSignals:(float*)signals times:(int64_t*)times;
- (void)removeAllSignalGraphs;
- (void)queueByName:(NSString*)name value:(float)value time:(int64_t)time;
- (void)setFirstTime:(int64_t)time;

- (void)selectSignalGraphAt:(NSUInteger)index;
- (void)selectSignalGraphWithName:(NSString*)name;
- (void)reset;

- (void)zoom:(int)value;

@end
