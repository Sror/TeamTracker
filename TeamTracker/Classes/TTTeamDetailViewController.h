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

@interface TTTeamDetailViewController : UIViewController
@property (nonatomic) TTTeam *team;
@property (nonatomic) IBOutlet UILabel *teamName;
@property (nonatomic) IBOutlet UILabel *points;
@property (nonatomic) IBOutlet UILabel *leaguePosition;
@property (nonatomic) IBOutlet UIView *ppgGraphView;
@property (nonatomic) IBOutlet UIButton *saveAsMyTeamButton;
@property (weak, nonatomic) IBOutlet UIButton *seeAllResultsButton;
@property (nonatomic) BOOL didArriveAsFavouriteTeam;

- (IBAction)saveButtonTapped:(UIButton *)sender;
- (IBAction)seeAllResultsButtonTapped:(UIButton *)sender;

@end
