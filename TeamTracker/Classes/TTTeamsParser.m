//
//  TTTeamsParser.m
//  TeamTracker
//
//  Created by Daniel Browne on 23/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTTeamsParser.h"

@implementation TTTeamsParser

@synthesize teams;

- (id)initWithLocalTeamsXMLFile:(NSString*)teamsXMLFile AndResultsURL:(NSURL*)resultsURL WithCacheExpiry:(NSTimeInterval)expiryTimeout {
    if (self == [super init]) {
        //Init
        tXMLFile = teamsXMLFile;
        rURL = resultsURL;
        teamsListXMLResponse = nil;
        teamsResultsXMLResponse = nil;
        teamsCache = [[TTTeamXMLCache alloc] initWithCacheExpiryTimeOut:expiryTimeout];
        parseTeamsListError = nil;
        parseTeamsResultsError = nil;
        //Init teams array
        self.teams = [NSMutableArray arrayWithCapacity:NUM_TEAMS];
    }
    return self;
}

- (NSError*)parseTeamsList {
    //Get data object...
	NSData *data = [NSData dataWithContentsOfFile:tXMLFile];
    
	//Create a new SMXMLDocument with the contents of the teams XML file
    NSError *error;
	teamsListXMLResponse = [SMXMLDocument documentWithData:data error:&error];
    
    //Check for errors
    parseTeamsListError = error;
    if (parseTeamsListError) {
        return parseTeamsListError;
    } else {
        //Pull out the <teams> node
        SMXMLElement *teamsElement = [teamsListXMLResponse.root childNamed:@"teams"];
        
        //Look through <teams> children of type <team>
        for (SMXMLElement *t in [teamsElement childrenNamed:@"team"]) {
            //Init team and add to teams array
            NSString *tName = [t valueWithPath:@"teamname"];
            TTTeam *team = [[TTTeam alloc] initTeamWithName:tName];
            [self.teams addObject:team];
        }
        
        return nil;
    }
}

- (NSError*)parseTeamsResultsXMLSortingBy:(NSInteger)sortMode {
    //Check cache first for parsed teams array...
    NSMutableArray *dataArray = [teamsCache checkValidityOfCache];
    
    //If we return nil array, cache expired, so we must re-parse if we have a network connection...
    if (dataArray == nil) {
        //No cached data, or cache invalidated due to timeout passing...
        NSData *data = [NSData dataWithContentsOfURL:rURL];
        
        //Clear old team data APART from name
        [self clearOldResultsDataFromTeams];
        
        //Create a new SMXMLDocument with the contents of results.xml
        NSError *error;
        teamsResultsXMLResponse = [SMXMLDocument documentWithData:data error:&error];
        
        //Check for errors
        parseTeamsResultsError = error;
        if (parseTeamsResultsError) {
            return parseTeamsResultsError;
        } else {
            //If we had a network problem getting the teams initially, parse them here instead
            if (parseTeamsListError) {
                //Reset error
                parseTeamsListError = nil;
                //Try again...
                parseTeamsListError = [self parseTeamsList];
                //If still error, return it...
                if (parseTeamsListError) {
                    return parseTeamsListError;
                }
            }
            
            //Pull out the <results> node
            SMXMLElement *results = [teamsResultsXMLResponse.root childNamed:@"results"];
            
            //Init matchDateSortID
            NSInteger matchDateSortID = 0;
            
            NSString *currentDate = nil;
            NSString *nextDate = nil;
            //Look through current <result> node for children of type <result>
            for (int i = 0; i < [[results childrenNamed:@"res"] count]; i++) {
                
                //Get current & next result
                //Useful for storing league position after every fixture a team plays
                SMXMLElement *result = [[results childrenNamed:@"res"] objectAtIndex:i];
                currentDate = [result valueWithPath:@"mDate"];
                if (i+1 <= [[results childrenNamed:@"res"] count]-1) {
                    SMXMLElement *nextResult = [[results childrenNamed:@"res"] objectAtIndex:i+1];
                    nextDate = [nextResult valueWithPath:@"mDate"];
                } else {
                    nextDate = nil;
                }
                
                //Format the date sensibly for display...
                NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                [dateFormater setDateFormat:@"yyyy-MM-dd"];
                NSDate *matchDateObj = [dateFormater dateFromString:[result valueWithPath:@"mDate"]];
                [dateFormater setDateFormat:@"EEEE, dd MMMM"];
                
                NSString *matchDate = [dateFormater stringFromDate:matchDateObj];
                NSString *homeTeam = [result valueWithPath:@"hTeam"];
                NSString *awayTeam = [result valueWithPath:@"aTeam"];
                NSInteger homeScore = [[result valueWithPath:@"hScore"] integerValue];
                NSInteger awayScore = [[result valueWithPath:@"aScore"] integerValue];
                NSString *homeGoalScorers = [result valueWithPath:@"hGS"];
                NSString *awayGoalScorers = [result valueWithPath:@"aGS"];
                
                //Increment matchDateSortID so that each fixture has its own ID
                //Useful when sorting ALL league fixtures by date
                matchDateSortID++;
                
                //Only init the result & add it to the team if it has been played
                //If the home and away score objects are nil, the match has NOT been played yet
                if ([result valueWithPath:@"hScore"] != nil && [result valueWithPath:@"aScore"] != nil) {
                    
                    TTMatchResult *mResult = [[TTMatchResult alloc] initWithHomeTeam:homeTeam AndAwayTeam:awayTeam WithHomeScore:homeScore AndAwayScore:awayScore AndHomeGoalScorers:homeGoalScorers AndAwayGoalScorers:awayGoalScorers AndMatchDate:matchDate AndMatchDateSortID:matchDateSortID];
                    
                    //Find the two teams involed in the result, and update their stats...
                    for (TTTeam *team in self.teams) {
                        if ([team.name isEqualToString:mResult.homeTeam] || [team.name isEqualToString:mResult.awayTeam]) {
                            //Update the team's points, and GF & GA based on the result...
                            //Team won at home...
                            if ((mResult.homeScore > mResult.awayScore) && [team.name isEqualToString:mResult.homeTeam]) {
                                team.points += 3;
                                team.homeGoalsFor += mResult.homeScore;
                                team.homeGoalsAgainst += mResult.awayScore;
                                team.homeWins++;
                                [team.formArray addObject:[NSString stringWithFormat:@"W"]];
                            }
                            //Team won away...
                            else if ((mResult.awayScore > mResult.homeScore) && [team.name isEqualToString:mResult.awayTeam]) {
                                team.points += 3;
                                team.awayGoalsFor += mResult.awayScore;
                                team.awayGoalsAgainst += mResult.homeScore;
                                team.awayWins++;
                                [team.formArray addObject:[NSString stringWithFormat:@"W"]];
                            }
                            //Team lost at home...
                            if ((mResult.homeScore < mResult.awayScore) && [team.name isEqualToString:mResult.homeTeam]) {
                                team.homeGoalsFor += mResult.homeScore;
                                team.homeGoalsAgainst += mResult.awayScore;
                                team.homeLosses++;
                                [team.formArray addObject:[NSString stringWithFormat:@"L"]];
                            }
                            //Team lost away...
                            else if ((mResult.awayScore < mResult.homeScore) && [team.name isEqualToString:mResult.awayTeam]) {
                                team.awayGoalsFor += mResult.awayScore;
                                team.awayGoalsAgainst += mResult.homeScore;
                                team.awayLosses++;
                                [team.formArray addObject:[NSString stringWithFormat:@"L"]];
                            }
                            //Team drew at home...
                            else if ((mResult.homeScore == mResult.awayScore) && [team.name isEqualToString:mResult.homeTeam]) {
                                team.points += 1;
                                team.homeGoalsFor += mResult.homeScore;
                                team.homeGoalsAgainst += mResult.awayScore;
                                team.homeDraws++;
                                [team.formArray addObject:[NSString stringWithFormat:@"D"]];
                            }
                            //Team drew away...
                            else if ((mResult.homeScore == mResult.awayScore) && [team.name isEqualToString:mResult.awayTeam]) {
                                team.points += 1;
                                team.awayGoalsFor += mResult.awayScore;
                                team.awayGoalsAgainst += mResult.homeScore;
                                team.awayDraws++;
                                [team.formArray addObject:[NSString stringWithFormat:@"D"]];
                            }
                            
                            //Update games played, pointsPerGame, historical ppgArray & goal differences
                            team.gamesPlayed++;
                            team.homeGamesPlayed = team.homeWins + team.homeDraws + team.homeLosses;
                            team.awayGamesPlayed = team.awayWins + team.awayDraws + team.awayLosses;
                            team.latestPPG = [NSNumber numberWithFloat:((float)team.points / (float)team.gamesPlayed)];
                            [team.ppgArray addObject:team.latestPPG];
                            team.totalGoalsFor = team.homeGoalsFor + team.awayGoalsFor;
                            team.totalGoalsAgainst = team.homeGoalsAgainst + team.awayGoalsAgainst;
                            team.totalGoalDifference = team.totalGoalsFor - team.totalGoalsAgainst;
                            team.played = YES;
                            
                            //Add result to both home and away teams' results arrays...
                            [team.results addObject:mResult];
                        }
                    }
                } else {
                    TTFixture *mFixture = [[TTFixture alloc] initWithHomeTeam:homeTeam AndAwayTeam:awayTeam AndMatchDate:matchDate AndMatchDateSortID:matchDateSortID];
                    
                    //Find the two teams involed in the result, and update their stats...
                    for (TTTeam *team in self.teams) {
                        if ([team.name isEqualToString:mFixture.homeTeam] || [team.name isEqualToString:mFixture.awayTeam]) {
                            //add fixture
                            [team.fixtures addObject:mFixture];
                        }
                    }
                }
                
                //If we are sorting by points, and the next RESULT is a different date, 
                if (sortMode == TTLeagueTableSortByPoints && ![nextDate isEqualToString:currentDate] && [result valueWithPath:@"hScore"] != nil && [result valueWithPath:@"aScore"] != nil) {
                    //Sort table to find league positions at this stage
                    [self sortTeamsForLeagueTableBy:sortMode];
                    //If a team has played on this date, store their league position
                    for (TTTeam *t in self.teams) {
                        if (t.played) {
                            [t.leaguePositionArray addObject:[NSNumber numberWithInteger:t.leaguePosition]];
                            t.played = NO;
                        }
                    }
                }
            }
            
            //Reverse results & fixtures for each team so most recent team result first
            for (TTTeam *team in self.teams) {
                team.results = (NSMutableArray*)[[team.results reverseObjectEnumerator] allObjects];
            }
            
            //Add results array to cache
            [teamsCache invalidateCache];
            [teamsCache setCacheWithData:self.teams];
            
            //Sort the teams table...
            [self sortTeamsForLeagueTableBy:sortMode];
            
            return nil;
        }
    } else {
        //Cache valid, so teams array already in memory & no need to parse -> no error
        
        //Sort the teams table...
        [self sortTeamsForLeagueTableBy:sortMode];
        return nil;
    }
}

- (void)sortTeamsForLeagueTableBy:(NSInteger)sortMode {
    NSMutableArray *arrayToSort = [NSMutableArray arrayWithArray:(NSArray*)self.teams];
    
    if (sortMode == TTLeagueTableSortByPoints) {
        //Sort table by doing least significant factor -> most significant factor
        //First sort by goals For...
        NSSortDescriptor *totalGoalsForSort = [NSSortDescriptor sortDescriptorWithKey:@"totalGoalsFor" ascending:NO];
        [arrayToSort sortUsingDescriptors:[NSMutableArray arrayWithObject:totalGoalsForSort]];
        
        //Then sort by goal difference...
        NSSortDescriptor *totalGoalDifferenceSort = [NSSortDescriptor sortDescriptorWithKey:@"totalGoalDifference" ascending:NO];
        [arrayToSort sortUsingDescriptors:[NSMutableArray arrayWithObject:totalGoalDifferenceSort]];
        
        //Finally sort by points or pointsPerGame...
        NSSortDescriptor *pointsSort = [NSSortDescriptor sortDescriptorWithKey:@"points" ascending:NO];
        [arrayToSort sortUsingDescriptors:[NSMutableArray arrayWithObject:pointsSort]];
    } else {
        //Just sort by PPG...
        NSSortDescriptor *pointsSort = [NSSortDescriptor sortDescriptorWithKey:@"latestPPG" ascending:NO];
        [arrayToSort sortUsingDescriptors:[NSMutableArray arrayWithObject:pointsSort]];
    }
    
    //Set league postion value
    for (int i = 0; i < NUM_TEAMS; i++) {
        TTTeam *team = [arrayToSort objectAtIndex:i];
        team.leaguePosition = i+1;
    }
    
    self.teams = arrayToSort;
}

- (void)invalidateCacheData {
    //Manuall invalidate the cache data regardless
    [teamsCache invalidateCache];
}

- (void)clearOldResultsDataFromTeams {
    //Reset all the team data APART from name
    for (TTTeam *team in self.teams) {
        team.leaguePosition = 0;
        team.gamesPlayed = 0;
        team.homeGamesPlayed = 0;
        team.awayGamesPlayed = 0;
        team.homeGoalsFor = 0;
        team.homeGoalsAgainst = 0;
        team.awayGoalsFor = 0;
        team.awayGoalsAgainst = 0;
        team.totalGoalDifference = 0;
        team.totalGoalsFor = 0;
        team.totalGoalsAgainst = 0;
        team.homeWins = 0;
        team.homeDraws = 0;
        team.homeLosses = 0;
        team.awayWins = 0;
        team.awayDraws = 0;
        team.awayLosses = 0;
        team.points = 0;
        team.latestPPG = [NSNumber numberWithFloat:0.0f];
        [team.ppgArray removeAllObjects];
        [team.formArray removeAllObjects];
        [team.leaguePositionArray removeAllObjects];
        [team.fixtures removeAllObjects];
        [team.results removeAllObjects];
    }
}

@end
