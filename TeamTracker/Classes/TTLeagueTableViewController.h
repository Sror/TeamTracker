//
//  TTLeagueTableViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAppDelegate.h"
#import "TTLeagueTableCell.h"
#import "TTPPGTableCell.h"
#import "TTTeam.h"
#import "TTMatchResult.h"
#import "TTBackgroundLayer.h"
#import "TTTeamDetailViewController.h"
#import "MBProgressHUD.h"
#import "TTInfoBox.h"

#define HEADER_TEXT_LEAGUE_PORTRAIT     @"     Team                                Pld  GD  Pts"
#define HEADER_TEXT_PPG_PORTRAIT        @"     Team                                  Pld    PPG"
#define HEADER_TEXT_LEAGUE_LANDSCAPE    @"     Team                                                                  Pld  GD  Pts"
#define HEADER_TEXT_PPG_LANDSCAPE       @"     Team                                                                    Pld    PPG"

@interface TTLeagueTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    TTAppDelegate *appDelegate;
    NSString *tableHeaderText;
    BOOL networkDataConnectionIsPresent;
}

- (void)refreshButtonTapped;
- (void)reloadLeagueTable;
- (void)reachabilityChanged:(NSNotification*)notification;

@property (nonatomic, retain) IBOutlet UITableView *leagueTable;
@property (nonatomic) NSInteger sortMode;

@end
