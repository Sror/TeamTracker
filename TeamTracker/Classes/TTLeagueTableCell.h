//
//  TTLeagueTableCell.h
//  TeamTracker
//
//  Created by Daniel Browne on 18/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTLeagueTableCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *teamName;
@property (nonatomic) IBOutlet UILabel *leaguePosition;
@property (nonatomic) IBOutlet UILabel *gamesPlayed;
@property (nonatomic) IBOutlet UILabel *totalGoalDifference;
@property (nonatomic) IBOutlet UILabel *points;

@end
