//
//  TTTeamsParser.h
//  TeamTracker
//
//  Created by Daniel Browne on 23/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTeamXMLCache.h"
#import "SMXMLDocument.h"
#import "TTTeam.h"
#import "TTMatchResult.h"
#import "TTFixture.h"
#import "TTAppDelegate.h"

typedef enum {
    TTLeagueTableSortByPoints,
    TTLeagueTableSortByPointsPerGame
} TTLeagueTableSortBy;

@interface TTTeamsParser : NSObject {
    NSString *tXMLFile;
    NSURL *rURL;
    SMXMLDocument *teamsListXMLResponse;
    SMXMLDocument *teamsResultsXMLResponse;
    TTTeamXMLCache *teamsCache;
    NSError *parseTeamsListError;
    NSError *parseTeamsResultsError;
}

- (id)initWithLocalTeamsXMLFile:(NSString*)teamsXMLFile AndResultsURL:(NSURL*)resultsURL WithCacheExpiry:(NSTimeInterval)expiryTimeout;
- (NSError*)parseTeamsList;
- (NSError*)parseTeamsResultsXMLSortingBy:(NSInteger)sortMode;
- (void)sortTeamsForLeagueTableBy:(NSInteger)sortMode;
- (void)clearOldResultsDataFromTeams;
- (void)invalidateCacheData;

@property (nonatomic, retain) NSMutableArray *teams;

@end
