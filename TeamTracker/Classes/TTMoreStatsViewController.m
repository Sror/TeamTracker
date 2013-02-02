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
    
    //layout graphs for current UI orienation
    [self layoutGraphsForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    
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

- (void)addGraphsToScrollViewWithGraphData:(NSArray*)array AndGraphType:(NSInteger)type{
    CGRect graphFrame;
    graphFrame.origin.x = self.scrollView.frame.size.width * type;
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
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.view.frame.size.height/2.0);
    }
    
    [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.ppgArray AndGraphType:TTGraphViewTypePredictedTotal];
    [self addGraphsToScrollViewWithGraphData:(NSArray*)self.team.leaguePositionArray AndGraphType:TTGraphViewTypeLeaguePosition];
    
    //Set scrollView contentSize
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * GRAPHS_COUNT, self.scrollView.frame.size.height);
    
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
@end
