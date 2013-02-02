//
//  TTGraphView.h
//  TeamTracker
//
//  Created by Daniel Browne on 26/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "TTAppDelegate.h"

typedef enum {
    TTGraphViewTypePredictedTotal,
    TTGraphViewTypeLeaguePosition
} TTGraphViewType;

@interface TTGraphView : UIView <CPTPlotDataSource> {
    CPTGraphHostingView *hostView;
    NSArray *data;
    NSString *title;
    CPTColor *uiTextColor;
    NSInteger graphType;
}

- (id)initWithFrame:(CGRect)frame AndGraphData:(NSArray*)graphData AndGraphType:(NSInteger)type;
- (void)initPlot;
- (void)configureHost;
- (void)configureGraph;
- (void)configureChart;

@end
