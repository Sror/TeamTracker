//
//  TTFixtureTableCell.h
//  TeamTracker
//
//  Created by Daniel Browne on 31/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTFixtureTableCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *matchDateLabel;
@property (nonatomic) IBOutlet UILabel *homeTeamLabel;
@property (nonatomic) IBOutlet UILabel *dashLabel;
@property (nonatomic) IBOutlet UILabel *awayTeamLabel;

@end
