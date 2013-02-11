//
//  TTMoreStatsViewController.m
//  TeamTracker
//
//  Created by Daniel Browne on 31/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTMoreStatsViewController.h"

@interface TTMoreStatsViewController ()

@end

@implementation TTMoreStatsViewController

@synthesize team;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *statsTitle = [NSString stringWithFormat:@"%@ Stats", self.team.name];
    self.title = statsTitle;
    
    //Find team's previous form for last 6 games
    for (int i = ([self.team.formArray count]-6); i < [self.team.formArray count]; i++) {
        NSString *formChar = nil;
        if (i == ([self.team.formArray count]-1)) {
            formChar = [NSString stringWithFormat:@"%@", [self.team.formArray objectAtIndex:i]];
        } else {
            formChar = [NSString stringWithFormat:@"%@, ", [self.team.formArray objectAtIndex:i]];
        }
        self.previousFormLabel.text = [self.previousFormLabel.text stringByAppendingString:formChar];
    }
    
    //Attack label
    float homeGoalsPerGame = (float)self.team.homeGoalsFor / (float)self.team.homeGamesPlayed;
    float awayGoalsPerGame = (float)self.team.awayGoalsFor / (float)self.team.awayGamesPlayed;
    float totalGoalsPerGame = (float)self.team.totalGoalsFor / (float)self.team.gamesPlayed;
    self.attackLabel.text = [NSString stringWithFormat:@"H: %.2f, A: %.2f, T: %.2f", homeGoalsPerGame, awayGoalsPerGame, totalGoalsPerGame];
    
    //Defence Label
    float homeGoalsConcededPerGame = (float)self.team.homeGoalsAgainst / (float)self.team.homeGamesPlayed;
    float awayGoalsConcededPerGame = (float)self.team.awayGoalsAgainst / (float)self.team.awayGamesPlayed;
    float totalGoalsConcededPerGame = (float)self.team.totalGoalsAgainst / (float)self.team.gamesPlayed;
    self.defenceLabel.text = [NSString stringWithFormat:@"H: %.2f, A: %.2f, T: %.2f", homeGoalsConcededPerGame, awayGoalsConcededPerGame, totalGoalsConcededPerGame];
    
    //Games Since
    int fTS, cS;
    fTS = 0;
    cS = 0;
    for (TTMatchResult *result in self.team.results) {
        //Find failed to score total
        if ([self.team.name isEqualToString:result.homeTeam] && result.homeScore > 0) {
            fTS++;
        } else if ([self.team.name isEqualToString:result.awayTeam] && result.awayScore > 0) {
            fTS++;
        } else if (([self.team.name isEqualToString:result.homeTeam] && result.homeScore == 0) || ([self.team.name isEqualToString:result.awayTeam] && result.awayScore == 0)) {
            break;
        }
    }
    for (TTMatchResult *result in self.team.results) {
        //Find clean sheet total
        if ([self.team.name isEqualToString:result.homeTeam] && result.awayScore > 0) {
            cS++;
        } else if ([self.team.name isEqualToString:result.awayTeam] && result.homeScore > 0) {
            cS++;
        } else if (([self.team.name isEqualToString:result.homeTeam] && result.awayScore == 0) || ([self.team.name isEqualToString:result.awayTeam] && result.homeScore == 0)) {
            break;
        }
    }
    //Set games Since label
    self.gamesSinceLabel.text = [NSString stringWithFormat:@"FtS: %d, CS: %d", fTS, cS];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutGraphsForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
}

- (void)addGraphsToScrollViewWithGraphData:(NSArray*)array AndGraphType:(NSInteger)type AtIndex:(NSInteger)index {
    CGRect graphFrame;
    graphFrame.origin.x = self.scrollView.frame.size.width * index;
    graphFrame.origin.y = 0;
    graphFrame.size = self.scrollView.frame.size;
    
    TTGraphView *graphView = [[TTGraphView alloc] initWithFrame:graphFrame AndGraphData:array AndGraphType:type];
    [self.scrollView addSubview:graphView];
}

- (void)layoutGraphsForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    //Remove old graphs
    if (self.scrollView.subviews != nil)
        [self.scrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //Add graphs to scrollView
    if (orientation == UIInterfaceOrientationPortrait) {
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.view.frame.size.height);
        
    } else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.view.frame.size.height - 208.0);
    }
    
    [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.leaguePositionArray AndGraphType:TTGraphViewTypeLeaguePosition AtIndex:0];
    [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.pointsArray AndGraphType:TTGraphViewTypePointsAccrued AtIndex:1];
    [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.ppgArray AndGraphType:TTGraphViewTypePredictedTotal AtIndex:2];
    
    //Decide on this graph based on League position
    if (self.team.leaguePosition <= 6) {
        [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.pointsArray AndGraphType:TTGraphViewTypePPGAutos AtIndex:3];
    } else if (self.team.leaguePosition > 6 && self.team.leaguePosition <= 12) {
        [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.pointsArray AndGraphType:TTGraphViewTypePPGPlayoffs AtIndex:3];
    } else {
        [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.pointsArray AndGraphType:TTGraphViewTypePPGSafety AtIndex:3];
    }
    
    //Set scrollView contentSize
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * GRAPHS_COUNT, self.scrollView.frame.size.height);
    self.pageControl.numberOfPages = GRAPHS_COUNT;
    
    [UIView animateWithDuration:0.5f animations:^{self.scrollView.alpha = 1.0f;}
                     completion:^ (BOOL finished) {
                         if (finished) {
                             //
                         }
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        //Hide other UI
        self.previousFormLabel.hidden = YES;
        self.pageControl.hidden = YES;
        self.previousFormTitleLabel.hidden = YES;
        self.barView.hidden = YES;
        self.attackTitleLabel.hidden = YES;
        self.attackLabel.hidden = YES;
        self.defenceTitleLabel.hidden = YES;
        self.defenceLabel.hidden = YES;
        self.gamesSinceTitleLabel.hidden = YES;
        self.gamesSinceLabel.hidden = YES;
        self.grassImageView.hidden = YES;
        self.helpButton.hidden = YES;
    } else {
        //Hide other UI
        self.previousFormLabel.hidden = NO;
        self.pageControl.hidden = NO;
        self.previousFormTitleLabel.hidden = NO;
        self.barView.hidden = NO;
        self.attackTitleLabel.hidden = NO;
        self.attackLabel.hidden = NO;
        self.defenceTitleLabel.hidden = NO;
        self.defenceLabel.hidden = NO;
        self.gamesSinceTitleLabel.hidden = NO;
        self.gamesSinceLabel.hidden = NO;
        self.grassImageView.hidden = NO;
        self.helpButton.hidden = NO;
    }
    
    [UIView animateWithDuration:0.5 animations:^{self.scrollView.alpha = 0.0f;}
                     completion:^ (BOOL finished) {
                         if (finished) {
                             //
                         }
                     }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //Decide on graph layout
    [self layoutGraphsForInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    //Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)pageControlTapped:(id)sender {
    //Update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)helpButtonTapped:(id)sender {
    UIAlertView *teamSavedAlert = [[UIAlertView alloc] initWithTitle:@"Help" message:@"This screen shows extended stats:\n\n\u2022 Form over past 6 games\n\u2022 Goals scored/conceded per game\n\u2022 Games since team failed to score\n\u2022 Games since team a clean sheet\n\n Rotate the phone to make graphs fill the screen!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [teamSavedAlert show];
}

@end
