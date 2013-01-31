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
@synthesize dataSource;
@synthesize allLeagueResults;
@synthesize showAllLeagueResults;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    
    //table dataSource
    self.dataSource = [NSMutableArray array];
    
    //Collate ALL league results if requested...
    if (showAllLeagueResults) {
        //Add a menu button to the navigation bar that will also allow access...
        //Only if we've come here from the menu
        SWRevealViewController *revealController = [self revealViewController];
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
        
        self.allLeagueResults = [NSMutableArray array];
        for (TTTeam *t in appDelegate.teamsParser.teams) {
            [self.allLeagueResults addObjectsFromArray:t.results];
        }
        //Strip out duplicate results
        NSMutableArray *unique = [NSMutableArray array];
        for (id obj in self.allLeagueResults) {
            if (![unique containsObject:obj]) {
                [unique addObject:obj];
            }
        }
        //Copy all unique result objects back to allLeagueResults
        //Do it in a way that removes redundant results from memory
        [self.allLeagueResults removeAllObjects];
        [self.allLeagueResults addObjectsFromArray:unique];
        [unique removeAllObjects];
        
        //Sort by matchDateSortID to put ALL results together grouped by date
        NSSortDescriptor *matchDateSort = [NSSortDescriptor sortDescriptorWithKey:@"matchDateSortID" ascending:YES];
        [self.allLeagueResults sortUsingDescriptors:[NSMutableArray arrayWithObject:matchDateSort]];
        
        //Reverse so most recent result is at index == 0
        self.allLeagueResults = (NSMutableArray*)[[self.allLeagueResults reverseObjectEnumerator] allObjects];
        
        //Set title...
        self.title = NSLocalizedString(@"All League Results", @"All League Results");
        
        //Set up initial amount of results to display
        for (int i = 0; i < 15; i++) {
            //Only add if result exists at index
            if (i < [self.allLeagueResults count]) {
                [self.dataSource addObject:[self.allLeagueResults objectAtIndex:i]];
            } else
                break;
        }
        
        // setup infinite scrolling
        __weak TTTeamResultsViewController *weakSelf = self;
        [self.resultsTable addInfiniteScrollingWithActionHandler:^{
            
            [weakSelf.resultsTable beginUpdates];
            for (int i = 0; i < 15; i++) {
                //Only add if result exists at index
                if ([weakSelf.dataSource count] < [weakSelf.allLeagueResults count]) {
                    [weakSelf.dataSource addObject:[weakSelf.allLeagueResults objectAtIndex:[weakSelf.dataSource count]]];
                    [weakSelf.resultsTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.dataSource count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                } else
                    break;
            }
            [weakSelf.resultsTable endUpdates];
            
            [weakSelf.resultsTable.infiniteScrollingView stopAnimating];
        }];
        
    } else {
        self.title = NSLocalizedString(@"Results", @"Results");
        
        //Set up initial amount of results to display
        for (int i = 0; i < 15; i++) {
            //Only add if result exists at index
            if (i < [self.team.results count]) {
                [self.dataSource addObject:[self.team.results objectAtIndex:i]];
            } else
                break;
        }
        
        // setup infinite scrolling
        __weak TTTeamResultsViewController *weakSelf = self;
        [self.resultsTable addInfiniteScrollingWithActionHandler:^{
            
            [weakSelf.resultsTable beginUpdates];
            for (int i = 0; i < 15; i++) {
                //Only add if result exists at index
                if ([weakSelf.dataSource count] < [weakSelf.team.results count]) {
                    [weakSelf.dataSource addObject:[weakSelf.team.results objectAtIndex:[weakSelf.dataSource count]]];
                    [weakSelf.resultsTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.dataSource count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                } else
                    break;
            }
            [weakSelf.resultsTable endUpdates];
            
            [weakSelf.resultsTable.infiniteScrollingView stopAnimating];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Set up a panGestureRecognizer for the resultsTable so that you can swipe left to access rearView of revealVC
    SWRevealViewController *revealController = [self revealViewController];
    [self.resultsTable addGestureRecognizer:revealController.panGestureRecognizer];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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
    return [self.dataSource count];
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
    UIColor *tableTextHighlightedColor = nil;
    
    //Use temp var to access custom cell properties...
    TTMatchResultCell *customCell = (TTMatchResultCell*)cell;
    
    //Get result object - indexed to place the most recent result first...
    TTMatchResult *mResult = [self.dataSource objectAtIndex:indexPath.row];
    
    //Figure out W, D, L to decide cell background colour (W = green, D = orange, L = red)
    CAGradientLayer *bgLayer = nil;
    if (showAllLeagueResults) {
        //Neutral colour if showing all results...        
        bgLayer = [TTBackgroundLayer lightGreyGradient];
        
        //Dark text colour...
        tableTextColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        tableTextHighlightedColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        tableTextShadowColor = [UIColor whiteColor];
    } else {
        //White text colour...
        tableTextColor = [UIColor whiteColor];
        tableTextHighlightedColor = [UIColor whiteColor];
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
    customCell.homeScore.highlightedTextColor = tableTextHighlightedColor;
    customCell.homeTeam.highlightedTextColor = tableTextHighlightedColor;
    customCell.awayScore.highlightedTextColor = tableTextHighlightedColor;
    customCell.awayTeam.highlightedTextColor = tableTextHighlightedColor;
    customCell.matchDate.highlightedTextColor = tableTextHighlightedColor;
    customCell.dashLabel.highlightedTextColor = tableTextHighlightedColor;
    
    //set the UITableViewCell to the TTMatchResultCell
    cell = customCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"matchResultCellIdentifier";
    TTMatchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        NSArray *customCell = [[NSBundle mainBundle] loadNibNamed:@"TTMatchResultCell" owner:nil options:nil];
        if ([[customCell objectAtIndex:0] isKindOfClass:[TTMatchResultCell class]]) {
            cell = [customCell objectAtIndex:0];
        }
    }
    
    //Get result object - indexed to place the most recent result first...
    TTMatchResult *result = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.homeTeam.text = [NSString stringWithFormat:@"%@", result.homeTeam];
    cell.homeScore.text = [NSString stringWithFormat:@"%d", result.homeScore];
    cell.awayTeam.text = [NSString stringWithFormat:@"%@", result.awayTeam];
    cell.awayScore.text = [NSString stringWithFormat:@"%d", result.awayScore];
    cell.matchDate.text = result.matchDate;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Push a TTTeamResultsViewController with relevant team to the navigationController...
    TTMatchDetailViewController *matchDetailViewController = [[TTMatchDetailViewController alloc] initWithNibName:@"TTMatchDetailViewController" bundle:nil];
    //Get result object - indexed to place the most recent result first...
    TTMatchResult *result = nil;
    if (showAllLeagueResults) {
        result = [allLeagueResults objectAtIndex:indexPath.row];
    } else {
        result = [team.results objectAtIndex:indexPath.row];
    }
    matchDetailViewController.result = result;
    
	[self.navigationController pushViewController:matchDetailViewController animated:YES];
    
    //Deselect the cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
