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

@interface TTAppDelegate : UIResponder <UIApplicationDelegate, SWRevealViewControllerDelegate> {

}

@property (nonatomic, retain) TTTeamsParser *teamsParser;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain) NSError *parseTeamsListError;

@end
