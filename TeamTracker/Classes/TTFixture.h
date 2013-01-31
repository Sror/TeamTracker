//
//  TTFixture.h
//  TeamTracker
//
//  Created by Daniel Browne on 31/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTFixture : NSObject

@property (nonatomic, retain) NSString *matchDate;
@property (nonatomic) NSInteger matchDateSortID;
@property (nonatomic, retain) NSString *homeTeam;
@property (nonatomic, retain) NSString *awayTeam;

- (id)initWithHomeTeam:(NSString*)hTeam AndAwayTeam:(NSString*)aTeam AndMatchDate:(NSString*)mDate AndMatchDateSortID:(NSInteger)mDateID;

@end
