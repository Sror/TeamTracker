//
//  TTBackgroundLayer.h
//  TeamTracker
//
//  Created by Daniel Browne on 20/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface TTBackgroundLayer : NSObject

+(CAGradientLayer*) greyGradient;
+(CAGradientLayer*) darkGreyGradient;
+(CAGradientLayer*) blueGradient;
+(CAGradientLayer*) greenGradient;
+(CAGradientLayer*) orangeGradient;
+(CAGradientLayer*) redGradient;

@end
