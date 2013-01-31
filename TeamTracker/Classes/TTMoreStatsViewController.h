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

#define GRAPHS_COUNT 3

@interface TTMoreStatsViewController : UIViewController <UIScrollViewDelegate>

- (IBAction)pageControlTapped:(id)sender;
- (void)layoutGraphsForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic) TTTeam *team;
@property (nonatomic) IBOutlet UIView *barView;
@property (nonatomic) IBOutlet UILabel *previousFormLabel;
@property (nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) IBOutlet UIScrollView *scrollView;
@end
