//
//  TTTeamResultsViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 19/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTTeamResultsViewController.h"
#import "TTTeamsParser.h"

@interface TTTeamResultsViewController ()

@end

@implementation TTTeamResultsViewController

@synthesize team;
@synthesize resultsTable;
@synthesize showAllLeagueResults;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (showAllLeagueResults) {
            self.title = NSLocalizedString(@"All Results", @"All Results");
        } else {
            self.title = NSLocalizedString(@"Results", @"Results");
        }
        
        //Init app delegate
        appDelegate = (TTAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //set seperator colour for table
    self.resultsTable.separatorColor = [UIColor darkTextColor];
    
    //Collate ALL league results if requested...
    if (showAllLeagueResults) {
        //Add a menu button to the navigation bar that will also allow access...
        //Only if we've come here from the menu
        SWRevealViewController *revealController = [self revealViewController];
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
        
        allLeagueResults = [NSMutableArray array];
        for (TTTeam *t in appDelegate.teamsParser.teams) {
            [allLeagueResults addObjectsFromArray:t.results];
        }
        //Strip out duplicate results
        NSMutableArray *unique = [NSMutableArray array];
        for (id obj in allLeagueResults) {
            if (![unique containsObject:obj]) {
                [unique addObject:obj];
            }
        }
        //Copy all unique result objects back to allLeagueResults
        //Do it in a way that removes redundant results from memory
        [allLeagueResults removeAllObjects];
        [allLeagueResults addObjectsFromArray:unique];
        [unique removeAllObjects];
        
        //Sort by matchDateSortID to put ALL results together grouped by date
        NSSortDescriptor *matchDateSort = [NSSortDescriptor sortDescriptorWithKey:@"matchDateSortID" ascending:YES];
        [allLeagueResults sortUsingDescriptors:[NSMutableArray arrayWithObject:matchDateSort]];
        
        /*//Count number of results on a particular date (for table sectioning)
        TTMatchResult *mResult = [allLeagueResults lastObject];
        const NSInteger numIDs = mResult.matchDateSortID+1;
        NSInteger counts[numIDs];
        dateSectionCounts = [NSMutableArray arrayWithCapacity:numIDs];
        for (int i = 0; i < numIDs; i++) {
            counts[i] = 0;
        }
        //Count number of results for a particular date
        for(TTMatchResult *result in allLeagueResults) {
            counts[result.matchDateSortID]++;
        }
        //Assign to class array
        for (int i = 0; i < numIDs; i++) {
            [dateSectionCounts addObject:[NSNumber numberWithInteger:counts[i]]];
        }*/
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Set up a panGestureRecognizer for the resultsTable so that you can swipe left to access rearView of revealVC
    SWRevealViewController *revealController = [self revealViewController];
    [self.resultsTable addGestureRecognizer:revealController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section...
    if (showAllLeagueResults) {
        return [allLeagueResults count];
    } else {
        return [self.team.results count];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 66.0;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //Force the CAGradientLayers being used in table cells + header views to snap to new bounds
    [self.resultsTable reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UILabel shadowTextColour
    UIColor *tableTextColor = nil;
    UIColor *tableTextShadowColor = nil;
    
    //Use temp var to access custom cell properties...
    TTMatchResultCell *customCell = (TTMatchResultCell*)cell;
    
    //Get result object - indexed to place the most recent result first...
    TTMatchResult *mResult = nil;
    if (showAllLeagueResults) {
        mResult = [allLeagueResults objectAtIndex:([allLeagueResults count] - 1) - indexPath.row];
    } else {
        mResult = [team.results objectAtIndex:([team.results count] - 1) - indexPath.row];
    }
    
    //Figure out W, D, L to decide cell background colour (W = green, D = orange, L = red)
    CAGradientLayer *bgLayer = nil;
    if (showAllLeagueResults) {
        //Neutral colour if showing all results...
        bgLayer = [TTBackgroundLayer greyGradient];
        //Dark text colour...
        tableTextColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        tableTextShadowColor = [UIColor whiteColor];
    } else {
        //White text colour...
        tableTextColor = [UIColor whiteColor];
        tableTextShadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        //Team won...
        if (((mResult.homeScore > mResult.awayScore) && [team.name isEqualToString:mResult.homeTeam]) || ((mResult.awayScore > mResult.homeScore) && [team.name isEqualToString:mResult.awayTeam])) {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer greenGradient];
        }
        //Team lost...
        if (((mResult.homeScore < mResult.awayScore) && [team.name isEqualToString:mResult.homeTeam]) || ((mResult.awayScore < mResult.homeScore) && [team.name isEqualToString:mResult.awayTeam])) {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer redGradient];
        }
        //Teams drew...
        else if (mResult.homeScore == mResult.awayScore) {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer orangeGradient];
        }
    }
    //Set CAGradientLayer to cell background...
    bgLayer.frame = cell.bounds;
    UIView *background = [[UIView alloc] initWithFrame: customCell.bounds];
    [background.layer insertSublayer:bgLayer atIndex:0];
    customCell.backgroundView = background;
    
    //Set other UILabel attributes...
    customCell.homeScore.textColor = tableTextColor;
    customCell.homeTeam.textColor = tableTextColor;
    customCell.awayScore.textColor = tableTextColor;
    customCell.awayTeam.textColor = tableTextColor;
    customCell.matchDate.textColor = tableTextColor;
    customCell.dashLabel.textColor = tableTextColor;
    customCell.homeScore.shadowColor = tableTextShadowColor;
    customCell.homeTeam.shadowColor = tableTextShadowColor;
    customCell.awayScore.shadowColor = tableTextShadowColor;
    customCell.awayTeam.shadowColor = tableTextShadowColor;
    customCell.matchDate.shadowColor = tableTextShadowColor;
    customCell.dashLabel.shadowColor = tableTextShadowColor;
    
    //set the UITableViewCell to the TTMatchResultCell
    cell = customCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TTMatchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        NSArray *customCell = [[NSBundle mainBundle] loadNibNamed:@"TTMatchResultCell" owner:nil options:nil];
        if ([[customCell objectAtIndex:0] isKindOfClass:[TTMatchResultCell class]]) {
            cell = [customCell objectAtIndex:0];
        }
    }
    
    //Get result object - indexed to place the most recent result first...
    TTMatchResult *result = nil;
    if (showAllLeagueResults) {
        result = [allLeagueResults objectAtIndex:([allLeagueResults count] - 1) - indexPath.row];
    } else {
        result = [team.results objectAtIndex:([team.results count] - 1) - indexPath.row];
    }
    
    cell.homeTeam.text = [NSString stringWithFormat:@"%@", result.homeTeam];
    cell.homeScore.text = [NSString stringWithFormat:@"%d", result.homeScore];
    cell.awayTeam.text = [NSString stringWithFormat:@"%@", result.awayTeam];
    cell.awayScore.text = [NSString stringWithFormat:@"%d", result.awayScore];
    cell.matchDate.text = [NSString stringWithFormat:@"%@", result.matchDate];
    
    return cell;
}

@end
