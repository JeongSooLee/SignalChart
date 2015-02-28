//
//  SignalGraphView.m
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import "SignalGraphView.h"
#import "CoreSignalGraphView.h"
#import "XAxisView.h"
#import "YAxisView.h"

#define X_LABEL_FIELD_HEIGHT    32
#define Y_LABEL_FIELD_WIDTH     32

@implementation SignalGraphView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self coordinateWithFrame:frame];
    }
    return self;
}

- (void)coordinateWithFrame:(CGRect)frame {
    CGFloat w = frame.size.width;
    CGFloat h = frame.size.height;
    
    CGRect yAxisFrame = CGRectMake(0, 0, Y_LABEL_FIELD_WIDTH, h/* - X_LABEL_FIELD_HEIGHT*/);
    CGRect graphFrame = CGRectMake(yAxisFrame.size.width, 0, w - yAxisFrame.size.width, h);
    CGRect xAxisFrame = CGRectMake(yAxisFrame.size.width, graphFrame.size.height - X_LABEL_FIELD_HEIGHT, graphFrame.size.width,  X_LABEL_FIELD_HEIGHT);
    
    _graphView = [[CoreSignalGraphView alloc] initWithFrame:CGRectMake(yAxisFrame.size.width, 0, graphFrame.size.width, graphFrame.size.height - X_LABEL_FIELD_HEIGHT)];
    _graphView.backgroundColor = [UIColor whiteColor];
    
    _xAxisView = [[XAxisView alloc] initWithFrame:xAxisFrame];
    _xAxisView.main = _graphView;
   
    _yAxisView = [[YAxisView alloc] initWithFrame:yAxisFrame];
    _yAxisView.main = _graphView;
    
    _graphView.xAxis = _xAxisView;
    _graphView.yAxis = _yAxisView;
    
    [self addSubview:_graphView];    
    [self addSubview:_xAxisView];
    [self addSubview:_yAxisView];
}

- (void)addSignalGraph:(SignalGraph*)graph widthName:(NSString*)name {
    [_graphView addSignalGraph:graph withName:name];
}

- (void)addConcurrentSignals:(float*)signals times:(int64_t*)times {
    [_graphView addConcurrentSignals:signals times:times];
}

- (void)selectSignalGraphAt:(NSUInteger)index {
    _yAxisView.signalGraph = [_graphView selectSignalGraphAt:index];
    _xAxisView.signalGraph = _yAxisView.signalGraph;
    
    [_graphView setNeedsDisplay];
    [_yAxisView setNeedsDisplay];
}

- (void)selectSignalGraphWithName:(NSString*)name {
    _yAxisView.signalGraph = [_graphView selectSignalGraphWithName:name];
    _xAxisView.signalGraph = _yAxisView.signalGraph;
    
    [_graphView setNeedsDisplay];
    [_yAxisView setNeedsDisplay];
}

- (void)removeAllSignalGraphs {
    [_graphView removeAllSignalGraphs];
}

- (CoreSignalGraphView*)contentView {
    return _graphView;
}

- (void)queueByName:(NSString*)name value:(float)value time:(int64_t)time {
    [_graphView queueByName:name value:value time:time];
}

- (void)setFirstTime:(int64_t)time {
    _graphView.firstTime = time;
}

- (void)zoom:(int)value {
    CGFloat newStepWidth = _graphView.stepWidth + value;
    if (newStepWidth < _graphView.minStepWidth) {
        _graphView.stepWidth = _graphView.minStepWidth;
        [_graphView addSkipIndex:1];
    } else if (newStepWidth > _graphView.maxStepWidth) {
        _graphView.stepWidth = _graphView.maxStepWidth;
        [_graphView addSkipIndex:-1];
    } else
        _graphView.stepWidth = newStepWidth;
    
    [_graphView setNeedsDisplay];
    [_xAxisView setNeedsDisplay];
    [_yAxisView setNeedsDisplay];
}

- (void)reset {
    [_graphView reset];
}

/*
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //http://stackoverflow.com/questions/9637203/check-direction-of-scroll-in-uiscrollview
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    if (translation.x > 0) {
        // react to dragging right
    }
    else
    {
        // react to dragging left
    }
    
    NSLog(@"scrollView.contentSize.width = %f", scrollView.contentSize.width);
    NSLog(@"scrollView.contentOffset.x = %f", scrollView.contentOffset.x);
    NSLog(@"translation.x = %f", translation.x);
    NSLog(@"velocity.x = %f", velocity.x);
    NSLog(@"targetContentOffset.x = %f", targetContentOffset->x);
    
    if ((scrollView.contentOffset.x < 0 && velocity.x < 0) ||  // has scrolled left..
        (scrollView.contentOffset.x > targetContentOffset->x && velocity.x > 0)) {
        // 총 몇칸을 옮겨야하는가?
        int offset = (int)(translation.x / _graphView.stepWidth);
        [_graphView offset:offset];
        
        [_graphView setNeedsDisplay];
        [_xAxisView setNeedsDisplay];
    }
}
*/

@end
