//
//  TTFixturesViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 31/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTFixturesViewController.h"
#import "TTTeamsParser.h"

@interface TTFixturesViewController ()

@end

@implementation TTFixturesViewController

@synthesize showAllFixtures;
@synthesize team;
@synthesize dataSource;
@synthesize allLeagueFixtures;

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
    self.fixturesTable.separatorColor = [UIColor darkTextColor];
    
    //table dataSource
    self.dataSource = [NSMutableArray array];
    
    //Collate ALL league fixtures if requested...
    if (showAllFixtures) {
        
        //Set title...
        self.title = NSLocalizedString(@"All League Fixtures", @"All League Fixtures");
        
        //Add a menu button to the navigation bar that will also allow access...
        //Only if we've come here from the menu
        SWRevealViewController *revealController = [self revealViewController];
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
        
        self.allLeagueFixtures = [NSMutableArray array];
        for (TTTeam *t in appDelegate.teamsParser.teams) {
            [self.allLeagueFixtures addObjectsFromArray:t.fixtures];
        }
        //Strip out duplicate results
        NSMutableArray *unique = [NSMutableArray array];
        for (id obj in self.allLeagueFixtures) {
            if (![unique containsObject:obj]) {
                [unique addObject:obj];
            }
        }
        //Copy all unique result objects back to allLeagueFixtures
        //Do it in a way that removes redundant results from memory
        [self.allLeagueFixtures removeAllObjects];
        [self.allLeagueFixtures addObjectsFromArray:unique];
        [unique removeAllObjects];
        
        //Sort by matchDateSortID to put ALL results together grouped by date
        NSSortDescriptor *matchDateSort = [NSSortDescriptor sortDescriptorWithKey:@"matchDateSortID" ascending:YES];
        [self.allLeagueFixtures sortUsingDescriptors:[NSMutableArray arrayWithObject:matchDateSort]];
        
        //Set up initial amount of results to display
        for (int i = 0; i < 15; i++) {
            //Only add if result exists at index
            if (i < [self.allLeagueFixtures count]) {
                [self.dataSource addObject:[self.allLeagueFixtures objectAtIndex:i]];
            } else
                break;
        }
        
        // setup infinite scrolling
        __weak TTFixturesViewController *weakSelf = self;
        [self.fixturesTable addInfiniteScrollingWithActionHandler:^{
            
            [weakSelf.fixturesTable beginUpdates];
            for (int i = 0; i < 15; i++) {
                //Only add if result exists at index
                if ([weakSelf.dataSource count] < [weakSelf.allLeagueFixtures count]) {
                    [weakSelf.dataSource addObject:[weakSelf.allLeagueFixtures objectAtIndex:[weakSelf.dataSource count]]];
                    [weakSelf.fixturesTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.dataSource count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                } else
                    break;
            }
            [weakSelf.fixturesTable endUpdates];
            
            [weakSelf.fixturesTable.infiniteScrollingView stopAnimating];
        }];

        
    } else {
        
        //Set title...
        self.title = NSLocalizedString(@"Fixtures", @"Fixtures");
        
        //Set up initial amount of results to display
        for (int i = 0; i < 15; i++) {
            //Only add if result exists at index
            if (i < [self.team.fixtures count]) {
                [self.dataSource addObject:[self.team.fixtures objectAtIndex:i]];
            } else
                break;
        }
        
        // setup infinite scrolling
        __weak TTFixturesViewController *weakSelf = self;
        [self.fixturesTable addInfiniteScrollingWithActionHandler:^{
            
            [weakSelf.fixturesTable beginUpdates];
            for (int i = 0; i < 15; i++) {
                //Only add if result exists at index
                if ([weakSelf.dataSource count] < [weakSelf.team.fixtures count]) {
                    [weakSelf.dataSource addObject:[weakSelf.team.fixtures objectAtIndex:[weakSelf.dataSource count]]];
                    [weakSelf.fixturesTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[weakSelf.dataSource count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                } else
                    break;
            }
            [weakSelf.fixturesTable endUpdates];
            
            [weakSelf.fixturesTable.infiniteScrollingView stopAnimating];
        }];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Set up a panGestureRecognizer for the resultsTable so that you can swipe left to access rearView of revealVC
    SWRevealViewController *revealController = [self revealViewController];
    [self.fixturesTable addGestureRecognizer:revealController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //Use temp var to access custom cell properties...
    TTFixtureTableCell *customCell = (TTFixtureTableCell*)cell;
    
    //Neutral colour if showing all fixtures...
    CAGradientLayer *bgLayer = [TTBackgroundLayer lightGreyGradient];
    //Dark text colour...
    UIColor *tableTextColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    UIColor *tableTextShadowColor = [UIColor whiteColor];
    
    //Set CAGradientLayer to cell background...
    bgLayer.frame = cell.bounds;
    UIView *background = [[UIView alloc] initWithFrame: customCell.bounds];
    [background.layer insertSublayer:bgLayer atIndex:0];
    customCell.backgroundView = background;
    
    //Set other UILabel attributes...
    customCell.homeTeamLabel.textColor = tableTextColor;
    customCell.awayTeamLabel.textColor = tableTextColor;
    customCell.matchDateLabel.textColor = tableTextColor;
    customCell.dashLabel.textColor = tableTextColor;
    customCell.homeTeamLabel.shadowColor = tableTextShadowColor;
    customCell.awayTeamLabel.shadowColor = tableTextShadowColor;
    customCell.matchDateLabel.shadowColor = tableTextShadowColor;
    customCell.dashLabel.shadowColor = tableTextShadowColor;
    
    
    //set the UITableViewCell to the TTMatchResultCell
    cell = customCell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"fixtureCellIdentifier";
    TTFixtureTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        NSArray *customCell = [[NSBundle mainBundle] loadNibNamed:@"TTFixtureTableCell" owner:nil options:nil];
        if ([[customCell objectAtIndex:0] isKindOfClass:[TTFixtureTableCell class]]) {
            cell = [customCell objectAtIndex:0];
        }
    }
    
    //Get result object - indexed to place the most recent result first...
    TTFixture *fixture = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.homeTeamLabel.text = fixture.homeTeam;
    cell.awayTeamLabel.text = fixture.awayTeam;
    cell.matchDateLabel.text = fixture.matchDate;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
