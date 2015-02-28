//
//  CoreSignalGraphView.h
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_VALUE_DENOMINATOR   8

@class SignalGraph;
@class XAxisView;
@class YAxisView;
@interface CoreSignalGraphView : UIView {
@private NSMutableArray* _signalGraphs;
@private NSMutableDictionary* _dicGraphs;
    
@private BOOL _virgin;
    
@private CGPoint oldTranslatedPoint;
@private CGFloat oldPinchWidth;
@private CGFloat oldPinchHeight;
}

@property int64_t firstTime;

@property CGFloat stepWidth;
@property CGFloat stepHeight;

@property (readonly) CGFloat minStepWidth;
@property (readonly) CGFloat maxStepWidth;

@property (readonly) CGFloat minStepHeight;
@property (readonly) CGFloat maxStepHeight;

// y축은 단계 갯수. 기본값은 8이지만 변경될 수 있다.
@property int denominator;

@property CGFloat offsetx;
@property CGFloat offsety;

@property XAxisView* xAxis;
@property YAxisView* yAxis;

- (void)reset;

- (void)addSignalGraph:(SignalGraph*)graph withName:(NSString*)name;
- (void)addConcurrentSignals:(float*)signals times:(int64_t*)times;

- (SignalGraph*)selectSignalGraphAt:(NSUInteger)index;
- (SignalGraph*)selectSignalGraphWithName:(NSString*)name;
- (SignalGraph*)signalGraphWithName:(NSString*)name;

- (void)queueByName:(NSString*)name value:(float)value time:(int64_t)time;

- (void)removeAllSignalGraphs;

- (void)offsetIndex:(int)offset;
- (void)addSkipIndex:(int)offset;

@end
