//
//  TTTeamXMLCache.m
//  TeamTracker
//
//  Created by Daniel Browne on 23/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTTeamXMLCache.h"

@implementation TTTeamXMLCache

-(id)initWithCacheExpiryTimeOut:(NSTimeInterval)expiryTimeout {
    if (self == [super init]) {
        //Init
        cacheDataArray = nil;
        cacheExpiryTimeout = expiryTimeout;
        cacheExpiryDate = [NSDate dateWithTimeIntervalSinceNow:cacheExpiryTimeout];
    }
    return self;
}

- (NSMutableArray*)checkValidityOfCache {
    //Current date
    NSDate *currentDate = [NSDate date];
    NSTimeInterval comparison = [currentDate timeIntervalSinceDate:cacheExpiryDate];
    //Check if cache expiry time is in past or future...
    if (comparison < 0) {
        return cacheDataArray;
    } else {
        cacheDataArray = nil;
        return nil;
    }
}

- (void)setCacheWithData:(NSMutableArray*)dataArray {
    //Set cache data
    cacheDataArray = dataArray;
}

- (void)invalidateCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Delete cache data
    cacheDataArray = nil;
    //Reset cache expiry
    cacheExpiryDate = [NSDate dateWithTimeIntervalSinceNow:[defaults integerForKey:@"cachePolicy"]];
}

@end
