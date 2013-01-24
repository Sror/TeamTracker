//
//  TTTeamXMLCache.h
//  TeamTracker
//
//  Created by Daniel Browne on 23/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TTTeamXMLCacheExpiryNever 3155760000 //100 years
#define TTTeamXMLCacheExpiryDefault 3600     //1 hour

@interface TTTeamXMLCache : NSObject {
    NSData *cacheData;
    NSDate *cacheExpiryDate;
    NSTimeInterval cacheExpiryTimeout;
}

-(id)initWithCacheExpiryTimeOut:(NSTimeInterval)expiryTimeout;
- (NSData*)checkValidityOfCache;
- (void)setCacheWithData:(NSData*)data;
- (void)invalidateCache;

@end
