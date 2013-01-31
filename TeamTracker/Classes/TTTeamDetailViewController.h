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
#import "TTFixturesViewController.h"
#import "TTMoreStatsViewController.h"
#import "TTGraphView.h"

@interface TTTeamDetailViewController : UIViewController

@property (nonatomic) TTTeam *team;
@property (nonatomic) IBOutlet UILabel *teamName;
@property (nonatomic) IBOutlet UILabel *points;
@property (nonatomic) IBOutlet UILabel *leaguePosition;
@property (nonatomic) IBOutlet UIView *predTotalGraphView;
@property (nonatomic) IBOutlet UIButton *saveAsMyTeamButton;
@property (nonatomic) IBOutlet UIButton *seeAllResultsButton;
@property (nonatomic) IBOutlet UIButton *upcomingFixturesButton;
@property (nonatomic) IBOutlet UIButton *moreStatsButton;
@property (nonatomic) BOOL didArriveAsFavouriteTeam;

- (IBAction)saveButtonTapped:(UIButton *)sender;
- (IBAction)seeAllResultsButtonTapped:(UIButton *)sender;
- (IBAction)moreStatsButtonTapped:(UIButton *)sender;
- (IBAction)upcomingFixturesButtonTapped:(id)sender;

@end
