//
//  TTTeamDetailViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 20/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTTeamDetailViewController.h"

@interface TTTeamDetailViewController ()

@end

@implementation TTTeamDetailViewController
@synthesize didArriveAsFavouriteTeam;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Team", @"Team");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealController = [self revealViewController];
    
    //Add a menu button to the navigation bar that will also allow access...
    //Only if we've come here from the menu
    if (self.didArriveAsFavouriteTeam) {
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    
    //Set up teamDetailViewController attributes
    self.teamName.text = self.team.name;
    self.points.text = [NSString stringWithFormat:@"%dpts", self.team.points];
    //Decide on position suffix...
    NSString *suffix = [NSString string];
    if (self.team.leaguePosition == 1 || self.team.leaguePosition == 21) {
        suffix = @"st";
    } else if (self.team.leaguePosition == 2 || self.team.leaguePosition == 22) {
        suffix = @"nd";
    } else if (self.team.leaguePosition == 3 || self.team.leaguePosition == 23) {
        suffix = @"rd";
    } else {
        suffix = @"th";
    }
    //Set league position
    self.leaguePosition.text = [NSString stringWithFormat:@"Position: %d%@", self.team.leaguePosition, suffix];
    
    //Gradient buttons from repeated images...
    UIImage *blackButtonImage = [[UIImage imageNamed:@"blackButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blackButtonImageHighlight = [[UIImage imageNamed:@"blackButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blueButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blueButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                          resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    // Set the button background states...
    [self.seeAllResultsButton setBackgroundImage:blackButtonImage forState:UIControlStateNormal]
    ;
    [self.seeAllResultsButton setBackgroundImage:blackButtonImageHighlight forState:UIControlStateHighlighted];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"favouriteTeam"] isEqualToString:self.team.name]) {
        [self.saveAsMyTeamButton setBackgroundImage:blueButtonImage forState:UIControlStateNormal]
        ;
        [self.saveAsMyTeamButton setBackgroundImage:blueButtonImageHighlight forState:UIControlStateHighlighted];
    } else {
        [self.saveAsMyTeamButton setBackgroundImage:blackButtonImage forState:UIControlStateNormal]
        ;
        [self.saveAsMyTeamButton setBackgroundImage:blackButtonImageHighlight forState:UIControlStateHighlighted];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Set up a panGestureRecognizer for the resultsTable so that you can swipe left to access rearView of revealVC
    SWRevealViewController *revealController = [self revealViewController];
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonTapped:(UIButton *)sender {
    //Save name of favourite team...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"favouriteTeam"] isEqualToString:self.team.name]) {
        UIAlertView *teamAlreadySavedAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ is already your favourite team.", self.team.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [teamAlreadySavedAlert show];
    } else {
        [defaults setObject:self.team.name forKey:@"favouriteTeam"];
        UIAlertView *teamSavedAlert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ have been saved as your favourite team.", self.team.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [teamSavedAlert show];
    }
}

- (IBAction)seeAllResultsButtonTapped:(UIButton *)sender {
    TTTeamResultsViewController *teamResultsViewController = [[TTTeamResultsViewController alloc] initWithNibName:@"TTTeamResultsViewController" bundle:nil];
    teamResultsViewController.team = self.team;
    teamResultsViewController.showAllLeagueResults = NO;
    
    [self.navigationController pushViewController:teamResultsViewController animated:YES];
}
@end
