//
//  TTSecondViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTMenuViewController.h"
#import "TTTeamsParser.h"

@interface TTMenuViewController ()

@end

@implementation TTMenuViewController

@synthesize menuTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Menu", @"Menu");
        
        //Init app delegate
        appDelegate = (TTAppDelegate*)[UIApplication sharedApplication].delegate;
        
        //Init menu options
        menuOptions = [NSArray arrayWithObjects:@"Championship Table", @"Points per Game Table", @"All Previous Results", @"All Upcoming Fixtures", @"Favourite Team", @"Settings", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//set table seperator colour
    self.menuTable.separatorColor = [UIColor darkTextColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Reload table incase we've changed our favourite team
    [self.menuTable reloadData];
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
    return [menuOptions count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    
    //Create a CAGradientLayer as the background to the tableHeaderView
    CAGradientLayer *bgLayer = [TTBackgroundLayer blueGradient];
    bgLayer.frame = customView.bounds;
    bgLayer.shadowOpacity = 1.0;
    bgLayer.shadowColor = [UIColor blackColor].CGColor;
    bgLayer.shadowOffset = CGSizeMake(0.0f, 2.5f);
    bgLayer.shadowRadius = 2.5f;
    [customView.layer insertSublayer:bgLayer atIndex:0];
	
	// create the header label object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.opaque = NO;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
	headerLabel.textColor = [UIColor whiteColor];
	//headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
	headerLabel.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
    
	//Center the UILabel + set text
	headerLabel.frame = CGRectMake(100.0, 0.0, 320.0, 44.0);
	headerLabel.text = @"Menu";
    
	[customView addSubview:headerLabel];
    
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //Hides empty cells (i.e. removes the seperators between unused cells)
    //Does this by setting an empty footer
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return [UIView new];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Set darkGreyGradient cell background colour
    //Create a CAGradientLayer as the background to the tableHeaderView
    cell.textLabel.backgroundColor = [UIColor clearColor];
    CAGradientLayer *bgLayer = [TTBackgroundLayer darkGreyGradient];
    bgLayer.frame = cell.bounds;
    UIView *background = [[UIView alloc] initWithFrame: cell.bounds];
    [background.layer insertSublayer:bgLayer atIndex:0];
    cell.backgroundView = background;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    //Configure cell attributes
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    //Set textLabel texts...
    if (indexPath.row == 4) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"favouriteTeam"] == nil) {
            cell.textLabel.text = @"Favourite team will appear here...";
        } else {
            cell.textLabel.text = [defaults objectForKey:@"favouriteTeam"];
            cell.detailTextLabel.text = [menuOptions objectAtIndex:indexPath.row];
        }
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    } else {
        cell.textLabel.text = [menuOptions objectAtIndex:indexPath.row];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SWRevealViewController *revealController = self.revealViewController;
    
    // We know the frontViewController is a NavigationController...
    UINavigationController *frontNavigationController = (id)revealController.frontViewController;
    
	//Decide which ViewController to show
	switch (indexPath.row) {
        case 0:
            //Only create new frontController instance if it is a DIFFERENT viewController class...
            if ( ![frontNavigationController.topViewController isKindOfClass:[TTLeagueTableViewController class]] ) {
                TTLeagueTableViewController *frontViewController = nil;
                frontViewController = [[TTLeagueTableViewController alloc] initWithNibName:@"TTLeagueTableView" bundle:nil];
                frontViewController.sortMode = TTLeagueTableSortByPoints;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                navigationController.navigationBar.tintColor = [UIColor colorWithRed:(7.0/255.0) green:(57.0/255.0) blue:(157.0/255.0) alpha:1.0];
                [revealController setFrontViewController:navigationController animated:YES];
            }
            //If it's the same, just toggle back...
            else {
                //Toggle back to the frontViewController & reload the league table sorting by points...
                TTLeagueTableViewController *frontViewController = (TTLeagueTableViewController*)frontNavigationController.topViewController;
                frontViewController.sortMode = TTLeagueTableSortByPoints;
                [revealController revealToggle:self];
                [frontViewController reloadLeagueTable];
            }
            break;
        case 1:
            //Only create new frontController instance if it is a DIFFERENT viewController class...
            if ( ![frontNavigationController.topViewController isKindOfClass:[TTLeagueTableViewController class]] ) {
                TTLeagueTableViewController *frontViewController = nil;
                frontViewController = [[TTLeagueTableViewController alloc] initWithNibName:@"TTLeagueTableView" bundle:nil];
                frontViewController.sortMode = TTLeagueTableSortByPointsPerGame;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                navigationController.navigationBar.tintColor = [UIColor colorWithRed:(7.0/255.0) green:(57.0/255.0) blue:(157.0/255.0) alpha:1.0];
                [revealController setFrontViewController:navigationController animated:YES];
            }
            //If it's the same, just toggle back...
            else {
                //Toggle back to the frontViewController & reload the league table sorting by points per game...
                TTLeagueTableViewController *frontViewController = (TTLeagueTableViewController*)frontNavigationController.topViewController;
                frontViewController.sortMode = TTLeagueTableSortByPointsPerGame;
                [revealController revealToggle:self];
                [frontViewController reloadLeagueTable];
            }
            break;
        case 2:
            //Only create new frontController instance if it is a DIFFERENT viewController class...
            if ( ![frontNavigationController.topViewController isKindOfClass:[TTTeamResultsViewController class]] ) {
                TTTeamResultsViewController *frontViewController = [[TTTeamResultsViewController alloc] initWithNibName:@"TTTeamResultsView" bundle:nil];
                frontViewController.showAllLeagueResults = YES;
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                navigationController.navigationBar.tintColor = [UIColor colorWithRed:(7.0/255.0) green:(57.0/255.0) blue:(157.0/255.0) alpha:1.0];
                [revealController setFrontViewController:navigationController animated:YES];
            } else {
                //Toggle back to the frontViewController to show favourite team...
                [revealController revealToggle:self];
            }
            break;
        case 3:
        {
            //Only create new frontController instance if it is a DIFFERENT viewController class...
            if ( ![frontNavigationController.topViewController isKindOfClass:[TTFixturesViewController class]] ) {
                TTFixturesViewController *frontViewController = [[TTFixturesViewController alloc] initWithNibName:@"TTFixturesView" bundle:nil];
                frontViewController.showAllFixtures = YES;
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                navigationController.navigationBar.tintColor = [UIColor colorWithRed:(7.0/255.0) green:(57.0/255.0) blue:(157.0/255.0) alpha:1.0];
                [revealController setFrontViewController:navigationController animated:YES];
            } else {
                //Toggle back to the frontViewController to show favourite team...
                [revealController revealToggle:self];
            }
        }
            break;
        case 4:
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults objectForKey:@"favouriteTeam"] != nil) {
                //Find favourite team...
                TTTeam *team;
                for (team in appDelegate.teamsParser.teams) {
                    if ([team.name isEqualToString:[defaults objectForKey:@"favouriteTeam"]]) {
                        break;
                    }
                }
                TTTeamDetailViewController *frontViewController = nil;
                frontViewController = [[TTTeamDetailViewController alloc] initWithNibName:@"TTTeamDetailView" bundle:nil];
                frontViewController.team = team;
                frontViewController.didArriveAsFavouriteTeam = YES;
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                navigationController.navigationBar.tintColor = [UIColor colorWithRed:(7.0/255.0) green:(57.0/255.0) blue:(157.0/255.0) alpha:1.0];
                [revealController setFrontViewController:navigationController animated:YES];
            }
        }
            break;
        case 5:
        {
            //Only create new frontController instance if it is a DIFFERENT viewController class...
            if ( ![frontNavigationController.topViewController isKindOfClass:[TTSettingsViewController class]] ) {
                TTSettingsViewController *frontViewController = [[TTSettingsViewController alloc] initWithNibName:@"TTSettingsView" bundle:nil];
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
                navigationController.navigationBar.tintColor = [UIColor colorWithRed:(7.0/255.0) green:(57.0/255.0) blue:(157.0/255.0) alpha:1.0];
                [revealController setFrontViewController:navigationController animated:YES];
            } else {
                //Toggle back to the frontViewController to show settings screen...
                [revealController revealToggle:self];
            }
        }
            break;
        default:
            break;
    }
    
    //Deselect the row...
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
