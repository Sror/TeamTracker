//
//  TTAppDelegate.m
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTAppDelegate.h"
#import "UINavigationController+ChildInterfaceOrientationsIniOS6.h"
#import "TTLeagueTableViewController.h"
#import "TTMenuViewController.h"
#import "TTTeamsParser.h"

@implementation TTAppDelegate

@synthesize parseTeamsListError;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *frontViewController, *rearViewController;
    frontViewController = [[TTLeagueTableViewController alloc] initWithNibName:@"TTLeagueTableViewController" bundle:nil];
    rearViewController = [[TTMenuViewController alloc] initWithNibName:@"TTMenuViewController" bundle:nil];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.14453125 blue:0.2890625 alpha:1.0];
    
    //Set navigationController's title font...
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0],
      UITextAttributeFont,
      nil]];
    
    //Set any back button's font...
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor], UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0], UITextAttributeFont,
      nil]
                                                forState:UIControlStateNormal];
	
	SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:navigationController];
    revealController.delegate = self;
    
    [self.window setRootViewController:revealController];
    
    //Get a URL to the teams list file...
    NSString *teamsPath = [[NSBundle mainBundle] pathForResource:@"championship_teams" ofType:@"xml"];
    //Get a URL to the results file
    NSURL *resultsURL = [NSURL URLWithString:@"http://dl.dropbox.com/u/5400542/championship_results.xml"];

    //Init teamsParser object with local teams list path, results XML URL and cache expiry of 1hr...
    self.teamsParser = [[TTTeamsParser alloc] initWithLocalTeamsXMLFile:teamsPath AndResultsURL:resultsURL
                                                   WithCacheExpiry:TTTeamXMLCacheExpiryDefault];
    
    //Parse local teams list file
    self.parseTeamsListError = [self.teamsParser parseTeamsList];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*TTTeam *team = nil;
 
 //Find the correct team...
 for (TTTeam *t in appDelegate.teams) {
 if (t.ID == teamID) {
 team = t;
 break;
 }
 }
 
 //Calculate PPG for team after each result upto gameNum
 for (int i = 0; i < gameNum; i++) {
 TTMatchResult *result = [team.results objectAtIndex:i];
 
 //If team won,
 if ((result.homeScore > result.awayScore) && (team.ID == result.homeTeam)) {
 
 }
 }
 */


/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
