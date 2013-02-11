//
//  TTSettingsViewController.h
//  TeamTracker
//
//  Created by Daniel Browne on 05/02/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAppDelegate.h"
#import "TTTeamXMLCache.h"
#import "TTAboutViewController.h"
#import "SWRevealViewController.h"

@interface TTSettingsViewController : UIViewController {
    //Init app delegate
    TTAppDelegate *appDelegate;

}
@property (nonatomic) IBOutlet UISegmentedControl *cacheSegmentedControl;
@property (nonatomic) IBOutlet UIButton *aboutButton;
@property (nonatomic) IBOutlet UILabel *copyrightLabel;
- (IBAction)cacheSegmentedControlTapped:(id)sender;
- (IBAction)aboutButtonTapped:(id)sender;

@end
