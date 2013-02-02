//
//  TTTeam.h
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTMatchResult.h"
#import "TTFixture.h"

@interface TTTeam : NSObject {

}

@property (nonatomic, retain) NSString *name;
@property (nonatomic) NSInteger leaguePosition;
@property (nonatomic) NSInteger gamesPlayed;
@property (nonatomic) NSInteger homeGoalsFor;
@property (nonatomic) NSInteger homeGoalsAgainst;
@property (nonatomic) NSInteger awayGoalsFor;
@property (nonatomic) NSInteger awayGoalsAgainst;
@property (nonatomic) NSInteger totalGoalsFor;
@property (nonatomic) NSInteger totalGoalsAgainst;
@property (nonatomic) NSInteger totalGoalDifference;
@property (nonatomic) NSInteger homeWins;
@property (nonatomic) NSInteger homeDraws;
@property (nonatomic) NSInteger homeLosses;
@property (nonatomic) NSInteger awayWins;
@property (nonatomic) NSInteger awayDraws;
@property (nonatomic) NSInteger awayLosses;
@property (nonatomic) NSInteger homeGamesPlayed;
@property (nonatomic) NSInteger awayGamesPlayed;
@property (nonatomic) NSInteger points;
@property (nonatomic) NSNumber *latestPPG;
@property (nonatomic, retain) NSMutableArray *ppgArray;
@property (nonatomic, retain) NSMutableArray *formArray;
@property (nonatomic, retain) NSMutableArray *leaguePositionArray;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSMutableArray *fixtures;
@property (nonatomic) BOOL played;

- (id)initTeamWithName:(NSString*)teamName;
- (void)addMatchResult:(TTMatchResult*)mResult;

@end
