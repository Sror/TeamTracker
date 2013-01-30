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
@synthesize networkDataConnectionIsPresent;

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
    //Start reachability notifications
    [reach startNotifier];
    
    // setup pull-to-refresh
    __weak TTLeagueTableViewController *weakSelf = self;
    [self.leagueTable addPullToRefreshWithActionHandler:^{
        if (weakSelf.networkDataConnectionIsPresent) {
            //invalidate cache...
            [appDelegate.teamsParser invalidateCacheData];
            //Reload the league table...
            [weakSelf reloadLeagueTable];
        } else {
            //Display an info box to user...
            TTInfoBox *box = [[TTInfoBox alloc] addToView:weakSelf.view withInfoText:@"No Network Connection" WhilstAnimating:YES];
        }
        //Stop & hide the pull-to-refresh view...
        [weakSelf.leagueTable.pullToRefreshView stopAnimating];
    }];
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
        self.networkDataConnectionIsPresent = TRUE;
    }
    else
    {
        self.networkDataConnectionIsPresent = FALSE;
        //Display an info box to user...
        TTInfoBox *box = [[TTInfoBox alloc] addToView:self.view withInfoText:@"Network Connection Lost" WhilstAnimating:YES];
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
        //Parse the latest results for league table on background thread...
        NSError *resultsError = [appDelegate.teamsParser parseTeamsResultsXMLSortingBy:sortMode];
        
        if (resultsError == nil) {
            //Reload the table + hide the progress HUD back on the main thread...
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.leagueTable reloadData];
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
    //Also helps if as we are showing/hiding labels showing WDL stats
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
        customCell.leaguePosition.shadowColor = tableTextShadowColor;
        customCell.teamName.textColor = tableTextColor;
        customCell.teamName.highlightedTextColor = tableTextHighlightedColor;
        customCell.teamName.shadowColor = tableTextShadowColor;
        customCell.gamesPlayed.textColor = tableTextColor;
        customCell.gamesPlayed.highlightedTextColor = tableTextHighlightedColor;
        customCell.gamesPlayed.shadowColor = tableTextShadowColor;
        customCell.totalGoalDifference.textColor = tableTextColor;
        customCell.totalGoalDifference.highlightedTextColor = tableTextHighlightedColor;
        customCell.totalGoalDifference.shadowColor = tableTextShadowColor;
        customCell.points.textColor = tableTextColor;
        customCell.points.highlightedTextColor = tableTextHighlightedColor;
        customCell.points.shadowColor = tableTextShadowColor;
        
        //If we are in landscape, setup the WDL labels and show them, else hide them
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            customCell.homeWins.hidden = NO;
            customCell.homeWins.textColor = tableTextColor;
            customCell.homeWins.highlightedTextColor = tableTextHighlightedColor;
            customCell.homeWins.shadowColor = tableTextShadowColor;
            customCell.homeDraws.hidden = NO;
            customCell.homeDraws.textColor = tableTextColor;
            customCell.homeDraws.highlightedTextColor = tableTextHighlightedColor;
            customCell.homeDraws.shadowColor = tableTextShadowColor;
            customCell.homeLosses.hidden = NO;
            customCell.homeLosses.textColor = tableTextColor;
            customCell.homeLosses.highlightedTextColor = tableTextHighlightedColor;
            customCell.homeLosses.shadowColor = tableTextShadowColor;
            customCell.awayWins.hidden = NO;
            customCell.awayWins.textColor = tableTextColor;
            customCell.awayWins.highlightedTextColor = tableTextHighlightedColor;
            customCell.awayWins.shadowColor = tableTextShadowColor;
            customCell.awayDraws.hidden = NO;
            customCell.awayDraws.textColor = tableTextColor;
            customCell.awayDraws.highlightedTextColor = tableTextHighlightedColor;
            customCell.awayDraws.shadowColor = tableTextShadowColor;
            customCell.awayLosses.hidden = NO;
            customCell.awayLosses.textColor = tableTextColor;
            customCell.awayLosses.highlightedTextColor = tableTextHighlightedColor;
            customCell.awayLosses.shadowColor = tableTextShadowColor;
        } else {
            customCell.homeWins.hidden = YES;
            customCell.homeDraws.hidden = YES;
            customCell.homeLosses.hidden = YES;
            customCell.awayWins.hidden = YES;
            customCell.awayDraws.hidden = YES;
            customCell.awayLosses.hidden = YES;
        }
        
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
    static NSString *leagueCellIdentifier = @"leagueCellIdentifier";
    static NSString *ppgCellIdentifier = @"ppgCellIdentifier";
    //Set up cell depending on sortMode...
    if (sortMode == TTLeagueTableSortByPoints) {
        TTLeagueTableCell *cell = [tableView dequeueReusableCellWithIdentifier:leagueCellIdentifier];
        
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
        cell.homeWins.text = [NSString stringWithFormat:@"%d", team.homeWins];
        cell.homeDraws.text = [NSString stringWithFormat:@"%d", team.homeDraws];
        cell.homeLosses.text = [NSString stringWithFormat:@"%d", team.homeLosses];
        cell.awayWins.text = [NSString stringWithFormat:@"%d", team.awayWins];
        cell.awayDraws.text = [NSString stringWithFormat:@"%d", team.awayDraws];
        cell.awayLosses.text = [NSString stringWithFormat:@"%d", team.awayLosses];
        
        return cell;
    } else {
        TTPPGTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ppgCellIdentifier];
        
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
