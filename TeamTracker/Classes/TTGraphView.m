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

- (id)initWithFrame:(CGRect)frame AndGraphData:(NSArray*)graphData AndGraphType:(NSInteger)type {
    self = [super initWithFrame:frame];
    if (self) {
        //Init data array
        data = graphData;
        //Init title
        switch (type) {
            case TTGraphViewTypePredictedTotal:
                title = @"Predicted Total";
                break;
            case TTGraphViewTypeLeaguePosition:
                title = @"League Position";
                break;
            case TTGraphViewTypePPGAutos:
                title = @"Points Remaining for Autos";
                break;
            case TTGraphViewTypePPGPlayoffs:
                title = @"Points Remaining for Playoffs";
                break;
            case TTGraphViewTypePPGSafety:
                title = @"Points Remaining for Safety";
                break;
            case TTGraphViewTypePointsAccrued:
                title = @"Points Gained vs Max Points";
                break;
            default:
                break;
        }
        
        graphType = type;
        
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
	if(fieldEnum == CPTScatterPlotFieldX || fieldEnum == CPTBarPlotFieldBarLocation)
	{
        return [NSNumber numberWithInteger:(index+1)];
    }
	else
	{
        NSNumber *numToPlot = [data objectAtIndex:index];
        NSInteger numToPlotInt = [numToPlot integerValue];
        
		if([(NSString*)plot.identifier isEqualToString:@"plot"]) {
            if (graphType == TTGraphViewTypePredictedTotal) {
                float predTotal = [numToPlot floatValue];
                predTotal *= 46.0f;
                numToPlot = [NSNumber numberWithFloat:predTotal];
            }
        } else if([(NSString*)plot.identifier isEqualToString:@"bestCase"]) {
            if (graphType == TTGraphViewTypePPGAutos) {
                numToPlotInt = AUTOS_BESTCASE - numToPlotInt;
            } else if (graphType == TTGraphViewTypePPGPlayoffs) {
                numToPlotInt= PLAYOFFS_BESTCASE - numToPlotInt;
            } else if (graphType == TTGraphViewTypePPGSafety) {
                numToPlotInt = CHMP_SAFETY_BESTCASE - numToPlotInt;
            }
            numToPlot = [NSNumber numberWithInteger:numToPlotInt];
        } else if([(NSString*)plot.identifier isEqualToString:@"average"]) {
            if (graphType == TTGraphViewTypePPGAutos) {
                numToPlotInt = AUTOS_AVERAGE - numToPlotInt;
            } else if (graphType == TTGraphViewTypePPGPlayoffs) {
                numToPlotInt = PLAYOFFS_AVERAGE - numToPlotInt;
            } else if (graphType == TTGraphViewTypePPGSafety) {
                numToPlotInt = CHMP_SAFETY_AVERAGE - numToPlotInt;
            }
            numToPlot = [NSNumber numberWithInteger:numToPlotInt];
        } else if([(NSString*)plot.identifier isEqualToString:@"worstCase"]) {
            if (graphType == TTGraphViewTypePPGAutos) {
                numToPlotInt = AUTOS_WORSTCASE - numToPlotInt;
            } else if (graphType == TTGraphViewTypePPGPlayoffs) {
                numToPlotInt = PLAYOFFS_WORSTCASE - numToPlotInt;
            } else if (graphType == TTGraphViewTypePPGSafety) {
                numToPlotInt = CHMP_SAFETY_WORSTCASE - numToPlotInt;
            }
            numToPlot = [NSNumber numberWithInteger:numToPlotInt];
        } else if([(NSString*)plot.identifier isEqualToString:@"maxPoints"]) {
            numToPlotInt = (index+1)*3;
            numToPlot = [NSNumber numberWithInteger:numToPlotInt];
        } else if([(NSString*)plot.identifier isEqualToString:@"pointsAccrued"]) {
            numToPlot = [NSNumber numberWithInteger:numToPlotInt];
        }
        return numToPlot;
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
    switch (graphType) {
        case TTGraphViewTypePredictedTotal:
            graph.paddingBottom = 30.0f;
            break;
        case TTGraphViewTypeLeaguePosition:
            graph.paddingBottom = 20.0f;
            break;
        case TTGraphViewTypePPGAutos:
            graph.paddingBottom = 30.0f;
            break;
        case TTGraphViewTypePPGPlayoffs:
            graph.paddingBottom = 30.0f;
            break;
        case TTGraphViewTypePPGSafety:
            graph.paddingBottom = 30.0f;
            break;
        case TTGraphViewTypePointsAccrued:
            graph.paddingBottom = 30.0f;
            break;
        default:
            break;
    }
    
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
    switch (graphType) {
        case TTGraphViewTypePredictedTotal:
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(MAX_PTS_YAXIS)];
            break;
        case TTGraphViewTypeLeaguePosition:
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat((float)NUM_TEAMS) length:CPTDecimalFromFloat(-(float)(NUM_TEAMS)+0.5f)];
            break;
        case TTGraphViewTypePPGAutos:
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
            break;
        case TTGraphViewTypePPGPlayoffs:
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
            break;
        case TTGraphViewTypePPGSafety:
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(60.0f)];
            break;
        case TTGraphViewTypePointsAccrued:
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(MAX_PTS_YAXIS)];
            break;
        default:
            break;
    }
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
    x.axisLineStyle = axisLineStyle;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
    x.majorIntervalLength = [[NSNumber numberWithFloat:10.0f] decimalValue];
    x.minorTicksPerInterval = 4;
    x.labelTextStyle = axisTextStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    switch (graphType) {
        case TTGraphViewTypePredictedTotal:
            x.titleOffset = -30.0f;
            x.labelOffset = -20.0f;
            break;
        case TTGraphViewTypeLeaguePosition:
            x.titleOffset = 300.0f;
            x.labelOffset = 300.0f;
            break;
        case TTGraphViewTypePPGAutos:
            x.titleOffset = -30.0f;
            x.labelOffset = -20.0f;
            break;
        case TTGraphViewTypePPGPlayoffs:
            x.titleOffset = -30.0f;
            x.labelOffset = -20.0f;
            break;
        case TTGraphViewTypePPGSafety:
            x.titleOffset = -30.0f;
            x.labelOffset = -20.0f;
            break;
        case TTGraphViewTypePointsAccrued:
            x.titleOffset = -30.0f;
            x.labelOffset = -20.0f;
            break;
        default:
            break;
    }
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
    float yMajorInterval = 0.0f;
    switch (graphType) {
        case TTGraphViewTypePredictedTotal:
            yMajorInterval = 20.0f;
            break;
        case TTGraphViewTypeLeaguePosition:
            yMajorInterval = 2.0f;
            break;
        case TTGraphViewTypePPGAutos:
            yMajorInterval = 20.0f;
            break;
        case TTGraphViewTypePPGPlayoffs:
            yMajorInterval = 20.0f;
            break;
        case TTGraphViewTypePPGSafety:
            yMajorInterval = 10.0f;
            break;
        case TTGraphViewTypePointsAccrued:
            yMajorInterval = 20.0f;
            break;
        default:
            break;
    }
    
    CPTAxis *y = axisSet.yAxis;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.majorIntervalLength = [[NSNumber numberWithFloat:yMajorInterval] decimalValue];
    y.minorTicksPerInterval = 1;
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = -25.0f;
    y.majorTickLineStyle = majorTickLineStyle;
    y.minorTickLineStyle = minorTickLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    //Show integer values only for Y-axis labels
    NSNumberFormatter *yFormatter = [[NSNumberFormatter alloc] init];
    [yFormatter setGeneratesDecimalNumbers:NO];
    [yFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    y.labelFormatter = yFormatter;
    
    //Line plot shadow
    CPTMutableShadow *lineShadow = [CPTMutableShadow shadow];
    lineShadow.shadowOffset = CGSizeMake(0.0, -2.0f);
    lineShadow.shadowBlurRadius = 2.0f;
    lineShadow.shadowColor = [CPTColor blackColor];
    
    //Graph line styles
    if (graphType == TTGraphViewTypePredictedTotal || graphType == TTGraphViewTypeLeaguePosition) {
        
        CPTScatterPlot *predTotalPlot = [[CPTScatterPlot alloc] initWithFrame:hostView.bounds];
        predTotalPlot.identifier = @"plot";
        CPTMutableLineStyle *predTotalLineStyle = [CPTMutableLineStyle lineStyle];
        predTotalLineStyle.lineWidth = 1.0f;
        predTotalLineStyle.lineColor = [CPTColor whiteColor];
        predTotalPlot.dataLineStyle = predTotalLineStyle;
        predTotalPlot.shadow = lineShadow;
        predTotalPlot.dataSource = self;
        [graph addPlot:predTotalPlot toPlotSpace:graph.defaultPlotSpace];
        
    } else if (graphType == TTGraphViewTypePPGAutos || graphType == TTGraphViewTypePPGPlayoffs || graphType == TTGraphViewTypePPGSafety) {
        
        CPTScatterPlot *leaguePositionPlotBC = [[CPTScatterPlot alloc] initWithFrame:hostView.bounds];
        leaguePositionPlotBC.identifier = @"bestCase";
        CPTMutableLineStyle *leaguePositionLineStyleBC = [CPTMutableLineStyle lineStyle];
        leaguePositionLineStyleBC.lineWidth = 1.0f;
        leaguePositionLineStyleBC.lineColor = [CPTColor greenColor];
        leaguePositionPlotBC.dataLineStyle = leaguePositionLineStyleBC;
        leaguePositionPlotBC.shadow = lineShadow;
        leaguePositionPlotBC.dataSource = self;
        [graph addPlot:leaguePositionPlotBC toPlotSpace:graph.defaultPlotSpace];
        
        CPTScatterPlot *leaguePositionPlotAV = [[CPTScatterPlot alloc] initWithFrame:hostView.bounds];
        leaguePositionPlotAV.identifier = @"average";
        CPTMutableLineStyle *leaguePositionLineStyleAV = [CPTMutableLineStyle lineStyle];
        leaguePositionLineStyleAV.lineWidth = 1.0f;
        leaguePositionLineStyleAV.lineColor = [CPTColor whiteColor];
        leaguePositionPlotAV.dataLineStyle = leaguePositionLineStyleAV;
        leaguePositionPlotAV.shadow = lineShadow;
        leaguePositionPlotAV.dataSource = self;
        [graph addPlot:leaguePositionPlotAV toPlotSpace:graph.defaultPlotSpace];
        
        CPTScatterPlot *leaguePositionPlotWC = [[CPTScatterPlot alloc] initWithFrame:hostView.bounds];
        leaguePositionPlotWC.identifier = @"worstCase";
        CPTMutableLineStyle *leaguePositionLineStyleWC = [CPTMutableLineStyle lineStyle];
        leaguePositionLineStyleWC.lineWidth = 1.0f;
        leaguePositionLineStyleWC.lineColor = [CPTColor redColor];
        leaguePositionPlotWC.dataLineStyle = leaguePositionLineStyleWC;
        leaguePositionPlotWC.shadow = lineShadow;
        leaguePositionPlotWC.dataSource = self;
        [graph addPlot:leaguePositionPlotWC toPlotSpace:graph.defaultPlotSpace];
        
    } else if (graphType == TTGraphViewTypePointsAccrued) {
        
        CPTBarPlot *maxPointsPlot = [[CPTBarPlot alloc] initWithFrame:hostView.bounds];
        maxPointsPlot.identifier = @"maxPoints";
        //pointsAccruedPlot.barWidth = [[NSDecimalNumber decimalNumberWithString:@"5.0"] decimalValue];
        //pointsAccruedPlot.barOffset = [[NSDecimalNumber decimalNumberWithString:@"10.0"] decimalValue];
        //pointsAccruedPlot.barCornerRadius = 5.0;
        // Remove bar outlines
        CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
        borderLineStyle.lineColor = [CPTColor clearColor];
        maxPointsPlot.lineStyle = borderLineStyle;
        maxPointsPlot.shadow = lineShadow;
        maxPointsPlot.dataSource = self;
        [graph addPlot:maxPointsPlot toPlotSpace:graph.defaultPlotSpace];
        
        CPTBarPlot *pointsAccruedPlot = [[CPTBarPlot alloc] initWithFrame:hostView.bounds];
        pointsAccruedPlot.identifier = @"pointsAccrued";
        //pointsAccruedPlot.barWidth = [[NSDecimalNumber decimalNumberWithString:@"5.0"] decimalValue];
        //pointsAccruedPlot.barOffset = [[NSDecimalNumber decimalNumberWithString:@"10.0"] decimalValue];
        //pointsAccruedPlot.barCornerRadius = 5.0;
        // Remove bar outlines
        pointsAccruedPlot.lineStyle = borderLineStyle;
        pointsAccruedPlot.shadow = lineShadow;
        pointsAccruedPlot.dataSource = self;
        [graph addPlot:pointsAccruedPlot toPlotSpace:graph.defaultPlotSpace];
        
    }
    
    // 4 - Set theme
    //[graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.15 green:0.15 blue:0.15 alpha:1.0]];
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot
                  recordIndex:(NSUInteger)index
{
    CPTFill *fill = nil;
    if ( [barPlot.identifier isEqual:@"pointsAccrued"] )
    {
        fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
        
    } else {
        fill = [CPTFill fillWithColor:[CPTColor grayColor]];
    }
    return fill;
}

@end
