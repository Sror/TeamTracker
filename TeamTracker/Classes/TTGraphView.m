//
//  TTGraphView.m
//  TeamTracker
//
//  Created by Daniel Browne on 26/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTGraphView.h"

@implementation TTGraphView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame AndGraphData:(NSArray*)graphData AndTitle:(NSString *)graphTitle {
    self = [super initWithFrame:frame];
    if (self) {
        //Init data array
        data = graphData;
        //Init title
        title = graphTitle;
        //Init graph plot
        [self initPlot];
    }
    return self;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    //Number of points to display on the graph
    return [data count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if(fieldEnum == CPTScatterPlotFieldX)
	{
        return [NSNumber numberWithInteger:(index+1)];
    }
	else
	{
		if(plot.identifier == @"predTotal") {
            NSNumber *numToPlot = [data objectAtIndex:index];
            float predTotal = [numToPlot floatValue];
            predTotal *= 46.0f;
            numToPlot = [NSNumber numberWithFloat:predTotal];
            return numToPlot;
        }
    }
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configureChart];
}

-(void)configureHost {
    // 1 - Set up view frame
    CGRect parentRect = self.bounds;
    // 2 - Create host view
    hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    hostView.allowPinchScaling = NO;
    //View layer stuff
    hostView.layer.shadowOpacity = 1.0;
    hostView.layer.shadowColor = [UIColor blackColor].CGColor;
    hostView.layer.shadowOffset = CGSizeMake(0.0f, 2.5f);
    hostView.layer.shadowRadius = 2.5f;
    [self addSubview:hostView];
}

-(void)configureGraph {
    // 1 - Create and initialize graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    hostView.hostedGraph = graph;
    graph.paddingLeft = 30.0f;
    graph.paddingTop = 20.0f;
    graph.paddingRight = 20.0f;
    graph.paddingBottom = 30.0f;
    
    //Color to tie in with rest of UI
    uiTextColor = [CPTColor whiteColor];
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = uiTextColor;
    textStyle.fontName = @"HelveticaNeue-Light";
    textStyle.fontSize = 15.0f;
    // 3 - Configure title
    graph.title = title;
    graph.titleTextStyle = textStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(NUM_GAMES)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(140.0)];
}

-(void)configureChart {
    CPTGraph *graph = nil;
    graph = hostView.hostedGraph;
    
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = uiTextColor;
    axisTitleStyle.fontName = @"HelveticaNeue-Light";
    axisTitleStyle.fontSize = 11.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor darkGrayColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = uiTextColor;
    axisTextStyle.fontName = @"HelveticaNeue-Light";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *minorTickLineStyle = [CPTMutableLineStyle lineStyle];
    minorTickLineStyle.lineColor = [CPTColor darkGrayColor];
    minorTickLineStyle.lineWidth = 0.5f;
    CPTMutableLineStyle *majorTickLineStyle = [CPTMutableLineStyle lineStyle];
    majorTickLineStyle.lineColor = [CPTColor lightGrayColor];
    majorTickLineStyle.lineWidth = 1.0f;
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineColor = [CPTColor grayColor];
    majorGridLineStyle.lineWidth = 0.5f;
    majorGridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0f], [NSNumber numberWithFloat:2.0f], nil];
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineColor = [CPTColor lightGrayColor];
    minorGridLineStyle.lineWidth = 0.5f;
    minorGridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0f], [NSNumber numberWithFloat:2.0f], nil];
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Match Number";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = -30.0f;
    x.axisLineStyle = axisLineStyle;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
    x.majorIntervalLength = [[NSNumber numberWithFloat:10.0] decimalValue];
    x.minorTicksPerInterval = 4;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.labelTextStyle = axisTextStyle;
    x.labelOffset = -20.0f;
    x.majorTickLineStyle = majorTickLineStyle;
    x.minorTickLineStyle = minorTickLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignPositive;
    
    //Show integer values only for X-axis labels
    NSNumberFormatter *xFormatter = [[NSNumberFormatter alloc] init];
    [xFormatter setGeneratesDecimalNumbers:NO];
    [xFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    x.labelFormatter = xFormatter;
    
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.majorIntervalLength = [[NSNumber numberWithFloat:20.0] decimalValue];
    y.minorTicksPerInterval = 1;
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = -25.0f;
    y.majorTickLineStyle = majorTickLineStyle;
    y.minorTickLineStyle = minorTickLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    //Show integer values only for X-axis labels
    NSNumberFormatter *yFormatter = [[NSNumberFormatter alloc] init];
    [yFormatter setGeneratesDecimalNumbers:NO];
    [yFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    y.labelFormatter = xFormatter;
	
	CPTScatterPlot *predTotalPlot = [[CPTScatterPlot alloc] initWithFrame:hostView.bounds];
	predTotalPlot.identifier = @"predTotal";
    CPTMutableLineStyle *predTotalLineStyle = [CPTMutableLineStyle lineStyle];
    predTotalLineStyle.lineWidth = 1.0f;
    predTotalLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableShadow *lineShadow = [CPTMutableShadow shadow];
    lineShadow.shadowOffset = CGSizeMake(0.0, -2.0f);
    lineShadow.shadowBlurRadius = 2.0f;
    lineShadow.shadowColor = [CPTColor blackColor];
    predTotalPlot.dataLineStyle = predTotalLineStyle;
    predTotalPlot.shadow = lineShadow;
	predTotalPlot.dataSource = self;
	[graph addPlot:predTotalPlot toPlotSpace:graph.defaultPlotSpace];
	
    // 4 - Set theme
    //[graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.15 green:0.15 blue:0.15 alpha:1.0]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
