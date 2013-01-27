//
//  UINavigationController+ChildInterfaceOrientationsIniOS6.m
//  TeamTracker
//
//  Created by Daniel Browne on 27/01/2013.
//  Copyright (c) 2013 Daniel Browne. All rights reserved.
//

#import "UINavigationController+ChildInterfaceOrientationsIniOS6.h"

@implementation UINavigationController (ChildInterfaceOrientationsIniOS6)

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
