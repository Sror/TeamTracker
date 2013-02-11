//
//  TTTeamXMLCache.h
//  TeamTracker
//
//  Created by Daniel Browne on 23/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TTTeamXMLCacheExpiryNever 3155760000 //100 years
#define TTTeamXMLCacheExpiryTwoHours 7200     //2 hour
#define TTTeamXMLCacheExpiryDefault 3600     //1 hour
#define TTTeamXMLCacheExpiryImmediate 0     //Never cache

@interface TTTeamXMLCache : NSObject {
    NSMutableArray *cacheDataArray;
    NSDate *cacheExpiryDate;
    NSTimeInterval cacheExpiryTimeout;
}

-(id)initWithCacheExpiryTimeOut:(NSTimeInterval)expiryTimeout;
- (NSMutableArray*)checkValidityOfCache;
- (void)setCacheWithData:(NSMutableArray*)dataArray;
- (void)invalidateCache;

@end
