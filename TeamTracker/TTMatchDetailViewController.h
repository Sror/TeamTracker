//
//  TTMatchDetailViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 25/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTMatchResult.h"
#import "SWRevealViewController.h"

@interface TTMatchDetailViewController : UIViewController
@property (nonatomic) TTMatchResult *result;
@property (nonatomic) IBOutlet UILabel *homeScore;
@property (nonatomic) IBOutlet UILabel *homeTeam;
@property (nonatomic) IBOutlet UITextView *homeGoalScorers;
@property (nonatomic) IBOutlet UILabel *awayScore;
@property (nonatomic) IBOutlet UILabel *awayTeam;
@property (nonatomic) IBOutlet UITextView *awayGoalScorers;

@end
