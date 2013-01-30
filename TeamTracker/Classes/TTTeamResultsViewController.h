//
//  TTTeamResultsViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 19/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAppDelegate.h"
#import "TTTeam.h"
#import "TTMatchResult.h"
#import "TTMatchResultCell.h"
#import "TTBackgroundLayer.h"
#import "TTMatchDetailViewController.h"
#import "SVPullToRefresh.h"

@interface TTTeamResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    TTAppDelegate *appDelegate;
}

@property (nonatomic, retain) TTTeam *team;
@property (nonatomic, retain) IBOutlet UITableView *resultsTable;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSMutableArray *allLeagueResults;
@property (nonatomic) BOOL showAllLeagueResults;

@end
