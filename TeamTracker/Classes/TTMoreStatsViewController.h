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

#define GRAPHS_COUNT 4

@interface TTMoreStatsViewController : UIViewController <UIScrollViewDelegate> {
}

- (IBAction)pageControlTapped:(id)sender;
- (IBAction)helpButtonTapped:(id)sender;
- (void)addGraphsToScrollViewWithGraphData:(NSArray*)array AndGraphType:(NSInteger)type AtIndex:(NSInteger)index;
- (void)layoutGraphsForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic) TTTeam *team;
@property (nonatomic) IBOutlet UIView *barView;
@property (nonatomic) IBOutlet UILabel *previousFormLabel;
@property (nonatomic) IBOutlet UILabel *previousFormTitleLabel;
@property (nonatomic) IBOutlet UILabel *attackTitleLabel;
@property (nonatomic) IBOutlet UILabel *attackLabel;
@property (nonatomic) IBOutlet UILabel *defenceTitleLabel;
@property (nonatomic) IBOutlet UILabel *defenceLabel;
@property (nonatomic) IBOutlet UILabel *gamesSinceTitleLabel;
@property (nonatomic) IBOutlet UILabel *gamesSinceLabel;
@property (nonatomic) IBOutlet UIImageView *grassImageView;
@property (nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) IBOutlet UIButton *helpButton;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@end
