//
//  TTMatchResult.h
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTMatchResult : NSObject {

}

- (id)initWithHomeTeam:(NSString*)hTeam AndAwayTeam:(NSString*)aTeam WithHomeScore:(NSInteger)hScore AndAwayScore:(NSInteger)aScore AndHomeGoalScorers:(NSString*)hGS AndAwayGoalScorers:(NSString*)aGS AndMatchDate:(NSString*)mDate AndMatchDateSortID:(NSInteger) mDateID;

@property (nonatomic, retain) NSString *matchDate;
@property (nonatomic) NSInteger matchDateSortID;
@property (nonatomic, retain) NSString *homeTeam;
@property (nonatomic, retain) NSString *awayTeam;
@property (nonatomic) NSInteger homeScore;
@property (nonatomic) NSInteger awayScore;
@property (nonatomic, retain) NSString *homeGoalScorers;
@property (nonatomic, retain) NSString *awayGoalScorers;

@end
