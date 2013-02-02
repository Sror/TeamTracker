//
//  TTMoreStatsViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 31/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTeam.h"
#import "TTGraphView.h"

#define GRAPHS_COUNT 2

@interface TTMoreStatsViewController : UIViewController <UIScrollViewDelegate>

- (IBAction)pageControlTapped:(id)sender;
- (void)addGraphsToScrollViewWithGraphData:(NSArray*)array AndGraphType:(NSInteger)type;
- (void)layoutGraphsForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic) TTTeam *team;
@property (nonatomic) IBOutlet UIView *barView;
@property (nonatomic) IBOutlet UILabel *previousFormLabel;
@property (nonatomic) IBOutlet UILabel *previousFormTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *attackTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *attackLabel;
@property (weak, nonatomic) IBOutlet UILabel *defenceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *defenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesSinceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *gamesSinceLabel;
@property (nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@end
