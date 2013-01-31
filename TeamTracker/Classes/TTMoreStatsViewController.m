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
        self.title = NSLocalizedString(@"More Stats", @"More Stats");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //layout graphs for current UI orienation
    [self layoutGraphsForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    
    //Find team's previous form for last 6 games
    for (int i = ([self.team.formArray count]-1); i > ([self.team.formArray count]-7); i--) {
        NSString *formChar = nil;
        if (i == ([self.team.formArray count]-6)) {
            formChar = [NSString stringWithFormat:@"%@", [self.team.formArray objectAtIndex:i]];
        } else {
            formChar = [NSString stringWithFormat:@"%@, ", [self.team.formArray objectAtIndex:i]];
        }
        self.previousFormLabel.text = [self.previousFormLabel.text stringByAppendingString:formChar];
    }
}

- (void)layoutGraphsForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    //Remove old graphs
    if (self.scrollView.subviews != nil)
        [self.scrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    //Add graphs to scrollView
    if (orientation == UIInterfaceOrientationPortrait) {
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.view.frame.size.height);
        
        for (int i = 0; i < GRAPHS_COUNT; i++) {
            CGRect graphFrame;
            graphFrame.origin.x = self.scrollView.frame.size.width * i;
            graphFrame.origin.y = 0;
            graphFrame.size = self.view.frame.size;
            
            TTGraphView *graphView = [[TTGraphView alloc] initWithFrame:graphFrame AndGraphData:(NSArray*)self.team.ppgArray AndTitle:@"Predicted Total Points"];
            [self.scrollView addSubview:graphView];
        }
        
        //Hide other UI
        self.previousFormLabel.hidden = YES;
        self.pageControl.hidden = YES;
        self.titleLabel.hidden = YES;
        self.barView.hidden = YES;
        
    } else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.view.frame.size.height/2.0);
        
        for (int i = 0; i < GRAPHS_COUNT; i++) {
            CGRect graphFrame;
            graphFrame.origin.x = self.scrollView.frame.size.width * i;
            graphFrame.origin.y = 0;
            graphFrame.size = self.scrollView.frame.size;
            
            TTGraphView *graphView = [[TTGraphView alloc] initWithFrame:graphFrame AndGraphData:(NSArray*)self.team.ppgArray AndTitle:@"Predicted Total Points"];
            [self.scrollView addSubview:graphView];
        }
        
        //Show other UI
        self.previousFormLabel.hidden = NO;
        self.pageControl.hidden = NO;
        self.titleLabel.hidden = NO;
        self.barView.hidden = NO;
    }
    
    //Set scrollView contentSize
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * GRAPHS_COUNT, self.scrollView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //Decide on graph layout
    [self layoutGraphsForInterfaceOrientation:fromInterfaceOrientation];
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
