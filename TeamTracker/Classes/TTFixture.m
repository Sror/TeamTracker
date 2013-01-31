//
//  TTFixture.m
//  TeamTracker
//
//  Created by Daniel Browne on 31/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTFixture.h"

@implementation TTFixture

@synthesize matchDate;
@synthesize matchDateSortID;
@synthesize homeTeam;
@synthesize awayTeam;

- (id)initWithHomeTeam:(NSString*)hTeam AndAwayTeam:(NSString*)aTeam AndMatchDate:(NSString*)mDate AndMatchDateSortID:(NSInteger)mDateID {
    if (self == [super init]) {
        self.matchDate = mDate;
        self.matchDateSortID = mDateID;
        self.homeTeam = hTeam;
        self.awayTeam = aTeam;
    }
    return self;
}

@end
