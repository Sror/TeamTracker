//
//  TTLeagueTableViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTLeagueTableViewController.h"

#import "TTTeamsParser.h"
#import "Reachability.h"

@interface TTLeagueTableViewController ()

@end

@implementation TTLeagueTableViewController

@synthesize leagueTable;
@synthesize sortMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Championship Table", @"Championship Table");
        
        //Init app delegate
        appDelegate = (TTAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealController = [self revealViewController];
    
    //Add a menu button to the navigation bar that will also allow access...
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    //Add a menu button to the navigation bar that will also allow access...
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped)];
    self.navigationItem.rightBarButtonItem = refreshButtonItem;
    
    //set seperator colour for table
    self.leagueTable.separatorColor = [UIColor darkTextColor];
    
    //Setup network Reachability tests/notifiers
    // allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // tell the reachability that we DO want to be reachable on 3G/EDGE/CDMA
    reach.reachableOnWWAN = YES;
    
    // here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [reach startNotifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Set up a panGestureRecognizer for the resultsTable so that you can swipe left to access rearView of revealVC
    SWRevealViewController *revealController = [self revealViewController];
    [self.leagueTable addGestureRecognizer:revealController.panGestureRecognizer];
    
    //Reload table if returning from the navigationViewController stack
    if (appDelegate.parseTeamsListError == nil) {
        [self reloadLeagueTable];
    } else {
        //Display an info box to user...
        TTInfoBox *box = [[TTInfoBox alloc] addToView:self.view withInfoText:@"No Network Connection" WhilstAnimating:YES];
        
    }
}

- (void)reachabilityChanged:(NSNotification*)notification {
    Reachability * reach = [notification object];
    
    //Update reachability flag
    if([reach isReachable])
    {
        networkDataConnectionIsPresent = TRUE;
    }
    else
    {
        networkDataConnectionIsPresent = FALSE;
        //Display an info box to user...
        TTInfoBox *box = [[TTInfoBox alloc] addToView:self.view withInfoText:@"Network Connection Lost" WhilstAnimating:YES];
    }
}
                                                                                                                                                                  
- (void)refreshButtonTapped {
    if (networkDataConnectionIsPresent) {
        //invalidate cache...
        [appDelegate.teamsParser invalidateCacheData];
        //Reload the league table...
        [self reloadLeagueTable];
    } else {
        //Display an info box to user...
        TTInfoBox *box = [[TTInfoBox alloc] addToView:self.view withInfoText:@"No Network Connection" WhilstAnimating:YES];
    }
}

- (void)reloadLeagueTable {
    //Set title...
    if (sortMode == TTLeagueTableSortByPoints) {
        self.title = NSLocalizedString(@"Championship Table", @"Championship Table");
    } else {
        self.title = NSLocalizedString(@"PPG Table", @"PPG Table");
    }
    
    //Decide on header text
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        if (sortMode == TTLeagueTableSortByPoints) {
            tableHeaderText = HEADER_TEXT_LEAGUE_PORTRAIT;
        } else {
            tableHeaderText = HEADER_TEXT_PPG_PORTRAIT;
        }
    } else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        if (sortMode == TTLeagueTableSortByPoints) {
            tableHeaderText = HEADER_TEXT_LEAGUE_LANDSCAPE;
        } else {
            tableHeaderText = HEADER_TEXT_PPG_LANDSCAPE;
        }
    }
    
    //Show the progress HUD and spawn a BG thread for XML parsing...
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //Get a URL to the results file
        //NSURL *resultsURL = [NSURL URLWithString:@"http://dl.dropbox.com/u/5400542/championship_results.xml"];
        //Parse the latest results for league table on background thread...
        //NSError *resultsError = [appDelegate parseResultsXMLAtURL:resultsURL SortingBy:sortMode];
        NSError *resultsError = [appDelegate.teamsParser parseTeamsResultsXMLSortingBy:sortMode];
        
        if (resultsError == nil) {
            //Reload the table, scroll to top + hide the progress HUD back on the main thread...
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.leagueTable reloadData];
                [self.leagueTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        } else {
            //hide the progress HUD + show Info Box back on the main thread...
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.leagueTable reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                //Display an info box to user...
                TTInfoBox *box = [[TTInfoBox alloc] addToView:self.view withInfoText:@"No Network Connection" WhilstAnimating:YES];
            });
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [appDelegate.teamsParser.teams count];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //Decide on header text
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        if (sortMode == TTLeagueTableSortByPoints) {
            tableHeaderText = HEADER_TEXT_LEAGUE_PORTRAIT;
        } else {
            tableHeaderText = HEADER_TEXT_PPG_PORTRAIT;
        }
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        if (sortMode == TTLeagueTableSortByPoints) {
            tableHeaderText = HEADER_TEXT_LEAGUE_LANDSCAPE;
        } else {
            tableHeaderText = HEADER_TEXT_PPG_LANDSCAPE;
        }
    }
    //Force the CAGradientLayers being used in table cells + header views to snap to new bounds
    [self.leagueTable reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 22.0)];
    
    //Create a CAGradientLayer as the background to the tableHeaderView
    CAGradientLayer *bgLayer = [TTBackgroundLayer darkGreyGradient];
    bgLayer.frame = customView.bounds;
    bgLayer.shadowOpacity = 1.0;
    bgLayer.shadowColor = [UIColor blackColor].CGColor;
    bgLayer.shadowOffset = CGSizeMake(0.0f, 2.5f);
    bgLayer.shadowRadius = 2.5f;
    [customView.layer insertSublayer:bgLayer atIndex:0];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0];
	headerLabel.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 22.0);
    headerLabel.text = tableHeaderText;
    
	[customView addSubview:headerLabel];
    
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 22.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UILabel textColours
    //Default positions
    UIColor *tableTextColor = nil;
    UIColor *tableTextShadowColor = nil;
    UIColor *tableTextHighlightedColor = nil;
    if (indexPath.row >= 6 && indexPath.row < 21) {
        tableTextColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        tableTextShadowColor = [UIColor whiteColor];
        tableTextHighlightedColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    //Promotion, Playoffs & Relegation
    else {
        tableTextColor = [UIColor whiteColor];
        tableTextShadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        tableTextHighlightedColor = [UIColor whiteColor];
    }
    
    //Use temp var to access custom cell properties...
    if (sortMode == TTLeagueTableSortByPoints) {
        TTLeagueTableCell *customCell = (TTLeagueTableCell*)cell;
        
        //Set background colour of cells depending on league position
        CAGradientLayer *bgLayer = nil;
        //Automatic promotion places
        if (indexPath.row < 2) {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer greenGradient];
        }
        //Playoffs
        else if (indexPath.row >=2 && indexPath.row < 6) {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer orangeGradient];
        }
        //Relegation
        else if (indexPath.row >= 21 && indexPath.row < 24)
        {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer redGradient];
        }
        //default
        else {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer greyGradient];
        }
        //Set CAGradientLayer to cell background...
        bgLayer.frame = cell.bounds;
        UIView *background = [[UIView alloc] initWithFrame: customCell.bounds];
        [background.layer insertSublayer:bgLayer atIndex:0];
        customCell.backgroundView = background;
        
        //Set other UILabel attributes...
        customCell.leaguePosition.textColor = tableTextColor;
        customCell.leaguePosition.highlightedTextColor = tableTextHighlightedColor;
        customCell.teamName.textColor = tableTextColor;
        customCell.teamName.highlightedTextColor = tableTextHighlightedColor;
        customCell.gamesPlayed.textColor = tableTextColor;
        customCell.gamesPlayed.highlightedTextColor = tableTextHighlightedColor;
        customCell.totalGoalDifference.textColor = tableTextColor;
        customCell.totalGoalDifference.highlightedTextColor = tableTextHighlightedColor;
        customCell.points.textColor = tableTextColor;
        customCell.points.highlightedTextColor = tableTextHighlightedColor;
        customCell.leaguePosition.shadowColor = tableTextShadowColor;
        customCell.teamName.shadowColor = tableTextShadowColor;
        customCell.gamesPlayed.shadowColor = tableTextShadowColor;
        customCell.totalGoalDifference.shadowColor = tableTextShadowColor;
        customCell.points.shadowColor = tableTextShadowColor;
        
        //set the UITableViewCell to the TTLeagueTableCell
        cell = customCell;
        
    } else {
        TTPPGTableCell *customCell = (TTPPGTableCell*)cell;
        
        //Set background colour of cells depending on league position
        CAGradientLayer *bgLayer = nil;
        //Automatic promotion places
        if (indexPath.row < 2) {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer greenGradient];
        }
        //Playoffs
        else if (indexPath.row >=2 && indexPath.row < 6) {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer orangeGradient];
        }
        //Relegation
        else if (indexPath.row >= 21 && indexPath.row < 24)
        {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer redGradient];
        }
        //default
        else {
            //Create a CAGradientLayer as the background to the tableHeaderView
            bgLayer = [TTBackgroundLayer greyGradient];
        }
        //Set CAGradientLayer to cell background...
        bgLayer.frame = cell.bounds;
        UIView *background = [[UIView alloc] initWithFrame: customCell.bounds];
        [background.layer insertSublayer:bgLayer atIndex:0];
        customCell.backgroundView = background;
        
        //Set other UILabel attributes...
        customCell.leaguePosition.textColor = tableTextColor;
        customCell.leaguePosition.highlightedTextColor = tableTextHighlightedColor;
        customCell.teamName.textColor = tableTextColor;
        customCell.teamName.highlightedTextColor = tableTextHighlightedColor;
        customCell.gamesPlayed.textColor = tableTextColor;
        customCell.gamesPlayed.highlightedTextColor = tableTextHighlightedColor;
        customCell.pointsPerGame.textColor = tableTextColor;
        customCell.pointsPerGame.highlightedTextColor = tableTextHighlightedColor;
        customCell.leaguePosition.shadowColor = tableTextShadowColor;
        customCell.teamName.shadowColor = tableTextShadowColor;
        customCell.gamesPlayed.shadowColor = tableTextShadowColor;
        customCell.pointsPerGame.shadowColor = tableTextShadowColor;
        
        //set the UITableViewCell to the TTLeagueTableCell
        cell = customCell;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //Set up cell depending on sortMode...
    if (sortMode == TTLeagueTableSortByPoints) {
        TTLeagueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            NSArray *customCell = [[NSBundle mainBundle] loadNibNamed:@"TTLeagueTableCell" owner:nil options:nil];
            if ([[customCell objectAtIndex:0] isKindOfClass:[TTLeagueTableCell class]]) {
                cell = [customCell objectAtIndex:0];
            }
        }
        TTTeam *team = [appDelegate.teamsParser.teams objectAtIndex:indexPath.row];
        
        cell.leaguePosition.text = [NSString stringWithFormat:@"%d", team.leaguePosition];
        cell.teamName.text = [NSString stringWithFormat:@"%@", team.name];
        cell.gamesPlayed.text = [NSString stringWithFormat:@"%d", team.gamesPlayed];
        if (team.totalGoalDifference >= 0) {
            cell.totalGoalDifference.text = [NSString stringWithFormat:@"+%d", team.totalGoalDifference];
        } else {
            cell.totalGoalDifference.text = [NSString stringWithFormat:@"%d", team.totalGoalDifference];
        }
        cell.points.text = [NSString stringWithFormat:@"%d", team.points];
        
        return cell;
    } else {
        TTPPGTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (cell == nil) {
            NSArray *customCell = [[NSBundle mainBundle] loadNibNamed:@"TTPPGTableCell" owner:nil options:nil];
            if ([[customCell objectAtIndex:0] isKindOfClass:[TTPPGTableCell class]]) {
                cell = [customCell objectAtIndex:0];
            }
        }
        TTTeam *team = [appDelegate.teamsParser.teams objectAtIndex:indexPath.row];
        
        cell.leaguePosition.text = [NSString stringWithFormat:@"%d", team.leaguePosition];
        cell.teamName.text = [NSString stringWithFormat:@"%@", team.name];
        cell.gamesPlayed.text = [NSString stringWithFormat:@"%d", team.gamesPlayed];
        cell.pointsPerGame.text = [NSString stringWithFormat:@"%.2f", [[team.ppgArray lastObject] floatValue]];
        
        return cell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Push a TTTeamResultsViewController with relevant team to the navigationController...
    TTTeamDetailViewController *teamDetailViewController = [[TTTeamDetailViewController alloc] initWithNibName:@"TTTeamDetailViewController" bundle:nil];
    teamDetailViewController.team = [appDelegate.teamsParser.teams objectAtIndex:indexPath.row];
    teamDetailViewController.didArriveAsFavouriteTeam = NO;
    
	[self.navigationController pushViewController:teamDetailViewController animated:YES];
    
    //Deselect the cell
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
