//
//  TTTeamDetailViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 20/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTTeamDetailViewController.h"

@interface TTTeamDetailViewController ()

@end

@implementation TTTeamDetailViewController
@synthesize hostView;
@synthesize didArriveAsFavouriteTeam;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Team", @"Team");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealController = [self revealViewController];
    
    //Add a menu button to the navigation bar that will also allow access...
    //Only if we've come here from the menu
    if (self.didArriveAsFavouriteTeam) {
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    
    //Set up teamDetailViewController attributes
    self.teamName.text = self.team.name;
    self.points.text = [NSString stringWithFormat:@"%dpts", self.team.points];
    //Decide on position suffix...
    NSString *suffix = [NSString string];
    if (self.team.leaguePosition == 1 || self.team.leaguePosition == 21) {
        suffix = @"st";
    } else if (self.team.leaguePosition == 2 || self.team.leaguePosition == 22) {
        suffix = @"nd";
    } else if (self.team.leaguePosition == 3 || self.team.leaguePosition == 23) {
        suffix = @"rd";
    } else {
        suffix = @"th";
    }
    //Set league position
    self.leaguePosition.text = [NSString stringWithFormat:@"Position: %d%@", self.team.leaguePosition, suffix];
    
    //Gradient buttons from repeated images...
    UIImage *blackButtonImage = [[UIImage imageNamed:@"blackButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blackButtonImageHighlight = [[UIImage imageNamed:@"blackButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blueButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blueButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                          resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    // Set the button background states...
    [self.seeAllResultsButton setBackgroundImage:blackButtonImage forState:UIControlStateNormal];
    [self.seeAllResultsButton setBackgroundImage:blackButtonImageHighlight forState:UIControlStateHighlighted];
    [self.moreStatsButton setBackgroundImage:blackButtonImage forState:UIControlStateNormal];
    [self.moreStatsButton setBackgroundImage:blackButtonImageHighlight forState:UIControlStateHighlighted];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"favouriteTeam"] isEqualToString:self.team.name]) {
        [self.saveAsMyTeamButton setBackgroundImage:blueButtonImage forState:UIControlStateNormal];
        [self.saveAsMyTeamButton setBackgroundImage:blueButtonImageHighlight forState:UIControlStateHighlighted];
    } else {
        [self.saveAsMyTeamButton setBackgroundImage:blackButtonImage forState:UIControlStateNormal];
        [self.saveAsMyTeamButton setBackgroundImage:blackButtonImageHighlight forState:UIControlStateHighlighted];
    }
    
    //Init ppg plot
    [self initPlot];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Set up a panGestureRecognizer for the resultsTable so that you can swipe left to access rearView of revealVC
    SWRevealViewController *revealController = [self revealViewController];
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonTapped:(UIButton *)sender {
    //Save name of favourite team...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"favouriteTeam"] isEqualToString:self.team.name]) {
        UIAlertView *teamAlreadySavedAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ is already your favourite team.", self.team.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [teamAlreadySavedAlert show];
    } else {
        [defaults setObject:self.team.name forKey:@"favouriteTeam"];
        UIAlertView *teamSavedAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ have been saved as your favourite team.", self.team.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [teamSavedAlert show];
        
        //Reset the favourite team button background for user feedback
        UIImage *blueButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        UIImage *blueButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                             resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
        [self.saveAsMyTeamButton setBackgroundImage:blueButtonImage forState:UIControlStateNormal];
        [self.saveAsMyTeamButton setBackgroundImage:blueButtonImageHighlight forState:UIControlStateHighlighted];
    }
}

- (IBAction)seeAllResultsButtonTapped:(UIButton *)sender {
    TTTeamResultsViewController *teamResultsViewController = [[TTTeamResultsViewController alloc] initWithNibName:@"TTTeamResultsViewController" bundle:nil];
    teamResultsViewController.team = self.team;
    teamResultsViewController.showAllLeagueResults = NO;
    
    [self.navigationController pushViewController:teamResultsViewController animated:YES];
}

- (IBAction)moreStatsButtonTapped:(UIButton *)sender {
    
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    //Number of points to display on the graph
    return [self.team.ppgArray count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if(fieldEnum == CPTScatterPlotFieldX)
	{
        return [NSNumber numberWithInteger:(index+1)];
    }
	else
	{
		if(plot.identifier == @"PPG") {
            NSNumber *numToPlot = [self.team.ppgArray objectAtIndex:index];
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
    [self configureLegend];
}

-(void)configureHost {
    // 1 - Set up view frame
    CGRect parentRect = self.ppgGraphView.bounds;
    // 2 - Create host view
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = NO;
    [self.ppgGraphView addSubview:self.hostView];
}

-(void)configureGraph {
    // 1 - Create and initialize graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    graph.paddingLeft = 20.0f;
    graph.paddingTop = 20.0f;
    graph.paddingRight = 20.0f;
    graph.paddingBottom = 20.0f;
    
    //Color to tie in with rest of UI
    CPTColor *uiTextColor = [CPTColor colorWithComponentRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = uiTextColor;
    textStyle.fontName = @"HelveticaNeue-Light";
    textStyle.fontSize = 15.0f;
    // 3 - Configure title
    NSString *title = @"Predicted Points Total";
    graph.title = title;
    graph.titleTextStyle = textStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(NUM_GAMES)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(140.0)];
	
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
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor darkGrayColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineColor = [CPTColor grayColor];
    majorGridLineStyle.lineWidth = 1.0f;
    majorGridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0f], [NSNumber numberWithFloat:2.0f], nil];
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineColor = [CPTColor lightGrayColor];
    minorGridLineStyle.lineWidth = 1.0f;
    minorGridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0f], [NSNumber numberWithFloat:2.0f], nil];
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Match Number";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = -35.0f;
    x.axisLineStyle = axisLineStyle;
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
    x.majorIntervalLength = [[NSNumber numberWithFloat:10.0] decimalValue];
    x.minorTicksPerInterval = 4;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.labelTextStyle = axisTextStyle;
    x.labelOffset = -25.0f;
    x.majorTickLineStyle = tickLineStyle;
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
    y.majorTickLineStyle = tickLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    //Show integer values only for X-axis labels
    NSNumberFormatter *yFormatter = [[NSNumberFormatter alloc] init];
    [yFormatter setGeneratesDecimalNumbers:NO];
    [yFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    y.labelFormatter = xFormatter;
	
	CPTScatterPlot *ppgPlot = [[CPTScatterPlot alloc] initWithFrame:self.hostView.bounds];
	ppgPlot.identifier = @"PPG";
    //ppgPlot.dataLineStyle = lineStyle;
	//xSquaredPlot.dataLineStyle.lineWidth = 1.0f;
	//xSquaredPlot.dataLineStyle.lineColor = [CPColor redColor];
	ppgPlot.dataSource = self;
	[graph addPlot:ppgPlot toPlotSpace:graph.defaultPlotSpace];
	
    // 4 - Set theme
    //[graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
}

-(void)configureChart {
}

-(void)configureLegend {
}
@end
