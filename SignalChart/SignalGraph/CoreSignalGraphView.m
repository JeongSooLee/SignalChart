//
//  GraphView.m
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import "CoreSignalGraphView.h"
#import "SignalGraph.h"
#import "XAxisView.h"
#import "YAxisView.h"

#define MIN_STEP_WIDTH  1.f
#define MAX_STEP_WIDTH  200.f
#define MIN_STEP_HEIGHT  40.f
#define MAX_STEP_HEIGHT  120.f

#define DEFAULT_STEP_WIDTH  40.f
#define DEFAULT_STEP_HEIGHT  40.f

@implementation CoreSignalGraphView
@synthesize xAxis, yAxis;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _signalGraphs = [NSMutableArray array];
        _dicGraphs = [NSMutableDictionary dictionary];
        _minStepWidth = MIN_STEP_WIDTH;
        _maxStepWidth = MAX_STEP_WIDTH;
        _minStepHeight = MIN_STEP_WIDTH;
        _maxStepHeight = MAX_STEP_WIDTH;
        _virgin = YES;
        
        _offsetx = 0;
        _offsety = 0;

        _stepWidth = DEFAULT_STEP_WIDTH;
        _stepHeight = frame.size.height / DEFAULT_VALUE_DENOMINATOR;

        if (_minStepHeight < _stepHeight)
            _minStepHeight = _stepHeight;
        
        _denominator = DEFAULT_VALUE_DENOMINATOR;
        
        _firstTime = [[NSDate date] timeIntervalSince1970] * 1000;
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panRecognizer];
        
        UIPinchGestureRecognizer *pinchRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:pinchRecogniser];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetShouldAntialias(context, YES );
    //CGColorSpaceRef linecolorspace = CGColorSpaceCreateDeviceRGB();
    //CGContextSetStrokeColorSpace(context, linecolorspace);

    for (SignalGraph* graph in _signalGraphs)
        [graph drawWithContext:context];

    //CGColorSpaceRelease(linecolorspace);
}

- (void)addSignalGraph:(SignalGraph*)graph withName:(NSString *)name {
    graph.parent = self;
    
    [_signalGraphs addObject:graph];
    [_dicGraphs setObject:graph forKey:name];
}

- (void)addConcurrentSignals:(float*)signals times:(int64_t*)times {
    if (_virgin) {
        self.firstTime = times[0];
        _virgin = NO;
    }
    
    for (int i = 0; i < _signalGraphs.count; i++) {
        SignalGraph* graph = [_signalGraphs objectAtIndex:i];
        
        [graph queue:signals[i] time:times[i]];
    }
    
    [self setNeedsDisplay];
}

- (void)queueByName:(NSString*)name value:(float)value time:(int64_t)time {
    if (_virgin) {
        self.firstTime = time;
        _virgin = NO;
    }

    SignalGraph* graph = [self signalGraphWithName:name];
    if (graph != nil) {/////////
        [graph queue:value time:time/*-self.firstTime*/];
        [self setNeedsDisplay];
        
        if (self.xAxis != nil)
            [self.xAxis setNeedsDisplay];
        /*
        if (self.yAxis != nil)
            [self.yAxis setNeedsDisplay];
         */
    }
}

- (SignalGraph*)selectSignalGraphAt:(NSUInteger)index {
    for (SignalGraph* graph in _signalGraphs)
        graph.selected = NO;
    
    SignalGraph* sg = [_signalGraphs objectAtIndex:index];
    sg.selected = YES;
    
    return sg;
}

- (SignalGraph*)selectSignalGraphWithName:(NSString*)name {
    for (SignalGraph* graph in _signalGraphs)
        graph.selected = NO;

    SignalGraph* sg = [_dicGraphs objectForKey:name];
    if (sg != nil)
        sg.selected = YES;
    
    return sg;
}

- (SignalGraph*)signalGraphWithName:(NSString*)name {
    return [_dicGraphs objectForKey:name];
}

- (void)removeAllSignalGraphs {
    [_dicGraphs removeAllObjects];
    [_signalGraphs removeAllObjects];
}

- (void)reset {
    _virgin = YES;
}

- (void)offsetIndex:(int)offset {
    for (SignalGraph* graph in _signalGraphs)
        [graph offsetIndex:offset];
}

- (void)addSkipIndex:(int)offset {
    for (SignalGraph* graph in _signalGraphs) {
        graph.skipIndex += offset;
        
        if (graph.skipIndex < 1)
            graph.skipIndex = 1;
        else if (graph.skipIndex > 100)
            graph.skipIndex = 100;
    }
}

#pragma mark PinchGesture

- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
    if ([recognizer numberOfTouches] > 1) {
        CGFloat x0 = [recognizer locationOfTouch:0 inView:self].x;
        CGFloat x1 = [recognizer locationOfTouch:1 inView:self].x;
        CGFloat y0 = [recognizer locationOfTouch:0 inView:self].y;
        CGFloat y1 = [recognizer locationOfTouch:1 inView:self].y;
        
        if (x0 > x1) {
            CGFloat tmp = x1;
            x1 = x0;
            x0 = tmp;
        }

        if (y0 > y1) {
            CGFloat tmp = y1;
            y1 = y0;
            y0 = tmp;
        }

        CGFloat w = x1 - x0;
        CGFloat h = y1 - y0;
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            oldPinchWidth = w;
            oldPinchHeight = h;
            return;
        }

        //int x0i = (_offsetx + (self.frame.size.width - x0)) / _stepWidth;
        //int y0i = (_offsety + (self.frame.size.height - y0)) / _stepHeight;
        
        CGFloat rw = w / oldPinchWidth;
        CGFloat rh = h / oldPinchHeight;
        
        CGFloat sw = _stepWidth * rw;
        CGFloat sh = _stepHeight * rh;
        
        CGFloat ox = _offsetx * rw + (w - oldPinchWidth);
        CGFloat oy = _offsety * rh + (h - oldPinchHeight);
        
        //CGFloat ox = x0i * sw + x0 - self.frame.size.width;
        //CGFloat oy = y0i * sh + y0 - self.frame.size.height;
        //NSLog(@"pinch w=%f, sw=%f, ox=%f, x0=%f", w, sw, ox, x0);
        //NSLog(@"pinch h=%f, sh=%f, oy=%f, y0=%f, y1=%f, y0i=%d", h, sh, oy, y0, y1, y0i);

        if (w >= h && sw >= _minStepWidth && sw <= _maxStepWidth) {
            if (ox < 0)
                ox = 0;
            
            _stepWidth = sw;
            _offsetx = ox;
            
            oldPinchWidth = w;
        }
        
        if (w < h) {
            if (oy < 0)
                oy = 0;
            
            if (sh < _minStepHeight)
                sh = _minStepHeight;
            
            if (sh > _maxStepHeight)
                sh = _maxStepHeight;
            
            _stepHeight = sh;
            _offsety = oy;
            
            oldPinchHeight = h;
        }
    
        /*
        CGFloat newStepWidth = _stepWidth + width;
        if (newStepWidth < _minStepWidth) {
            _stepWidth = _minStepWidth;
            [self addSkipIndex:1];
        } else if (newStepWidth > _maxStepWidth) {
            _stepWidth = _maxStepWidth;
            [self addSkipIndex:-1];
        } else
            _stepWidth = newStepWidth;
        */
        
        [self setNeedsDisplay];
        [self.xAxis setNeedsDisplay];
        [self.yAxis setNeedsDisplay];
    }
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if ([recognizer numberOfTouches] > 1)
        return;

    CGPoint translatedPoint = [recognizer translationInView:self];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        oldTranslatedPoint = translatedPoint;
        return;
    }

    if (_stepHeight * _denominator > self.frame.size.height) {
        _offsety += (translatedPoint.y - oldTranslatedPoint.y);

        if (_stepHeight * _denominator - _offsety < self.frame.size.height)
            _offsety = _stepHeight * _denominator - self.frame.size.height;
    }
    
    int dataLength = 0;
    for (SignalGraph* graph in _signalGraphs) {
        dataLength = graph.dataLength;
        break;
    }
    
    //if (_stepWidth * dataLength > self.frame.size.width) {
    _offsetx += (translatedPoint.x - oldTranslatedPoint.x);
    
    if (_stepWidth * dataLength - _offsetx < self.frame.size.width)
        _offsetx = _stepWidth * dataLength - self.frame.size.width;
    //}
    
    if (_offsetx < 0)
        _offsetx = 0;
    
    if (_offsety < 0)
        _offsety = 0;
    
    [self setNeedsDisplay];
    [self.xAxis setNeedsDisplay];
    [self.yAxis setNeedsDisplay];

    oldTranslatedPoint = translatedPoint;
}

@end
