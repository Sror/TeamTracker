//
//  TTSecondViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAppDelegate.h"
#import "TTTeam.h"
#import "TTMatchResult.h"
#import "TTBackgroundLayer.h"
#import "TTLeagueTableViewController.h"
#import "TTTeamDetailViewController.h"
#import "TTTeamResultsViewController.h"

@interface TTMenuViewController : UIViewController {
    TTAppDelegate *appDelegate;
    NSArray *menuOptions;
}

@property (nonatomic, retain) IBOutlet UITableView *menuTable;

@end
