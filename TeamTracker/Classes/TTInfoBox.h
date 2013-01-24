//
//  TTInfoBox.h
//  TeamTracker
//
//  Created by Daniel Browne on 22/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface TTInfoBox : NSObject {
    BOOL animateTransitions;
}

- (id)addToView:(UIView*)view withInfoText:(NSString*)infoText WhilstAnimating:(BOOL)animate;

@end
