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

@interface TTTeamResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    TTAppDelegate *appDelegate;
    NSMutableArray *allLeagueResults;
    //NSMutableArray *dateSectionCounts;
}

@property (nonatomic, retain) TTTeam *team;
@property (nonatomic, retain) IBOutlet UITableView *resultsTable;
@property (nonatomic) BOOL showAllLeagueResults;

@end
