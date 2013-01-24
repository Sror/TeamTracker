//
//  TTTeam.m
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTTeam.h"

@implementation TTTeam

@synthesize name;
@synthesize leaguePosition;
@synthesize gamesPlayed;
@synthesize homeGoalsFor;
@synthesize homeGoalsAgainst;
@synthesize awayGoalsFor;
@synthesize awayGoalsAgainst;
@synthesize totalGoalsFor;
@synthesize totalGoalsAgainst;
@synthesize totalGoalDifference;
@synthesize homeWins;
@synthesize homeDraws;
@synthesize homeLosses;
@synthesize awayWins;
@synthesize awayDraws;
@synthesize awayLosses;
@synthesize points;
@synthesize latestPPG;
@synthesize ppgArray;
@synthesize leaguePositionArray;
@synthesize results;

- (id)initTeamWithName:(NSString*)teamName {
    if (self == [super init]) {
        self.name = teamName;
        self.results = [NSMutableArray arrayWithCapacity:NUM_GAMES];
        self.ppgArray = [NSMutableArray arrayWithCapacity:NUM_GAMES];
        self.leaguePositionArray = [NSMutableArray arrayWithCapacity:NUM_GAMES];
    }
    return self;
}

- (void)addMatchResult:(TTMatchResult*)mResult {
    [results addObject:mResult];
}

@end
