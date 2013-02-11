//
//  TTAppDelegate.h
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMXMLDocument.h"
#import "SWRevealViewController.h"

@class TTTeamsParser;

#define NUM_TEAMS 24
#define NUM_GAMES 46
#define TEAMS_XML @"championship_teams"
#define RESULTS_XML @"http://dl.dropbox.com/u/5400542/championship_results.xml"

#define AUTOS_PLACES 2
#define PLAYOFF_PLACES 6
#define RELEGATION_PLACES 22

//Championship
#define AUTOS_BESTCASE 80
#define AUTOS_AVERAGE 87
#define AUTOS_WORSTCASE 93
#define PLAYOFFS_BESTCASE 71
#define PLAYOFFS_AVERAGE 74
#define PLAYOFFS_WORSTCASE 76
#define CHMP_SAFETY_BESTCASE 41
#define CHMP_SAFETY_AVERAGE 47
#define CHMP_SAFETY_WORSTCASE 53

//Premier League
#define CHAMPIONS_BESTCASE 81
#define CHAMPIONS_AVERAGE 89
#define CHAMPIONS_WORSTCASE 96
#define EUROPE_BESTCASE 57
#define EUROPE_AVERAGE 64
#define EUROPE_WORSTCASE 68
#define PREM_SAFETY_BESTCASE 34
#define PREM_SAFETY_AVERAGE 37
#define PREM_SAFETY_WORSTCASE 43

@interface TTAppDelegate : UIResponder <UIApplicationDelegate, SWRevealViewControllerDelegate> {

}

@property (nonatomic, retain) TTTeamsParser *teamsParser;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain) NSError *parseTeamsListError;

@end
