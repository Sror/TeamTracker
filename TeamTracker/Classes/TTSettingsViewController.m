//
//  TTSettingsViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 05/02/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTSettingsViewController.h"
#import "TTTeamsParser.h"

@interface TTSettingsViewController ()

@end

@implementation TTSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Settings", @"Settings");
        
        //Init app delegate
        appDelegate = (TTAppDelegate*)[UIApplication sharedApplication].delegate;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Set the selected index of the segmented control
    if ([defaults integerForKey:@"cachePolicy"] == TTTeamXMLCacheExpiryImmediate) {
        self.cacheSegmentedControl.selectedSegmentIndex = 0;
    } else if ([defaults integerForKey:@"cachePolicy"] == TTTeamXMLCacheExpiryDefault) {
        self.cacheSegmentedControl.selectedSegmentIndex = 1;
    } else if ([defaults integerForKey:@"cachePolicy"] == TTTeamXMLCacheExpiryTwoHours) {
        self.cacheSegmentedControl.selectedSegmentIndex = 2;
    } else if ([defaults integerForKey:@"cachePolicy"] == TTTeamXMLCacheExpiryNever) {
        self.cacheSegmentedControl.selectedSegmentIndex = 3;
    }
    
    SWRevealViewController *revealController = [self revealViewController];
    
    //Add a menu button to the navigation bar that will also allow access...
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"] style:UIBarButtonItemStyleBordered target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    //Gradient buttons from repeated images...
    UIImage *blueButtonImage = [[UIImage imageNamed:@"blueButton.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *blueButtonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    // Set the button background states...
    [self.aboutButton setBackgroundImage:blueButtonImage forState:UIControlStateNormal];
    [self.aboutButton setBackgroundImage:blueButtonImageHighlight forState:UIControlStateHighlighted];
    
    //Copyright label
    self.copyrightLabel.text = [NSString stringWithFormat:@"TeamTracker v%@ © 2013 Daniel Browne. All rights reserved.", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Set up a panGestureRecognizer for the resultsTable so that you can swipe left to access rearView of revealVC
    SWRevealViewController *revealController = [self revealViewController];
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
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

- (IBAction)cacheSegmentedControlTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Set the current cache policy...
    switch (self.cacheSegmentedControl.selectedSegmentIndex) {
        case 0:
            [defaults setInteger:(NSInteger)TTTeamXMLCacheExpiryImmediate forKey:@"cachePolicy"];
            break;
        case 1:
            [defaults setInteger:(NSInteger)TTTeamXMLCacheExpiryDefault forKey:@"cachePolicy"];
            break;
        case 2:
            [defaults setInteger:(NSInteger)TTTeamXMLCacheExpiryTwoHours forKey:@"cachePolicy"];
            break;
        case 3:
            [defaults setInteger:(NSInteger)TTTeamXMLCacheExpiryNever forKey:@"cachePolicy"];
            break;
        default:
            break;
    }
    
    //Invalidate cache
    [appDelegate.teamsParser invalidateCacheData];
}

- (IBAction)aboutButtonTapped:(id)sender {
    TTAboutViewController *aboutResultsViewController = [[TTAboutViewController alloc] initWithNibName:@"TTAboutView" bundle:nil];
    
    [self.navigationController pushViewController:aboutResultsViewController animated:YES];
}
@end
