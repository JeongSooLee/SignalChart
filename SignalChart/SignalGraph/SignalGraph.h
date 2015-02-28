//
//  SignalGraph.h
//  SignalChart
//
//  Created by 이정수 on 2012. 11. 4..
//  Copyright (c) 2014. JeongSoo, Lee.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreSignalGraphView.h"

@interface SignalGraph : NSObject {
@private CGRect _frame;
@private int64_t _lastTime;
    //@private BOOL hasInput;
}

@property (nonatomic, strong) CoreSignalGraphView* parent;
@property (nonatomic, strong) UIColor* gridColor;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) NSString* unit;
@property BOOL selected;

@property float minValue;
@property float maxValue;

@property int quota;

// 데이터가 추가될 때마다 1씩 증가한다. quota는 초과될 수 없다.
@property int dataLength;

// 오른쪽에서 시작하여 최신 데이터부터 그려진다.
// 여기부터 그려진다(원점). 현재 사용되지 않는다.
@property int offsetIndex;

// 최근 데이터가 들어갈 인덱스
@property int tailIndex;

@property int skipIndex;

@property float* values;
@property int64_t* times;

- (id)initWithFrame:(CGRect)frame min:(float)min max:(float)max unit:(NSString*)unit quota:(int)quota;
- (void)drawWithContext:(CGContextRef)context;
- (void)queue:(float)value time:(int64_t)time;
- (CGFloat)getPixelY:(float)value;

- (void)scroll:(CGSize)offset;

- (void)offsetIndex:(int)offset; // (-) scroll to left, (+) scroll to right

@end
