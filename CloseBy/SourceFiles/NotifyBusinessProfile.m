//
//  NotifyBusinessProfile.m
//  CloseBy
//
//  Created by iGold on 3/12/15.
//  Copyright (c) 2015 clzby. All rights reserved.
//

#import "NotifyBusinessProfile.h"

#import "SlideNavigationController.h"
#import "BusinessDescriptionVC.h"


@implementation NotifyBusinessProfile

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    
}
- (IBAction)onClickEdit:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        BusinessDescriptionVC* vc = [self.storyboard instantiateViewControllerWithIdentifier: @"BusinessDescriptionVC"];
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:nil];
        
    }];
}
@end
