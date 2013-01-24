//
//  TTMatchResult.m
//  TeamTracker
//
//  Created by Daniel Browne on 17/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTMatchResult.h"

@implementation TTMatchResult

@synthesize matchDate;
@synthesize matchDateSortID;
@synthesize homeTeam;
@synthesize awayTeam;
@synthesize homeScore;
@synthesize awayScore;

- (id)initWithHomeTeam:(NSString*)hTeam AndAwayTeam:(NSString*)aTeam WithHomeScore:(NSInteger)hScore AndAwayScore:(NSInteger)aScore AndMatchDate:(NSString*)mDate AndMatchDateSortID:(NSInteger)mDateID {
    if (self == [super init]) {
        self.matchDate = mDate;
        self.matchDateSortID = mDateID;
        self.homeTeam = hTeam;
        self.awayTeam = aTeam;
        self.homeScore = hScore;
        self.awayScore = aScore;
    }
    return self;
}

@end
