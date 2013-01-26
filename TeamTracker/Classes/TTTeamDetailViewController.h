//
//  TTTeamDetailViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 20/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TTBackgroundLayer.h"
#import "TTLeagueTableCell.h"
#import "TTTeam.h"
#import "TTMatchResult.h"
#import "TTMatchResultCell.h"
#import "TTTeamResultsViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface TTTeamDetailViewController : UIViewController <CPTPlotDataSource>
@property (nonatomic) TTTeam *team;
@property (nonatomic) IBOutlet UILabel *teamName;
@property (nonatomic) IBOutlet UILabel *points;
@property (nonatomic) IBOutlet UILabel *leaguePosition;
@property (nonatomic) IBOutlet UIView *ppgGraphView;
@property (nonatomic) IBOutlet UIButton *saveAsMyTeamButton;
@property (nonatomic) IBOutlet UIButton *seeAllResultsButton;
@property (nonatomic) IBOutlet UIButton *moreStatsButton;
@property (nonatomic) CPTGraphHostingView *hostView;
@property (nonatomic) BOOL didArriveAsFavouriteTeam;

- (IBAction)saveButtonTapped:(UIButton *)sender;
- (IBAction)seeAllResultsButtonTapped:(UIButton *)sender;
- (IBAction)moreStatsButtonTapped:(UIButton *)sender;
-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;

@end
