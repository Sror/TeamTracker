//
//  TTFixturesViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 31/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAppDelegate.h"
#import "TTFixture.h"
#import "TTFixtureTableCell.h"
#import "TTTeam.h"
#import "TTBackgroundLayer.h"
#import "SVPullToRefresh.h"

@interface TTFixturesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    TTAppDelegate *appDelegate;
}

@property (nonatomic) BOOL showAllFixtures;
@property (nonatomic, retain) TTTeam *team;
@property (nonatomic, retain) IBOutlet UITableView *fixturesTable;
@property (nonatomic) NSMutableArray *dataSource;
@property (nonatomic) NSMutableArray *allLeagueFixtures;

@end
