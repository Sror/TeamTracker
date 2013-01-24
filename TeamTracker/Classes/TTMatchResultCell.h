//
//  TTMatchResultCell.h
//  TeamTracker
//
//  Created by Daniel Browne on 19/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTMatchResultCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *homeTeam;
@property (nonatomic) IBOutlet UILabel *homeScore;
@property (nonatomic) IBOutlet UILabel *awayTeam;
@property (nonatomic) IBOutlet UILabel *awayScore;
@property (nonatomic) IBOutlet UILabel *matchDate;
@property (nonatomic) IBOutlet UILabel *dashLabel;

@end
