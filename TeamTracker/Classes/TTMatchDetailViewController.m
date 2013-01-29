//
//  TTMatchDetailViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 25/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTMatchDetailViewController.h"

@interface TTMatchDetailViewController ()

@end

@implementation TTMatchDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //title
    self.title = NSLocalizedString(self.result.matchDate, self.result.matchDate);
    
    //Init the UILabels & UITextViews
    self.homeTeam.text = self.result.homeTeam;
    self.homeScore.text = [NSString stringWithFormat:@"%d", self.result.homeScore];
    self.homeGoalScorers.text = self.result.homeGoalScorers;
    self.awayTeam.text = self.result.awayTeam;
    self.awayScore.text = [NSString stringWithFormat:@"%d", self.result.awayScore];
    self.awayGoalScorers.text = self.result.awayGoalScorers;
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

@end