//
//  TTInfoBox.m
//  TeamTracker
//
//  Created by Daniel Browne on 22/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "TTInfoBox.h"

@implementation TTInfoBox

- (id)addToView:(UIView*)view withInfoText:(NSString*)infoText WhilstAnimating:(BOOL)animate{
	if (self == [super init]) {
        //Set animate flag
        animateTransitions = animate;
        
		//InfoBox size and origin
        UIFont *infoLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
		CGSize infoBoxSize = [infoText sizeWithFont:infoLabelFont];
        infoBoxSize.height *= 2.0;
        infoBoxSize.width += 20.0;
        CGFloat infoBoxOriginX, infoBoxOriginY;
        infoBoxOriginX = (view.bounds.size.width - infoBoxSize.width)/2.0;
        infoBoxOriginY = (view.bounds.size.height - infoBoxSize.height)/2.0;
        
        //Text Label
		CGRect frame = CGRectMake(10, infoBoxSize.height/4.0, infoBoxSize.width-20, infoBoxSize.height/2.0);
		UILabel *infoLabel = [[UILabel alloc] initWithFrame:frame];
		infoLabel.text = infoText;
		infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.opaque = NO;
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        infoLabel.highlightedTextColor = [UIColor whiteColor];
        infoLabel.font = infoLabelFont;
		
        //Translucent box with rounded corners & drop shadow
		frame = CGRectMake(infoBoxOriginX, infoBoxOriginY, infoBoxSize.width, infoBoxSize.height);
		UIView *infoView = [[UIView alloc] initWithFrame:frame];
		infoView.backgroundColor = [UIColor colorWithRed:0.0 green:(37/255.0) blue:(74/255.0) alpha:1.0];
		[infoView addSubview:infoLabel];
		infoView.layer.cornerRadius = 10.0;
        infoView.layer.shadowOpacity = 1.0;
        infoView.layer.shadowColor = [UIColor blackColor].CGColor;
        infoView.layer.shadowOffset = CGSizeMake(0.0f, 2.5f);
        infoView.layer.shadowRadius = 2.5f;
        
        if (animateTransitions) {
            infoView.alpha = 0.0;
        } else {
            infoView.alpha = 0.8;
        }
        
		[view addSubview:infoView];
        
        if (animateTransitions) {
            //Fade infoBox into view...
            [UIView animateWithDuration:0.3 animations:^{infoView.alpha = 0.8f;}
                             completion:^ (BOOL finished) {
                                 if (finished) {
                                     //Fade infoBox back out...
                                     [UIView animateWithDuration:0.3f delay:2.0f options:UIViewAnimationCurveEaseOut animations:^{infoView.alpha = 0.0f;} completion:NULL];
                                 }
                             }];
        }
	}
	return self;
}

@end
