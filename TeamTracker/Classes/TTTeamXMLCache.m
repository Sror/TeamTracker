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
        cacheData = nil;
        cacheExpiryTimeout = expiryTimeout;
        cacheExpiryDate = [NSDate dateWithTimeIntervalSinceNow:cacheExpiryTimeout];
    }
    return self;
}

- (NSData*)checkValidityOfCache {
    //Current date
    NSDate *currentDate = [NSDate date];
    NSTimeInterval comparison = [currentDate timeIntervalSinceDate:cacheExpiryDate];
    if (comparison < 0) {
        //Cache has not expired
        return cacheData;
    } else {
        cacheData = nil;
        return nil;
    }
}

- (void)setCacheWithData:(NSData*)data {
    cacheData = data;
}

- (void)invalidateCache {
    //Delete cache data
    cacheData = nil;
    //Reset cache expiry
    cacheExpiryDate = [NSDate dateWithTimeIntervalSinceNow:cacheExpiryTimeout];
}

@end
